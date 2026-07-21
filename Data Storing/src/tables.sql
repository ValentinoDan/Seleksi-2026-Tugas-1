DROP TABLE IF EXISTS Komposisi_Energi;
DROP TABLE IF EXISTS Indikator_Energi;
DROP TABLE IF EXISTS Indikator_CO2;
DROP TABLE IF EXISTS Indikator_Populasi;
DROP TABLE IF EXISTS Indikator_GDP;
DROP TABLE IF EXISTS Negara;
DROP TABLE IF EXISTS Jenis_Energi;
DROP TABLE IF EXISTS Tahun;
DROP TABLE IF EXISTS Kategori_Ekonomi;
DROP TABLE IF EXISTS Benua;

CREATE TABLE Benua (
    id_benua SMALLINT PRIMARY KEY AUTO_INCREMENT,
    nama_benua VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Kategori_Ekonomi (
    id_kategori_ekonomi SMALLINT PRIMARY KEY AUTO_INCREMENT,
    jenis_kategori VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Tahun (
    tahun SMALLINT PRIMARY KEY CHECK (tahun between 1900 and 2100)
);

CREATE TABLE Jenis_Energi (
    id_jenis SMALLINT PRIMARY KEY AUTO_INCREMENT,
    nama_jenis VARCHAR(100) NOT NULL
);

CREATE TABLE Negara (
    id_negara SMALLINT PRIMARY KEY AUTO_INCREMENT,
    nama_negara VARCHAR(100) NOT NULL UNIQUE,
    id_benua SMALLINT NOT NULL,
    id_kategori_ekonomi SMALLINT,
    FOREIGN KEY (id_benua) REFERENCES Benua(id_benua) ON DELETE RESTRICT,
    FOREIGN KEY (id_kategori_ekonomi) REFERENCES Kategori_Ekonomi(id_kategori_ekonomi) ON DELETE SET NULL
);

CREATE TABLE Indikator_GDP (
    id_negara SMALLINT,
    tahun SMALLINT,
    nilai_gdp BIGINT NOT NULL CHECK (nilai_gdp >= 0),
    persentase_pertumbuhan_gdp DECIMAL(5,2),
    gdp_per_capita INT CHECK (gdp_per_capita >= 0),
    persentase_gdp_dunia DECIMAL(10, 7) CHECK (persentase_gdp_dunia BETWEEN 0 AND 100),
    rank_gdp SMALLINT CHECK (rank_gdp > 0),
    primary KEY (id_negara, tahun),
    CONSTRAINT ranks_gdp UNIQUE (tahun, rank_gdp),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara) ON DELETE CASCADE,
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun) ON DELETE RESTRICT
);

CREATE TABLE Indikator_Populasi (
    id_negara SMALLINT,
    tahun SMALLINT,
    jumlah_populasi BIGINT CHECK (jumlah_populasi > 0),
    persentase_perubahan_tahunan DECIMAL(5, 2),
    perubahan_tahunan INT,
    migrasi_bersih INT,
    usia_median DECIMAL(4, 2) CHECK (usia_median >= 0),
    tingkat_fertilitas DECIMAL(4, 2),
    kepadatan_penduduk SMALLINT CHECK (kepadatan_penduduk >= 0),
    persentase_penduduk_urban DECIMAL(5, 2) CHECK (persentase_penduduk_urban BETWEEN 0 AND 100),
    jumlah_penduduk_urban INT CHECK (jumlah_penduduk_urban >= 0),
    persentase_populasi_dunia DECIMAL(10, 7) CHECK (persentase_populasi_dunia BETWEEN 0 AND 100),
    rank_populasi SMALLINT CHECK (rank_populasi > 0),
    PRIMARY KEY (id_negara, tahun),
    CONSTRAINT ranks_populasi UNIQUE (tahun, rank_populasi),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara) ON DELETE CASCADE,
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun) ON DELETE RESTRICT
);

