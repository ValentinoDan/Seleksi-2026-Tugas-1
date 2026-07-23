# Seleksi Tahap 2 Asisten Basis Data 2026

## Author
| Nama                    | NIM      |
| ----------------------- | -------- |
| Valentino Daniel Kusumo | 13524104 |

---

## Deskripsi Singkat Data, DBMS, dan Alasan Pemilihan Topik
* **Topik yang Diangkat:** Indikator global yang mencakup GDP, populasi, lingkungan (*emisi CO₂*), dan energi berbagai negara
* **DBMS yang Digunakan:** MariaDB
* **Alasan Pemilihan Topik:** Topik ini dipilih karena saya cukup tertarik untuk melihat dan menggali data makroekonomi, khususnya GDP, karena kebetulan saya baru saja mengambil matkul Makroekonomi semester 4 lalu. Selain itu, saya melihat ada beberapa indikator yang mungkin masih memiliki keterikatan, seperti populasi, emisi CO₂, dan energi.

---

## Database
1. **`Data_Storing`**: Berisi tabel hasil *scraping*
2. **`Data_Warehouse`**: Berisi tabel berstruktur *Galaxy Schema*

---

## Cara Menggunakan Docker
1. Install Docker
2. Jalankan *container* Docker
```bash
docker compose up -d --build
```
3. Masuk ke dalam MariaDB melalui container
* *General*
```bash
docker exec -it Basdat mariadb -u Basdat -pBasdat
```

* Langsung masuk ke database `Data_Storing`
```bash
docker exec -it Basdat mariadb -u Basdat -pBasdat Data_Storing
```

* Langsung masuk ke database `Data_Warehouse`
```bash
docker exec -it Basdat mariadb -u Basdat -pBasdat Data_Warehouse
```

4. Melakukan Dump SQL
```bash
docker exec Basdat mariadb-dump -u Basdat -pBasdat --add-drop-table --routines --triggers [Database] > [Path direktori]
```

---

## Cara Menggunakan *Scraper* dan Hasil Output-nya
1. Install requirement berikut
```bash
  pip install requests beautifulsoup4 mysql-connector-python
```

2. Jalankan seluruh skrip *scraper*:
```bash
  python "Data Scraping/src/scrap_co2.py"
  python "Data Scraping/src/scrap_energy.py"
  python "Data Scraping/src/scrap_gdp.py"
  python "Data Scraping/src/scrap_population.py"
  python "Data Scraping/src/scrap_region.py"
```
3. Hasilnya akan tersimpan dalam folder `Data Scraping/data/` dalam format JSON
4. Sebelum melakukan *insert data*, jalankan Docker dan sesuaikan konfigurasi `Dockerfile` berikut
```bash
  FROM mariadb:latest

  ENV MYSQL_DATABASE=Data_Storing
  ENV MYSQL_USER=Basdat
  ENV MYSQL_PASSWORD=Basdat
  ENV MYSQL_ROOT_PASSWORD=Basdat

  COPY ["Data Storing/src/tables.sql", "/docker-entrypoint-initdb.d/1-tables.sql"]
  # COPY ["Data Storing/export/IndikatorNegara.sql", "/docker-entrypoint-initdb.d/2-indikator-negara.sql"]
  # COPY ["Data Warehous/src/dim_fact.sql", "/docker-entrypoint-initdb.d/3-Dim-Fact.sql"]
  # COPY ["Data Warehous/src/insert.sql", "/docker-entrypoint-initdb.d/4-Insert.sql"]
  # COPY ["Data Warehous/src/event.sql", "/docker-entrypoint-initdb.d/5-Event.sql"]

  EXPOSE 3306
```
  Selanjutnya, jalankan
```bash
  docker compose up -d --build
```

5. Jalankan skrip *insert data*:
```bash
  python "Data Storing\src\insert_data.py"
```
6. Data akan berhasil dimasukkan ke dalam *database* `Data_Storing`

