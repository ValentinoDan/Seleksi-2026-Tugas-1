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
    tahun SMALLINT PRIMARY KEY
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
    FOREIGN KEY (id_benua) REFERENCES Benua(id_benua),
    FOREIGN KEY (id_kategori_ekonomi) REFERENCES Kategori_Ekonomi(id_kategori_ekonomi)
);

CREATE TABLE Indikator_GDP (
    id_negara SMALLINT,
    tahun SMALLINT,
    nilai_gdp BIGINT,
    persentase_pertumbuhan_gdp DECIMAL(5,2),
    gdp_per_capita INT,
    persentase_gdp_dunia DECIMAL(5, 2),
    rank_gdp SMALLINT,
    primary KEY (id_negara, tahun),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara),
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun)
);

CREATE TABLE Indikator_Populasi (
    id_negara SMALLINT,
    tahun SMALLINT,
    jumlah_populasi BIGINT,
    persentase_perubahan_tahunan DECIMAL(5, 2),
    perubahan_tahunan INT,
    migrasi_bersih INT,
    usia_median DECIMAL(4, 2),
    tingkat_fertilitas DECIMAL(4, 2),
    kepadatan_penduduk SMALLINT,
    persentase_penduduk_urban DECIMAL(5, 2),
    jumlah_penduduk_urban INT,
    persentase_populasi_dunia DECIMAL(5, 2),
    rank_populasi SMALLINT,
    PRIMARY KEY (id_negara, tahun),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara),
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun)
);

CREATE TABLE Indikator_CO2 (
    id_negara SMALLINT,
    tahun SMALLINT,
    emisi_co2 BIGINT,
    persentase_perubahan_setahun DECIMAL(5, 2),
    emisi_co2_per_kapita DECIMAL(5, 2),
    persentase_emisi_co2_dunia DECIMAL(5, 2),
    rank_co2 SMALLINT,
    PRIMARY KEY (id_negara, tahun),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara),
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun)
);

CREATE TABLE Indikator_Energi (
    id_negara SMALLINT,
    tahun SMALLINT,
    konsumsi_energi_total BIGINT,
    persentase_dunia DECIMAL(5, 2),
    konsumsi_per_capita INT,
    rank_energi SMALLINT,
    PRIMARY KEY (id_negara, tahun),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara),
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun)
);

CREATE TABLE Komposisi_Energi (
    id_negara SMALLINT,
    tahun SMALLINT,
    id_jenis SMALLINT,
    jumlah_komposisi BIGINT,
    persentase_konsumsi TINYINT,
    PRIMARY KEY (id_negara, tahun, id_jenis),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara),
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun),
    FOREIGN KEY (id_jenis) REFERENCES Jenis_Energi(id_jenis)
);