CREATE TABLE Indikator_CO2 (
    id_negara SMALLINT,
    tahun SMALLINT,
    emisi_co2 BIGINT CHECK (emisi_co2 >= 0),
    persentase_perubahan_setahun DECIMAL(5, 2),
    emisi_co2_per_capita DECIMAL(5, 2) CHECK (emisi_co2_per_capita >= 0),
    persentase_emisi_co2_dunia DECIMAL(10, 7) CHECK (persentase_emisi_co2_dunia BETWEEN 0 AND 100),
    rank_co2 SMALLINT CHECK (rank_co2 > 0),
    PRIMARY KEY (id_negara, tahun),
    CONSTRAINT ranks_co2 UNIQUE (tahun, rank_co2),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara) ON DELETE CASCADE,
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun) ON DELETE RESTRICT
);

CREATE TABLE Indikator_Energi (
    id_negara SMALLINT,
    tahun SMALLINT,
    konsumsi_energi_total BIGINT CHECK (konsumsi_energi_total >= 0),
    persentase_dunia DECIMAL(10, 7) CHECK (persentase_dunia BETWEEN 0 AND 100),
    konsumsi_per_capita INT CHECK (konsumsi_per_capita >= 0),
    rank_energi SMALLINT CHECK (rank_energi > 0),
    PRIMARY KEY (id_negara, tahun),
    CONSTRAINT ranks_energi UNIQUE (tahun, rank_energi),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara) ON DELETE CASCADE,
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun) ON DELETE RESTRICT
);

CREATE TABLE Komposisi_Energi (
    id_negara SMALLINT,
    tahun SMALLINT,
    id_jenis SMALLINT,
    jumlah_komposisi BIGINT CHECK (jumlah_komposisi >= 0),
    persentase_konsumsi TINYINT CHECK (persentase_konsumsi BETWEEN 0 AND 100),
    PRIMARY KEY (id_negara, tahun, id_jenis),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara) ON DELETE CASCADE,
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun) ON DELETE RESTRICT,
    FOREIGN KEY (id_jenis) REFERENCES Jenis_Energi(id_jenis) ON DELETE RESTRICT
);

DELIMITER //

CREATE TRIGGER trg_persentase_energi_insert 
BEFORE INSERT ON Komposisi_Energi
FOR EACH ROW
BEGIN
    DECLARE total TINYINT;

    -- hitung total persentase konsumsi energi untuk negara dan tahun yang sama
    SELECT COALESCE(SUM(persentase_konsumsi), 0) INTO total
    FROM Komposisi_Energi
    WHERE id_negara = NEW.id_negara AND tahun = NEW.tahun;

    -- memastikan total % tidak > 101 (ada data scrape yang > 100)
    IF (total + NEW.persentase_konsumsi) > 101 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error Insert: Total persentase konsumsi energi tidak boleh melebihi 100%'; -- tetep 100 agar insert manual set di 100
    END IF;
END //

CREATE TRIGGER trg_persentase_energi_update
BEFORE UPDATE ON Komposisi_Energi
FOR EACH ROW
BEGIN
    DECLARE total TINYINT;

    -- hitung total persentase konsumsi energi untuk negara dan tahun yang sama, kecuali jenis energi yang sedang diupdate
    SELECT COALESCE(SUM(persentase_konsumsi), 0) INTO total
    FROM Komposisi_Energi
    WHERE id_negara = NEW.id_negara AND tahun = NEW.tahun AND id_jenis != OLD.id_jenis;

    -- memastikan total % tidak > 101 (ada data scrape yang > 100)
    IF (total + NEW.persentase_konsumsi) > 101 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error Update: Total persentase konsumsi energi tidak boleh melebihi 100%'; -- tetep 100 agar insert manual set di 100
    END IF;
END //