> **Notes:** Seluruh proses *scraping* dan *insert* di atas sebenarnya tidak wajib dilakukan karena hasil *dump database* sudah tersedia pada `Data Storing/export/IndikatorNegara.sql`.

---

## Penjelasan Struktur dari File JSON

### `co2.json`

| Field | Tipe | Keterangan |
|-------|------|------------|
| `rank` | Integer | Peringkat negara berdasarkan total emisi CO₂ |
| `country` | String | Nama negara |
| `tahun` | Integer | Tahun |
| `co2_emission_ton` | Integer | Total emisi CO₂ (ton) |
| `one_year_change_pct` | Float | Persentase perubahan emisi dibanding tahun sebelumnya |
| `co2_per_capita_ton` | Float | Emisi CO₂ per kapita (ton/orang) |
| `share_of_world_co2_pct` | Float | Persentase kontribusi terhadap total emisi CO₂ dunia |

Contoh:
```json
{
    "rank": 1,
    "country": "China",
    "tahun": 2024,
    "co2_emission_ton": 13124727993,
    "one_year_change_pct": 0.79,
    "co2_per_capita_ton": 9.13,
    "share_of_world_co2_pct": 33.12
}
```

---

### `energy.json`

| Field | Tipe | Keterangan |
|-------|------|------------|
| `rank` | Integer | Peringkat negara berdasarkan konsumsi energi |
| `country` | String | Nama negara |
| `tahun` | Integer | Tahun |
| `consumption_btu` | Integer | Total konsumsi energi (BTU) |
| `world_share_pct` | Float | Persentase konsumsi energi dunia |
| `per_capita_btu` | Integer | Konsumsi energi per kapita (BTU) |
| `oil_btu` | Integer | Konsumsi energi dari minyak |
| `oil_pct` | Float | Persentase energi dari minyak |
| `gas_btu` | Integer | Konsumsi energi dari gas alam |
| `gas_pct` | Float | Persentase energi dari gas alam |
| `coal_btu` | Integer | Konsumsi energi dari batu bara |
| `coal_pct` | Float | Persentase energi dari batu bara |
| `fossil_btu` | Integer | Total energi dari bahan bakar fosil |
| `fossil_pct` | Float | Persentase energi dari bahan bakar fosil |
| `renewable_btu` | Integer | Total energi terbarukan |
| `renewable_pct` | Float | Persentase energi terbarukan |

Contoh:
```json
{
    "rank": 1,
    "country": "China",
    "tahun": 2017,
    "consumption_btu": 138689472800000,
    "world_share_pct": 23.81,
    "per_capita_btu": 98197,
    "oil_btu": 24912052000000,
    "oil_pct": 18,
    "gas_btu": 8805077643000,
    "gas_pct": 6,
    "coal_btu": 87670259230000,
    "coal_pct": 63,
    "fossil_btu": 121387388873000,
    "fossil_pct": 88,
    "renewable_btu": 17302083960000,
    "renewable_pct": 12
}
```

---

### `gdp.json`

| Field | Tipe | Keterangan |
|-------|------|------------|
| `rank` | Integer | Peringkat negara berdasarkan nilai GDP |
| `country` | String | Nama negara |
| `tahun` | Integer | Tahun |
| `gdp_value` | Integer | Nilai GDP (USD) |
| `gdp_growth_pct` | Float | Pertumbuhan GDP (%) |
| `gdp_per_capita` | Integer | GDP per kapita (USD) |
| `share_of_world_gdp_pct` | Float | Persentase kontribusi terhadap GDP dunia |

Contoh:
```json
{
    "rank": 1,
    "country": "United States",
    "tahun": 2024,
    "gdp_value": 29184890000000,
    "gdp_growth_pct": 2.8,
    "gdp_per_capita": 85810,
    "share_of_world_gdp_pct": 26.23
}
```

