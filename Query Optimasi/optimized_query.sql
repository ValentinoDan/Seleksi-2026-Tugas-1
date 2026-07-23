-- Query 1 (Before), pake fungsi ROUND
SELECT nama_negara, tahun, gdp_per_capita 
FROM Indikator_Negara
NATURAL JOIN Negara
WHERE ROUND(gdp_per_capita / 1000) = 5
ORDER BY gdp_per_capita DESC;

-- Query 1 (After), pake kondisi WHERE aja
SELECT nama_negara, tahun, gdp_per_capita 
FROM Indikator_Negara
NATURAL JOIN Negara
WHERE gdp_per_capita >= 4500 AND gdp_per_capita < 5500
ORDER BY gdp_per_capita DESC;

-- Query 2 (Before), pake subquery yang tidak efisien
SELECT nama_negara, nilai_gdp, tahun
FROM Indikator_Negara i
NATURAL JOIN Negara
WHERE id_negara in (SELECT id_negara FROM Negara WHERE nama_benua = 'Asia');

-- Query 2 (After), hilangkan subquery
SELECT nama_negara, nilai_gdp, tahun
FROM Indikator_Negara i
NATURAL JOIN Negara
WHERE nama_benua = 'Asia';

-- Query 3 (Before), ada bagi di WHERE
SELECT nama_negara, tahun, nama_jenis, jumlah_komposisi
FROM Komposisi_Energi
NATURAL JOIN Negara
NATURAL JOIN Jenis_Energi
WHERE jumlah_komposisi / 1000000 > 100;

-- Query 3 (After), create indexing
CREATE INDEX idx_komposisi ON Komposisi_Energi (jumlah_komposisi);

SELECT n.nama_negara, k.tahun, j.nama_jenis, k.jumlah_komposisi FROM Komposisi_Energi k
JOIN Negara n ON k.id_negara = n.id_negara
JOIN Jenis_Energi j ON k.id_jenis = j.id_jenis
WHERE k.jumlah_komposisi > 100000000;