CREATE TRIGGER trg_persentase_energi_dunia_insert
BEFORE INSERT ON Indikator_Energi
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(5, 2);

    -- hitung total persentase konsumsi energi dunia untuk tahun yang sama
    SELECT COALESCE(SUM(persentase_dunia), 0) INTO total
    FROM Indikator_Energi
    WHERE tahun = NEW.tahun;

    -- memastikan total % tidak > 101 (toleransi)
    IF (total + NEW.persentase_dunia) > 101 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error Insert: Total persentase konsumsi energi dunia tidak boleh melebihi 101%';
    END IF;
END //

CREATE TRIGGER trg_persentase_energi_dunia_update
BEFORE UPDATE ON Indikator_Energi
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(5, 2);

    -- hitung total persentase konsumsi energi dunia untuk tahun yang sama, kecuali negara yang sedang diupdate
    SELECT COALESCE(SUM(persentase_dunia), 0) INTO total
    FROM Indikator_Energi
    WHERE tahun = NEW.tahun AND id_negara != OLD.id_negara;

    -- memastikan total % tidak > 101 (toleransi)
    IF (total + NEW.persentase_dunia) > 101 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error Update: Total persentase konsumsi energi dunia tidak boleh melebihi 101%';
    END IF;
END //

-- harus ada indikator energi dulu baru bisa insert komposisi energi
CREATE TRIGGER trg_indikator_before_komposisi_insert
BEFORE INSERT ON Komposisi_Energi
FOR EACH ROW
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Indikator_Energi
    WHERE id_negara = NEW.id_negara AND tahun = NEW.tahun;
    
    IF total = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data komposisi energi harus punya data indikator energi terlebih dahulu';
    END IF;
END//

CREATE PROCEDURE insert_gdp(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT,
    IN p_nilai_gdp BIGINT,
    IN p_pertumbuhan DECIMAL(5,2),
    IN p_per_capita INT,
    IN p_persen_dunia DECIMAL(5,2)
)
BEGIN
    DECLARE new_rank SMALLINT;

    -- hitung rank yang sesuai
    SELECT COUNT(*) + 1 INTO new_rank
    FROM Indikator_GDP
    WHERE tahun = p_tahun AND nilai_gdp > p_nilai_gdp;

    -- geser rank gdp + 1, mulai dari paling bawah (ada constraint unique rank_gdp)
    UPDATE Indikator_GDP
    SET rank_gdp = rank_gdp + 1
    WHERE tahun = p_tahun AND rank_gdp >= new_rank
    ORDER BY rank_gdp DESC;

    -- insert data baru dengan rank yang sesuai
    INSERT INTO Indikator_GDP (
        id_negara, tahun, nilai_gdp, persentase_pertumbuhan_gdp, 
        gdp_per_capita, persentase_gdp_dunia, rank_gdp
    ) VALUES (
        p_id_negara, p_tahun, p_nilai_gdp, p_pertumbuhan, 
        p_per_capita, p_persen_dunia, new_rank
    );
END //

CREATE PROCEDURE update_gdp(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT,
    IN p_nilai_gdp BIGINT,
    IN p_pertumbuhan DECIMAL(5,2),
    IN p_per_capita INT,
    IN p_persen_dunia DECIMAL(5,2)
)
BEGIN
    DECLARE gdp BIGINT;
    DECLARE pertumbuhan DECIMAL(5,2);
    DECLARE per_capita INT;
    DECLARE persen_dunia DECIMAL(5,2);
    
    -- ambil data lama dari indikator gdp
    SELECT nilai_gdp, persentase_pertumbuhan_gdp, gdp_per_capita, persentase_gdp_dunia
    INTO gdp, pertumbuhan, per_capita, persen_dunia
    FROM Indikator_GDP
    WHERE id_negara = p_id_negara AND tahun = p_tahun;
   
    IF gdp IS NOT NULL THEN
        
        -- pake data baru jika ada, kalo ga pake data lama
        SET gdp = COALESCE(p_nilai_gdp, gdp);
        SET pertumbuhan = COALESCE(p_pertumbuhan, pertumbuhan);
        SET per_capita = COALESCE(p_per_capita, per_capita);
        SET persen_dunia = COALESCE(p_persen_dunia, persen_dunia);
        
        -- delete dulu
        CALL delete_gdp(p_id_negara, p_tahun);
        
        -- insert lagi pake data baru
        CALL insert_gdp(p_id_negara, p_tahun, gdp, pertumbuhan, per_capita, persen_dunia);
    ELSE
        IF p_nilai_gdp IS NOT NULL THEN
            CALL insert_gdp(p_id_negara, p_tahun, p_nilai_gdp, p_pertumbuhan, p_per_capita, p_persen_dunia);
        END IF;
    END IF;