---

### `population.json`

| Field | Tipe | Keterangan |
|-------|------|------------|
| `rank` | Integer | Peringkat negara berdasarkan jumlah penduduk |
| `country` | String | Nama negara |
| `tahun` | Integer | Tahun |
| `population` | Integer | Jumlah penduduk |
| `yearly_pct_change` | Float | Persentase perubahan jumlah penduduk per tahun |
| `yearly_change` | Integer | Perubahan jumlah penduduk dibanding tahun sebelumnya |
| `net_migrants` | Integer | Selisih antara jumlah orang yang masuk (imigran) dan jumlah orang yang keluar (emigran) |
| `median_age` | Float | Usia median penduduk |
| `fertility_rate` | Float | Tingkat fertilitas |
| `density_p_km2` | Integer | Kepadatan penduduk (jiwa/km²) |
| `urban_pop_pct` | Float | Persentase penduduk perkotaan |
| `urban_population` | Integer | Jumlah penduduk perkotaan |
| `world_pop_share_pct` | Float | Persentase populasi dunia |

Contoh:
```json
{
    "rank": 1,
    "country": "India",
    "tahun": 2024,
    "population": 1450935791,
    "yearly_pct_change": 0.89,
    "yearly_change": 12866195,
    "net_migrants": -630830,
    "median_age": 28.4,
    "fertility_rate": 1.96,
    "density_p_km2": 488,
    "urban_pop_pct": 36.6,
    "urban_population": 530387142,
    "world_pop_share_pct": 17.78
}
```

---

### `region.json`

| Field | Tipe | Keterangan |
|-------|------|------------|
| `country` | String | Nama negara |
| `region` | String | Benua tempat negara berada |

Contoh:
```json
{
    "country": "India",
    "region": "Asia"
}
```

---

## Struktur ERD dan Diagram Relasional RDBMS
### *Entity Relationship Diagram* (ERD)

- **Negara** untuk menyimpan data setiap negara
- **Benua** mengelompokkan setiap negara berdasarkan wilayah geografis
- **Kategori Ekonomi** mengelompokkan negara berdasarkan kategori ekonomi (*entity tambahan*)
- **Tahun** untuk menunjukkan waktu
- **Indikator GDP**, **Indikator Populasi**, **Indikator CO₂**, dan **Indikator Energi** menyimpan data indikator masing-masing negara pada suatu tahun
- **Jenis Energi** mendefinisikan sumber energi (Oil, Gas, Coal, Fossil, dan Renewable)
- **Komposisi Energi** menyimpan jumlah konsumsi serta persentase setiap jenis energi pada suatu negara dan tahun

Hubungan pada ERD:

- Satu **Benua** memiliki banyak **Negara** (*one-to-many*)
- Satu **Kategori Ekonomi** memiliki banyak **Negara** (*one-to-many*)
- Satu **Negara** memiliki banyak data **Indikator** pada berbagai tahun (*one-to-many*)
- Satu **Jenis Energi** dapat memiliki beberapa **Komposisi Energi** untuk berbagai negara dan tahun yang berbeda (*one-to-many*)
- Satu **Tahun** dapat memiliki beragam **Indikator** dari berbagai negara (*one-to-many*)

![Entity Relationship Diagram](Data%20Storing/design/ERD_Diagram.png)

### Diagram Relasional RDBMS

- Tabel **Negara** menjadi tabel utama yang direferensikan oleh seluruh tabel indikator
- Seluruh tabel indikator menggunakan **composite primary key (`id_negara`, `tahun`)** sehingga setiap negara hanya memiliki satu data indikator untuk setiap tahun
- Tabel **Komposisi_Energi** menggunakan **composite primary key (`id_jenis`, `id_negara`, `tahun`)** karena setiap negara memiliki beberapa jenis energi pada tahun yang sama
- Tabel **Benua**, **Kategori_Ekonomi**, **Jenis_Energi**, dan **Tahun** berfungsi sebagai tabel referensi

