import json
import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    port=3307,
    user="Basdat",
    password="Basdat",
    database="IndikatorNegara"
)
cur = conn.cursor()

# Load JSON files
def load_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

gdp = load_json("Data Scraping/data/gdp.json")
region = load_json("Data Scraping/data/region.json")
energy = load_json("Data Scraping/data/energy.json")
co2 = load_json("Data Scraping/data/co2.json")
population = load_json("Data Scraping/data/population.json")

print(f"Data loaded - GDP: {len(gdp)}, Region: {len(region)}, Energy: {len(energy)}, CO2: {len(co2)}, Population: {len(population)}")

# Insert Benua
region_list = sorted(set(r['region'] for r in region))
region_map = {}
for r in region_list:
    cur.execute("INSERT INTO Benua (nama_benua) VALUES (%s)", (r,))
    region_map[r] = cur.lastrowid
print(f"Benua: {len(region_map)} baris")

# Insert Jenis_Energi
energy_list = ["Oil", "Gas", "Coal", "Renewable & Nuclear"]
energy_map = {}
for e in energy_list:
    cur.execute("INSERT INTO Jenis_Energi (nama_jenis) VALUES (%s)", (e,))
    energy_map[e] = cur.lastrowid
print(f"Jenis Energi: {len(energy_map)} baris")

# Insert Negara
regions = {r['country']: r['region'] for r in region}
countries = sorted(regions.keys())
countries_map = {}
for c in countries:
    id_region = region_map[regions[c]]
    cur.execute("INSERT INTO Negara (nama_negara, id_benua) VALUES (%s, %s)", (c, id_region))  # fix: pakai id_region, bukan region_id/region_name
    countries_map[c] = cur.lastrowid
print(f"Negara: {len(countries_map)} baris")

# Insert Tahun
for tahun in [2017, 2024]:
    cur.execute("INSERT INTO Tahun (tahun) VALUES (%s)", (tahun,))

# Insert Indikator_GDP
skips = 0
for g in gdp:
    id_country = countries_map.get(g['country'])
    if id_country is None:
        skips += 1
        continue
    cur.execute("""
        INSERT INTO Indikator_GDP (id_negara, tahun, nilai_gdp, persentase_pertumbuhan_gdp, gdp_per_capita, persentase_gdp_dunia, rank_gdp)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (id_country, g['tahun'], g['gdp_value'], g['gdp_growth_pct'], g['gdp_per_capita'], g['share_of_world_gdp_pct'], g['rank']))
print(f"Indikator GDP: {len(gdp) - skips} baris berhasil, {skips} baris dilewati")

# Insert Indikator_Populasi
skips = 0
for p in population:
    id_country = countries_map.get(p['country'])
    if id_country is None:
        skips += 1
        continue
    cur.execute("""
        INSERT INTO Indikator_Populasi 
        (id_negara, tahun, rank_populasi, jumlah_populasi, persentase_perubahan_tahunan, 
         perubahan_tahunan, migrasi_bersih, usia_median, tingkat_fertilitas, 
         kepadatan_penduduk, persentase_penduduk_urban, jumlah_penduduk_urban, persentase_populasi_dunia)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (id_country, p['tahun'], p['rank'], p['population'], p['yearly_pct_change'],
          p['yearly_change'], p['net_migrants'], p['median_age'], p['fertility_rate'],
          p['density_p_km2'], p['urban_pop_pct'], p['urban_population'], p['world_pop_share_pct']))
print(f"Indikator Populasi: {len(population) - skips} baris berhasil, {skips} baris dilewati")

# Insert Indikator_CO2
skips = 0
for c in co2:
    id_country = countries_map.get(c['country'])
    if id_country is None:
        skips += 1
        continue
    cur.execute("""
        INSERT INTO Indikator_CO2 
        (id_negara, tahun, rank_co2, emisi_co2, persentase_perubahan_setahun, emisi_co2_per_kapita, persentase_emisi_co2_dunia)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (id_country, c['tahun'], c['rank'], c['co2_emission_ton'], c['one_year_change_pct'], c['co2_per_capita_ton'], c['share_of_world_co2_pct']))
print(f"Indikator CO2: {len(co2) - skips} baris berhasil, {skips} baris dilewati")

# Insert Indikator_Energi
skips = 0
for e in energy:
    id_country = countries_map.get(e['country'])
    if id_country is None:
        skips += 1
        continue
    cur.execute("""
        INSERT INTO Indikator_Energi 
        (id_negara, tahun, rank_energi, konsumsi_energi_total, persentase_dunia, konsumsi_per_capita)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (id_country, e['tahun'], e['rank'], e['consumption_btu'], e['world_share_pct'], e['per_capita_btu']))
print(f"Indikator Energi: {len(energy) - skips} baris berhasil, {skips} baris dilewati")

# Insert Komposisi_Energi
count = 0
for e in energy:
    id_country = countries_map.get(e['country'])
    if id_country is None:
        continue

    types = [
        ('Oil', e.get('oil_btu'), e.get('oil_pct')),
        ('Gas', e.get('gas_btu'), e.get('gas_pct')),
        ('Coal', e.get('coal_btu'), e.get('coal_pct')),
        ('Renewable & Nuclear', e.get('renewable_btu'), e.get('renewable_pct')),
    ]

    for energy_type, btu, percentage in types:
        if btu is None:
            continue
        cur.execute("""
            INSERT INTO Komposisi_Energi (id_negara, tahun, id_jenis, jumlah_komposisi, persentase_konsumsi)
            VALUES (%s, %s, %s, %s, %s)
        """, (id_country, e['tahun'], energy_map[energy_type], btu, percentage))
        count += 1
print(f"Komposisi Energi: {count} baris berhasil")

conn.commit()
cur.close()
conn.close()
print("Data berhasil dimasukkan ke database IndikatorNegara")