END //

CREATE PROCEDURE delete_gdp(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT
)
BEGIN
    DECLARE old_rank SMALLINT;

    -- get rank_gdp dari negara yang di delete
    SELECT rank_gdp INTO old_rank
    FROM Indikator_GDP
    WHERE id_negara = p_id_negara AND tahun = p_tahun;

    IF old_rank IS NOT NULL THEN
        
        -- hapus data indikator gdp yang dihapus
        DELETE FROM Indikator_GDP 
        WHERE id_negara = p_id_negara AND tahun = p_tahun;

        -- geser naik ke atas rank gdp, mulai dari paling atas (ada constraint unique rank_gdp)
        UPDATE Indikator_GDP
        SET rank_gdp = rank_gdp - 1
        WHERE tahun = p_tahun AND rank_gdp > old_rank
        ORDER BY rank_gdp ASC;
    END IF;
END //

CREATE PROCEDURE insert_populasi(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT,
    IN p_jumlah_populasi BIGINT,
    IN p_persen_perubahan DECIMAL(5, 2),
    IN p_perubahan_tahunan INT,
    IN p_migrasi_bersih INT,
    IN p_usia_median DECIMAL(4, 2),
    IN p_tingkat_fertilitas DECIMAL(4, 2),
    IN p_kepadatan SMALLINT,
    IN p_persen_urban DECIMAL(5, 2),
    IN p_jumlah_urban INT,
    IN p_persen_dunia DECIMAL(5, 2)
)
BEGIN
    DECLARE new_rank SMALLINT;

    -- hitung rank yang sesuai
    SELECT COUNT(*) + 1 INTO new_rank
    FROM Indikator_Populasi
    WHERE tahun = p_tahun AND jumlah_populasi > p_jumlah_populasi;

    -- geser rank populasi + 1, mulai dari paling bawah (ada constraint unique rank_populasi)
    UPDATE Indikator_Populasi
    SET rank_populasi = rank_populasi + 1
    WHERE tahun = p_tahun AND rank_populasi >= new_rank
    ORDER BY rank_populasi DESC;

    -- insert data baru dengan rank yang sesuai
    INSERT INTO Indikator_Populasi (
        id_negara, tahun, jumlah_populasi, persentase_perubahan_tahunan,
        perubahan_tahunan, migrasi_bersih, usia_median, tingkat_fertilitas,
        kepadatan_penduduk, persentase_penduduk_urban, jumlah_penduduk_urban,
        persentase_populasi_dunia, rank_populasi
    ) VALUES (
        p_id_negara, p_tahun, p_jumlah_populasi, p_persen_perubahan,
        p_perubahan_tahunan, p_migrasi_bersih, p_usia_median, p_tingkat_fertilitas,
        p_kepadatan, p_persen_urban, p_jumlah_urban,
        p_persen_dunia, new_rank
    );
END //

CREATE PROCEDURE delete_populasi(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT
)
BEGIN
    DECLARE old_rank SMALLINT;

    -- get rank_populasi dari negara yang di delete
    SELECT rank_populasi INTO old_rank
    FROM Indikator_Populasi
    WHERE id_negara = p_id_negara AND tahun = p_tahun;

    IF old_rank IS NOT NULL THEN

        -- hapus data indikator populasi yang dihapus
        DELETE FROM Indikator_Populasi 
        WHERE id_negara = p_id_negara AND tahun = p_tahun;

        -- geser naik ke atas rank populasi, mulai dari paling atas (ada constraint unique rank_populasi)
        UPDATE Indikator_Populasi
        SET rank_populasi = rank_populasi - 1
        WHERE tahun = p_tahun AND rank_populasi > old_rank
        ORDER BY rank_populasi ASC;
    END IF;