![Diagram Relasional RDBMS](Data%20Storing/design/Model_Relasional_dbdiagram.png)

---

## Proses Translasi ERD menjadi Diagram Relasional
- Relasi **Memiliki** antara Negara dan Indikator diubah dengan menambahkan atribut `id_negara` sebagai *foreign key* sekaligus bagian dari *composite primary key* pada seluruh tabel indikator
- Relasi **Termasuk** antara Benua dan Negara diubah dengan menambahkan atribut `id_benua` sebagai *foreign key* pada tabel Negara
- Relasi **Tergolong** antara Kategori_Ekonomi dan Negara diubah dengan menambahkan atribut `id_kategori_ekonomi` sebagai *foreign key* pada tabel `Negara`
- Relasi **Terjadi_saat** antara Tahun dan Indikator diubah dengan menambahkan atribut `tahun` sebagai *foreign key* sekaligus bagian dari *composite primary key* pada seluruh tabel indikator
- Relasi **Terdiri_dari** antara Jenis_Energi dan Komposisi_Energi dengan menambahkan atribut `id_jenis` sebagai *foreign key* sekaligus bagian dari *composite primary key* pada tabel `Komposisi_Energi`

---

## Screenshot Query
1. Top 10 Negara dengan GDP tertinggi tahun 2024

   ![Top 10 Negara GDP 2024](Data%20Storing/screenshot/Top_10_GDP.png)

2. Negara di Benua Asia dengan populasi > 100 juta dimulai dari negara dengan populasi terbesar

   ![Negara Asia Populasi](Data%20Storing/screenshot/Negara_Asia.png)

3. Indikator lengkap untuk Negara Indonesia

   ![Indikator Indonesia](Data%20Storing/screenshot/Indonesia.png)

4. Mendapatkan data negara dengan nilai GDP yang cukup tinggi, tapi tidak masuk top 30 negara penyumbang emisi CO2 tertinggi

   ![GDP vs CO2](Data%20Storing/screenshot/GDP_CO2.png)

5. Mendapatkan data negara yang mengalami resesif (*gdp growth negatif*) dan population growth yang menyusut juga secara bersamaan

   ![Negara Resesif](Data%20Storing/screenshot/resesif.png)

> **Notes**: Lebih lengkapnya dapat dilihat pada dokumen [Query_Data Storing.pdf](Data%20Storing/Query_Data%20Storing.pdf)

---

## Bonus
### Data Warehouse

![ERD Diagram Data Warehouse](Data%20Warehous/design/ERD_Diagram_Data_Warehouse.png)

Diagram *Data Warehouse* dirancang menggunakan struktur **Galaxy Schema**

**Dimension Table**

- `Negara` menyimpan informasi terkait data negara
- `Tahun` menyimpan informasi yang berkaitan dengan waktu (tahun & dekade) 
- `Jenis_Energi` menyimpan klasifikasi sumber energi

**Fact Table**

- `Indikator_Negara`, berisi indikator GDP, populasi, CO₂, dan konsumsi energi untuk setiap negara pada suatu tahun.
- `Komposisi_Energi`, berisi komposisi konsumsi energi berdasarkan jenis energi untuk setiap negara.
- `Indikator_Benua`, berisi hasil agregasi indikator setiap benua pada suatu tahun.

### Scheduling
Scheduling ini dibuat untuk memastikan data yang terdapat di `Data_Warehouse` mengikuti update terbaru dari `Data_Storing`. Pengecekan dilakukan tiap minggu mulai dari 1 Januari 2027.

