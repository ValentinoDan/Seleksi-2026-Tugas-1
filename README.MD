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

> **Catatan:** Seluruh proses *scraping* dan *insert* di atas sebenarnya tidak wajib dilakukan karena *database dump* sudah tersedia pada `Data Storing/export/IndikatorNegara.sql`.

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

Hubungan utama pada ERD:

- Satu **Benua** memiliki banyak **Negara** (*one-to-many*)
- Satu **Kategori Ekonomi** memiliki banyak **Negara** (*one-to-many*)
- Satu **Negara** memiliki banyak data **Indikator** pada berbagai tahun (*one-to-many*)
- Satu **Jenis Energi** dapat memiliki beberapa **Komposisi Energi** untuk berbagai negara dan tahun yang berbeda (*one-to-many*)
- Satu **Tahun** dapat memiliki beragam **Indikator** dari berbagai negara (*one-to-many*)

<p align="center">
  <img src="Data Storing\design\ERD_Diagram.png" alt="Entity Relationship Diagram" width="900">
</p>

### Diagram Relasional RDBMS

- Tabel **Negara** menjadi tabel utama yang direferensikan oleh seluruh tabel indikator
- Seluruh tabel indikator menggunakan **composite primary key (`id_negara`, `tahun`)** sehingga setiap negara hanya memiliki satu data indikator untuk setiap tahun
- Tabel **Komposisi_Energi** menggunakan **composite primary key (`id_jenis`, `id_negara`, `tahun`)** karena setiap negara memiliki beberapa jenis energi pada tahun yang sama
- Tabel **Benua**, **Kategori_Ekonomi**, **Jenis_Energi**, dan **Tahun** berfungsi sebagai tabel referensi

<p align="center">
  <img src="Data Storing\design\Model_Relasional_dbdiagram.png" alt="Diagram Relasional RDBMS" width="1000">
</p>