END //

CREATE PROCEDURE update_populasi(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT,
    IN p_jumlah_populasi BIGINT,
    IN p_persen_perubahan DECIMAL(5, 2),
    IN p_perubahan_tahunan INT,
    IN p_migrasi_bersih INT,
    IN p_usia_median DECIMAL(4, 2),
    IN p_tingkat_fertilitas DECIMAL(4, 2),
    IN p_kepadatan SMALLINT,
    IN p_persen_urban DECIMAL(5, 2),
    IN p_jumlah_urban INT,
    IN p_persen_dunia DECIMAL(5, 2)
)
BEGIN
    DECLARE jumlah_p BIGINT;
    DECLARE persen_perubahan DECIMAL(5, 2);
    DECLARE perubahan_t INT;
    DECLARE migrasi_b INT;
    DECLARE usia_m DECIMAL(4, 2);
    DECLARE tingkat_f DECIMAL(4, 2);
    DECLARE kepadatan SMALLINT;
    DECLARE persen_urban DECIMAL(5, 2);
    DECLARE jumlah_urban INT;
    DECLARE persen_dunia DECIMAL(5, 2);
    
    -- ambil data lama dari indikator populasi
    SELECT jumlah_populasi, persentase_perubahan_tahunan, perubahan_tahunan,
           migrasi_bersih, usia_median, tingkat_fertilitas, kepadatan_penduduk,
           persentase_penduduk_urban, jumlah_penduduk_urban, persentase_populasi_dunia
    INTO jumlah_p, persen_perubahan, perubahan_t,
         migrasi_b, usia_m, tingkat_f, kepadatan,
         persen_urban, jumlah_urban, persen_dunia
    FROM Indikator_Populasi
    WHERE id_negara = p_id_negara AND tahun = p_tahun;
   
    IF jumlah_p IS NOT NULL THEN
        
        -- pake data baru jika ada, kalo ga pake data lama
        SET jumlah_p = COALESCE(p_jumlah_populasi, jumlah_p);
        SET persen_perubahan = COALESCE(p_persen_perubahan, persen_perubahan);
        SET perubahan_t = COALESCE(p_perubahan_tahunan, perubahan_t);
        SET migrasi_b = COALESCE(p_migrasi_bersih, migrasi_b);
        SET usia_m = COALESCE(p_usia_median, usia_m);
        SET tingkat_f = COALESCE(p_tingkat_fertilitas, tingkat_f);
        SET kepadatan = COALESCE(p_kepadatan, kepadatan);
        SET persen_urban = COALESCE(p_persen_urban, persen_urban);
        SET jumlah_urban = COALESCE(p_jumlah_urban, jumlah_urban);
        SET persen_dunia = COALESCE(p_persen_dunia, persen_dunia);

        -- delete dulu
        CALL delete_populasi(p_id_negara, p_tahun);

        -- insert lagi pake data baru
        CALL insert_populasi(p_id_negara, p_tahun, jumlah_p, persen_perubahan, perubahan_t, migrasi_b, usia_m,
             tingkat_f, kepadatan, persen_urban, jumlah_urban, persen_dunia);
    ELSE
        IF p_jumlah_populasi IS NOT NULL THEN
            CALL insert_populasi(p_id_negara, p_tahun, p_jumlah_populasi, p_persen_perubahan, p_perubahan_tahunan,
                p_migrasi_bersih, p_usia_median, p_tingkat_fertilitas, p_kepadatan, p_persen_urban,
                p_jumlah_urban, p_persen_dunia);
        END IF;
    END IF;
END //

