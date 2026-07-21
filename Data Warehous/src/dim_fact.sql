CREATE DATABASE IF NOT EXISTS Data_Warehouse;
GRANT ALL PRIVILEGES ON Data_Warehouse.* TO 'Basdat'@'%';
FLUSH PRIVILEGES;

USE Data_Warehouse;

DROP TABLE IF EXISTS Indikator_Benua;
DROP TABLE IF EXISTS Indikator_Negara;
DROP TABLE IF EXISTS Komposisi_Energi;
DROP TABLE IF EXISTS Jenis_Energi;
DROP TABLE IF EXISTS Negara;
DROP TABLE IF EXISTS Tahun;

CREATE TABLE Tahun (
    tahun SMALLINT PRIMARY KEY,
    dekade VARCHAR(10) NOT NULL
);

CREATE TABLE Negara (
    id_negara SMALLINT PRIMARY KEY,
    nama_negara VARCHAR(100) NOT NULL,
    nama_benua VARCHAR(100)
);

CREATE TABLE Jenis_Energi (
    id_jenis SMALLINT PRIMARY KEY,
    nama_jenis VARCHAR(100) NOT NULL,
    kategori VARCHAR(20)
);

CREATE TABLE Indikator_Negara (
    id_negara SMALLINT,
    tahun SMALLINT,
    jenis_kategori_ekonomi VARCHAR(500),
    nilai_gdp BIGINT,
    gdp_per_capita INT,
    persentase_gdp_dunia DECIMAL(10,7),
    rank_gdp SMALLINT,
    jumlah_populasi BIGINT,
    kepadatan_penduduk SMALLINT,
    persentase_penduduk_urban DECIMAL(5,2),
    usia_median DECIMAL(4,2),
    tingkat_fertilitas DECIMAL(4,2),
    rank_populasi SMALLINT,
    emisi_co2 BIGINT,
    emisi_co2_per_capita DECIMAL(5,2),
    rank_co2 SMALLINT,
    konsumsi_energi_total BIGINT,
    konsumsi_energi_per_capita INT,
    rank_energi SMALLINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_negara, tahun),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara),
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun)
);

CREATE TABLE Komposisi_Energi (
    id_negara SMALLINT,
    id_jenis SMALLINT,
    tahun SMALLINT,
    jumlah_komposisi BIGINT,
    persentase_konsumsi TINYINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_negara, id_jenis, tahun),
    FOREIGN KEY (id_negara) REFERENCES Negara(id_negara),
    FOREIGN KEY (id_jenis) REFERENCES Jenis_Energi(id_jenis),
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun)
);

CREATE TABLE Indikator_Benua (
    nama_benua VARCHAR(100),
    tahun SMALLINT,
    jumlah_negara_gdp INT,
    total_gdp BIGINT,
    gdp_per_capita DECIMAL(14,2),
    jumlah_negara_populasi INT,
    total_populasi BIGINT,
    jumlah_negara_co2 INT,
    total_emisi_co2 BIGINT,
    co2_per_capita DECIMAL(10,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (nama_benua, tahun),
    FOREIGN KEY (tahun) REFERENCES Tahun(tahun)
);