```sql
USE Data_Warehouse;

DROP EVENT IF EXISTS sync_data;

DELIMITER //

CREATE EVENT sync_data
ON SCHEDULE EVERY 1 WEEK
STARTS '2027-01-01 01:00:00'
ON COMPLETION PRESERVE
DO
BEGIN
    -- conton untuk tahun
    INSERT INTO Tahun (tahun, dekade)
    SELECT tahun, CONCAT(FLOOR(tahun/10)*10, 's')
    FROM Data_Storing.Tahun
    ON DUPLICATE KEY UPDATE
    dekade = VALUES(dekade);
    ....
END //

DELIMITER ;
```

**Contoh** (*kolom updated_at berubah untuk id_negara 1*)

![Scheduling (after)](Data%20Warehous/screenshot/scheduling.png)

### Query Optimization
1. Mengubah penggunaan fungsi dengan menggunakan kondisi `WHERE`

**Before**

![Query 1 (before)](Query%20Optimasi/capita_before.png)

**After**

![Query 1 (after)](Query%20Optimasi/capita_after.png)

2. Menghilangan penggunaan *subquery* yang tidak efisien

**Before**

![Query 2 (before)](Query%20Optimasi/asia_before.png)

**After**

![Query 2 (after)](Query%20Optimasi/asia_after.png)

3. Membuat *indexing* 

**Before**

![Query 3 (before)](Query%20Optimasi/komposisi_before2.png)

**After**

![Query 3 (after)](Query%20Optimasi/komposisi_after3.png)

> **Notes**: Lebih lengkapnya dapat dilihat pada dokumen [Query_Data Warehouse.pdf](Data%20Warehous/Query_Data%20Warehouse.pdf)

---

## Referensi
* **Library yang Digunakan**: `requests`, `beautifulsoup4`, `mysql-connector-python`
* **Sumber Data**: Worldometer, https://www.worldometers.info/
* **Referensi Youtube**:
  * Panduan *Web Scraping*: [Scraping Data from a Real Website | Web Scraping in Python](https://youtu.be/8dTpNajxaH0?si=NFkVwQULUhICS37Q)
  * Panduan Konfigurasi *Scheduling*: [SQL Event Scheduling: Automate Database Tasks with Examples](https://youtu.be/bz0vTH1p4_I?si=G7gjKNUzdYQIjzdX)
  * Panduan Optimasi Basis Data: [SQL indexing best practices | How to make your database FASTER!](https://youtu.be/BIlFTFrEFOI?si=1juiAhCQPRx_CQZp)
* **Link Diagram**:
  * *ERD Data Storing*: [ERD Data Storing](https://drive.google.com/file/d/1IjYbIomGOmojFj9bfjJ1ifym5Z4D0EQF/view?usp=sharing)
  * *Relational Model Data Storing*: [Model Relasional Data Storing](https://dbdiagram.io/d/Model-Relasional-Indikator-Negara-6a58fbdac3a90dd98d52ca82)
  * *ERD Data Warehouse*: [ERD Data Warehouse](https://drive.google.com/file/d/1olDtdoWLUTAiheBvtzWk-j7drnlTdi48/view?usp=sharing)
  * *Relational Model Data Warehouse*: [Model Relasional Data Warehouse](https://dbdiagram.io/d/Model_Relasional_Data_Warehouse-6a6056eb067336e1dec99ad2)
---

## Penggunaan AI
1. **Bagian yang Dibantu AI:** 
   - Membantu proses *scraping* data
   - Membantu pembuatan *procedure* dan *event*
   - Membantu validasi sintaks MariaDB
   - Membantu membuat format `README.md`
2. **Bagian yang Dikerjakan Sendiri:** 
   - Perancangan ERD dan model relasional
   - Perancangan Data Warehouse
   - Setup Docker
   - Implementasi *query*
   - Membuat laporan untuk *query*
3. **Refleksi Penggunaan AI:** 
   - AI membantu saya memahami materi baru dengan lebih cepat dan langsung mempraktikkannya. Selain itu, AI juga mempercepat pengerjaan tugas, terutama dalam pembuatan tabel SQL dari model relasional serta validasi sintaks.