CREATE PROCEDURE insert_co2(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT,
    IN p_emisi_co2 BIGINT,
    IN p_persen_perubahan DECIMAL(5, 2),
    IN p_co2_per_capita DECIMAL(5, 2),
    IN p_persen_dunia DECIMAL(5, 2)
)
BEGIN
    DECLARE new_rank SMALLINT;

    -- hitung rank yang sesuai
    SELECT COUNT(*) + 1 INTO new_rank
    FROM Indikator_CO2
    WHERE tahun = p_tahun AND emisi_co2 > p_emisi_co2;

    -- geser rank CO2 + 1, mulai dari paling bawah (ada constraint unique rank_co2)
    UPDATE Indikator_CO2
    SET rank_co2 = rank_co2 + 1
    WHERE tahun = p_tahun AND rank_co2 >= new_rank
    ORDER BY rank_co2 DESC;

    -- insert data baru dengan rank yang sesuai
    INSERT INTO Indikator_CO2 (
        id_negara, tahun, emisi_co2, persentase_perubahan_setahun,
        emisi_co2_per_capita, persentase_emisi_co2_dunia, rank_co2
    ) VALUES (
        p_id_negara, p_tahun, p_emisi_co2, p_persen_perubahan,
        p_co2_per_capita, p_persen_dunia, new_rank
    );
END //

CREATE PROCEDURE delete_co2(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT
)
BEGIN
    DECLARE old_rank SMALLINT;

    -- get rank_co2 dari negara yang di delete
    SELECT rank_co2 INTO old_rank
    FROM Indikator_CO2
    WHERE id_negara = p_id_negara AND tahun = p_tahun;

    IF old_rank IS NOT NULL THEN

        -- hapus data indikator CO2 yang dihapus
        DELETE FROM Indikator_CO2 
        WHERE id_negara = p_id_negara AND tahun = p_tahun;

        -- geser naik ke atas rank CO2, mulai dari paling atas (ada constraint unique rank_co2)
        UPDATE Indikator_CO2
        SET rank_co2 = rank_co2 - 1
        WHERE tahun = p_tahun AND rank_co2 > old_rank
        ORDER BY rank_co2 ASC;
    END IF;
END //

CREATE PROCEDURE update_co2(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT,
    IN p_emisi_co2 BIGINT,
    IN p_persen_perubahan DECIMAL(5, 2),
    IN p_co2_per_capita DECIMAL(5, 2),
    IN p_persen_dunia DECIMAL(5, 2)
)
BEGIN
    -- ambil data lama dari indikator CO2
    DECLARE emisi BIGINT;
    DECLARE persen_perubahan DECIMAL(5, 2);
    DECLARE co2_per_capita DECIMAL(5, 2);
    DECLARE persen_dunia DECIMAL(5, 2);

    SELECT emisi_co2, persentase_perubahan_setahun, emisi_co2_per_capita, persentase_emisi_co2_dunia
    INTO emisi, persen_perubahan, co2_per_capita, persen_dunia
    FROM Indikator_CO2
    WHERE id_negara = p_id_negara AND tahun = p_tahun;

    IF emisi IS NOT NULL THEN
        
        -- pake data baru jika ada, kalo ga pake data lama
        SET emisi = COALESCE(p_emisi_co2, emisi);
        SET persen_perubahan = COALESCE(p_persen_perubahan, persen_perubahan);
        SET co2_per_capita = COALESCE(p_co2_per_capita, co2_per_capita);
        SET persen_dunia = COALESCE(p_persen_dunia, persen_dunia);

        -- delete dulu
        CALL delete_co2(p_id_negara, p_tahun);

        -- insert lagi pake data baru
        CALL insert_co2(p_id_negara, p_tahun, emisi, persen_perubahan, co2_per_capita, persen_dunia);
    ELSE
        IF p_emisi_co2 IS NOT NULL THEN
            CALL insert_co2(p_id_negara, p_tahun, p_emisi_co2, p_persen_perubahan, p_co2_per_capita, p_persen_dunia);
        END IF;
    END IF;
END //

