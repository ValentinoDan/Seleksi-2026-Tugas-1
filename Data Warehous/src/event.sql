USE Data_Warehouse;

DROP EVENT IF EXISTS sync_data;

DELIMITER //

CREATE EVENT sync_data
ON SCHEDULE EVERY 1 WEEK
STARTS '2027-01-01 01:00:00'
ON COMPLETION PRESERVE
DO
BEGIN
    INSERT INTO Tahun (tahun, dekade)
    SELECT tahun, CONCAT(FLOOR(tahun/10)*10, 's')
    FROM Data_Storing.Tahun
    ON DUPLICATE KEY UPDATE
    dekade = VALUES(dekade);

    INSERT INTO Negara (id_negara, nama_negara, nama_benua)
    SELECT DISTINCT n.id_negara, n.nama_negara, b.nama_benua
    FROM Data_Storing.Negara n
    LEFT JOIN Data_Storing.Benua b ON n.id_benua = b.id_benua
    LEFT JOIN Data_Storing.Indikator_GDP g ON n.id_negara = g.id_negara AND g.tahun IS NOT NULL
    ON DUPLICATE KEY UPDATE
    nama_negara = VALUES(nama_negara),
    nama_benua = VALUES(nama_benua);

    INSERT INTO Jenis_Energi (id_jenis, nama_jenis, kategori)
    SELECT id_jenis, nama_jenis,
    CASE WHEN nama_jenis IN ('Oil', 'Gas', 'Coal') THEN 'Fosil' ELSE 'Non-Fosil' END
    FROM Data_Storing.Jenis_Energi
    ON DUPLICATE KEY UPDATE
    nama_jenis = VALUES(nama_jenis),
    kategori = VALUES(kategori);

    INSERT INTO Indikator_Negara (id_negara, tahun, jenis_kategori_ekonomi, nilai_gdp, gdp_per_capita, persentase_gdp_dunia, rank_gdp,
    jumlah_populasi, kepadatan_penduduk, persentase_penduduk_urban, usia_median, tingkat_fertilitas, rank_populasi, emisi_co2, emisi_co2_per_capita, rank_co2,
    konsumsi_energi_total, konsumsi_energi_per_capita, rank_energi)
    SELECT g.id_negara, g.tahun, 
    CASE 
        WHEN g.gdp_per_capita <= 1175 THEN 'Low Income'
        WHEN g.gdp_per_capita > 1175 AND g.gdp_per_capita <= 4635 THEN 'Lower middle income'
        WHEN g.gdp_per_capita > 4635 AND g.gdp_per_capita <= 14375 THEN 'Upper middle income'
        ELSE 'High income'
    END AS jenis_kategori_ekonomi,
    g.nilai_gdp, g.gdp_per_capita, g.persentase_gdp_dunia, g.rank_gdp,
    p.jumlah_populasi, p.kepadatan_penduduk, p.persentase_penduduk_urban, p.usia_median, p.tingkat_fertilitas, p.rank_populasi, c.emisi_co2, c.emisi_co2_per_capita, c.rank_co2,
    e.konsumsi_energi_total, e.konsumsi_per_capita, e.rank_energi
    FROM Data_Storing.Indikator_GDP g
    LEFT JOIN Data_Storing.Indikator_Populasi p ON g.id_negara = p.id_negara AND g.tahun = p.tahun
    LEFT JOIN Data_Storing.Indikator_CO2 c ON g.id_negara = c.id_negara AND g.tahun = c.tahun
    LEFT JOIN Data_Storing.Indikator_Energi e ON g.id_negara = e.id_negara AND g.tahun = e.tahun
    ON DUPLICATE KEY UPDATE
    jenis_kategori_ekonomi = VALUES(jenis_kategori_ekonomi),
    nilai_gdp = VALUES(nilai_gdp),
    gdp_per_capita = VALUES(gdp_per_capita),
    persentase_gdp_dunia = VALUES(persentase_gdp_dunia),
    rank_gdp = VALUES(rank_gdp),
    jumlah_populasi = VALUES(jumlah_populasi),
    kepadatan_penduduk = VALUES(kepadatan_penduduk),
    persentase_penduduk_urban = VALUES(persentase_penduduk_urban),
    usia_median = VALUES(usia_median),
    tingkat_fertilitas = VALUES(tingkat_fertilitas),
    rank_populasi = VALUES(rank_populasi),
    emisi_co2 = VALUES(emisi_co2),
    emisi_co2_per_capita = VALUES(emisi_co2_per_capita),
    rank_co2 = VALUES(rank_co2),
    konsumsi_energi_total = VALUES(konsumsi_energi_total),
    konsumsi_energi_per_capita = VALUES(konsumsi_energi_per_capita),
    rank_energi = VALUES(rank_energi);

    INSERT INTO Komposisi_Energi (id_negara, id_jenis, tahun, jumlah_komposisi, persentase_konsumsi)
    SELECT k.id_negara, k.id_jenis, k.tahun, k.jumlah_komposisi, k.persentase_konsumsi
    FROM Data_Storing.Komposisi_Energi k
    JOIN Data_Storing.Negara n ON k.id_negara = n.id_negara
    JOIN Data_Storing.Jenis_Energi j ON k.id_jenis = j.id_jenis
    ON DUPLICATE KEY UPDATE
    jumlah_komposisi = VALUES(jumlah_komposisi),
    persentase_konsumsi = VALUES(persentase_konsumsi);

    INSERT INTO Indikator_Benua (nama_benua, tahun, jumlah_negara_gdp, total_gdp, gdp_per_capita,
    jumlah_negara_populasi, total_populasi, jumlah_negara_co2, total_emisi_co2, co2_per_capita)
    SELECT n.nama_benua, g.tahun, COUNT(DISTINCT g.id_negara), SUM(g.nilai_gdp), AVG(g.gdp_per_capita),
        COUNT(DISTINCT p.id_negara), SUM(p.jumlah_populasi), COUNT(DISTINCT c.id_negara), SUM(c.emisi_co2), AVG(c.emisi_co2_per_capita)
    FROM Data_Storing.Indikator_GDP g
    JOIN Negara n ON g.id_negara = n.id_negara
    LEFT JOIN Data_Storing.Indikator_Populasi p ON g.id_negara = p.id_negara AND g.tahun = p.tahun
    LEFT JOIN Data_Storing.Indikator_CO2 c ON g.id_negara = c.id_negara AND g.tahun = c.tahun
    WHERE n.nama_benua IS NOT NULL AND g.tahun IS NOT NULL
    GROUP BY n.nama_benua, g.tahun
    ON DUPLICATE KEY UPDATE
    jumlah_negara_gdp = VALUES(jumlah_negara_gdp),
    total_gdp = VALUES(total_gdp),
    gdp_per_capita = VALUES(gdp_per_capita),
    jumlah_negara_populasi = VALUES(jumlah_negara_populasi),
    total_populasi = VALUES(total_populasi),
    jumlah_negara_co2 = VALUES(jumlah_negara_co2),
    total_emisi_co2 = VALUES(total_emisi_co2),
    co2_per_capita = VALUES(co2_per_capita);
END //

DELIMITER ;