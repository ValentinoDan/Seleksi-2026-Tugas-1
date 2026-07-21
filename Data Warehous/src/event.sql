USE Data_Warehouse;

SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS sync_data;

DELIMITER //

CREATE EVENT sync_data
ON SCHEDULE EVERY 1 YEAR
STARTS '2027-01-01 01:00:00'
ON COMPLETION PRESERVE
DO
BEGIN
    SET FOREIGN_KEY_CHECKS = 0;

    TRUNCATE TABLE Tahun;
    TRUNCATE TABLE Negara;
    TRUNCATE TABLE Jenis_Energi;
    TRUNCATE TABLE Indikator_Negara;
    TRUNCATE TABLE Komposisi_Energi;
    TRUNCATE TABLE Indikator_Benua;

    SET FOREIGN_KEY_CHECKS = 1;

    INSERT INTO Tahun (tahun, dekade)
    SELECT tahun, CONCAT(FLOOR(tahun/10)*10, 's')
    FROM Data_Storing.Tahun;

    INSERT INTO Negara (id_negara, nama_negara, nama_benua)
    SELECT DISTINCT n.id_negara, n.nama_negara, b.nama_benua
    FROM Data_Storing.Negara n
    LEFT JOIN Data_Storing.Benua b ON n.id_benua = b.id_benua
    LEFT JOIN Data_Storing.Indikator_GDP g ON n.id_negara = g.id_negara AND g.tahun IS NOT NULL;

    INSERT INTO Jenis_Energi (id_jenis, nama_jenis, kategori)
    SELECT id_jenis, nama_jenis,
    CASE WHEN nama_jenis IN ('Oil', 'Gas', 'Coal') THEN 'Fosil' ELSE 'Non-Fosil' END
    FROM Data_Storing.Jenis_Energi;

    INSERT INTO Indikator_Negara (id_negara, tahun, jenis_kategori_ekonomi, nilai_gdp, gdp_per_capita, persentase_gdp_dunia, rank_gdp,
    jumlah_populasi, kepadatan_penduduk, persentase_penduduk_urban, usia_median, tingkat_fertilitas, rank_populasi, emisi_co2, emisi_co2_per_kapita, rank_co2,
    konsumsi_energi_total, konsumsi_energi_per_capita, rank_energi)
    SELECT g.id_negara, g.tahun, 
    CASE 
        WHEN g.gdp_per_capita <= 1175 THEN 'Low Income'
        WHEN g.gdp_per_capita > 1175 AND g.gdp_per_capita <= 4635 THEN 'Lower middle income'
        WHEN g.gdp_per_capita > 4635 AND g.gdp_per_capita <= 14375 THEN 'Upper middle income'
        ELSE 'High income'
    END AS jenis_kategori_ekonomi,
    g.nilai_gdp, g.gdp_per_capita, g.persentase_gdp_dunia, g.rank_gdp,
    p.jumlah_populasi, p.kepadatan_penduduk, p.persentase_penduduk_urban, p.usia_median, p.tingkat_fertilitas, p.rank_populasi, c.emisi_co2, c.emisi_co2_per_kapita, c.rank_co2,
    e.konsumsi_energi_total, e.konsumsi_per_capita, e.rank_energi
    FROM Data_Storing.Indikator_GDP g
    LEFT JOIN Data_Storing.Indikator_Populasi p ON g.id_negara = p.id_negara AND g.tahun = p.tahun
    LEFT JOIN Data_Storing.Indikator_CO2 c ON g.id_negara = c.id_negara AND g.tahun = c.tahun
    LEFT JOIN Data_Storing.Indikator_Energi e ON g.id_negara = e.id_negara AND g.tahun = e.tahun;

    INSERT INTO Komposisi_Energi (id_negara, id_jenis, tahun, jumlah_komposisi, persentase_konsumsi)
    SELECT k.id_negara, k.id_jenis, k.tahun, k.jumlah_komposisi, k.persentase_konsumsi
    FROM Data_Storing.Komposisi_Energi k
    JOIN Data_Storing.Negara n ON k.id_negara = n.id_negara
    JOIN Data_Storing.Jenis_Energi j ON k.id_jenis = j.id_jenis;

    INSERT INTO Indikator_Benua (nama_benua, tahun, jumlah_negara_gdp, total_gdp, gdp_per_capita,
    jumlah_negara_populasi, total_populasi, jumlah_negara_co2, total_emisi_co2, co2_per_kapita)
    SELECT n.nama_benua, g.tahun, COUNT(DISTINCT g.id_negara), SUM(g.nilai_gdp), AVG(g.gdp_per_capita),
        COUNT(DISTINCT p.id_negara), SUM(p.jumlah_populasi), COUNT(DISTINCT c.id_negara), SUM(c.emisi_co2), AVG(c.emisi_co2_per_kapita)
    FROM Data_Storing.Indikator_GDP g
    JOIN Negara n ON g.id_negara = n.id_negara
    LEFT JOIN Data_Storing.Indikator_Populasi p ON g.id_negara = p.id_negara AND g.tahun = p.tahun
    LEFT JOIN Data_Storing.Indikator_CO2 c ON g.id_negara = c.id_negara AND g.tahun = c.tahun
    WHERE n.nama_benua IS NOT NULL AND g.tahun IS NOT NULL
    GROUP BY n.nama_benua, g.tahun;
END //

DELIMITER ;