CREATE PROCEDURE insert_energi(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT,
    IN p_konsumsi_total BIGINT,
    IN p_persen_dunia DECIMAL(5, 2),
    IN p_konsumsi_per_capita INT
)
BEGIN
    DECLARE new_rank SMALLINT;

    -- hitung rank yang sesuai
    SELECT COUNT(*) + 1 INTO new_rank
    FROM Indikator_Energi
    WHERE tahun = p_tahun AND konsumsi_energi_total > p_konsumsi_total;

    -- geser rank energi + 1, mulai dari paling bawah (ada constraint unique rank_energi)
    UPDATE Indikator_Energi
    SET rank_energi = rank_energi + 1
    WHERE tahun = p_tahun AND rank_energi >= new_rank
    ORDER BY rank_energi DESC;

    -- insert data baru dengan rank yang sesuai
    INSERT INTO Indikator_Energi (
        id_negara, tahun, konsumsi_energi_total, persentase_dunia,
        konsumsi_per_capita, rank_energi
    ) VALUES (
        p_id_negara, p_tahun, p_konsumsi_total, p_persen_dunia,
        p_konsumsi_per_capita, new_rank
    );
END //

CREATE PROCEDURE delete_energi(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT
)
BEGIN
    DECLARE old_rank SMALLINT;

    -- get rank_energi dari negara yang di delete
    SELECT rank_energi INTO old_rank
    FROM Indikator_Energi
    WHERE id_negara = p_id_negara AND tahun = p_tahun;

    IF old_rank IS NOT NULL THEN

        -- hapus data indikator energi yang dihapus
        DELETE FROM Indikator_Energi 
        WHERE id_negara = p_id_negara AND tahun = p_tahun;

        -- geser naik ke atas rank energi, mulai dari paling atas (ada constraint unique rank_energi)
        UPDATE Indikator_Energi
        SET rank_energi = rank_energi - 1
        WHERE tahun = p_tahun AND rank_energi > old_rank
        ORDER BY rank_energi ASC;
    END IF;
END //

CREATE PROCEDURE update_energi(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT,
    IN p_konsumsi_total BIGINT,
    IN p_persen_dunia DECIMAL(5, 2),
    IN p_konsumsi_per_capita INT
)
BEGIN
    DECLARE konsumsi BIGINT;
    DECLARE persen_dunia DECIMAL(5, 2);
    DECLARE per_capita INT;

    -- ambil data lama dari indikator energi
    SELECT konsumsi_energi_total, persentase_dunia, konsumsi_per_capita
    INTO konsumsi, persen_dunia, per_capita
    FROM Indikator_Energi
    WHERE id_negara = p_id_negara AND tahun = p_tahun;

    IF konsumsi IS NOT NULL THEN

        -- pake data baru jika ada, kalo ga pake data lama
        SET konsumsi = COALESCE(p_konsumsi_total, konsumsi);
        SET persen_dunia = COALESCE(p_persen_dunia, persen_dunia);
        SET per_capita = COALESCE(p_konsumsi_per_capita, per_capita);

        -- delete dulu
        CALL delete_energi(p_id_negara, p_tahun);

        -- insert lagi pake data baru
        CALL insert_energi(p_id_negara, p_tahun, konsumsi, persen_dunia, per_capita);
    ELSE
        IF p_konsumsi_total IS NOT NULL THEN
            CALL insert_energi(p_id_negara, p_tahun, p_konsumsi_total, p_persen_dunia, p_konsumsi_per_capita);
        END IF;
    END IF;
END //

CREATE PROCEDURE count_total_energi(
    IN p_id_negara SMALLINT,
    IN p_tahun SMALLINT
)
BEGIN
    DECLARE total BIGINT;
    SELECT COALESCE(SUM(jumlah_komposisi), 0) INTO total
    FROM Komposisi_Energi
    WHERE id_negara = p_id_negara AND tahun = p_tahun;
    
    CALL update_energi(p_id_negara, p_tahun, total, NULL, NULL);
END //

DELIMITER ;