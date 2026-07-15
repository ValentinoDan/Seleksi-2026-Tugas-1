from utils import fetch, remove_sign, remove_pct, remove_sign_float, get_country    
import json, os, time

# ambil data populasi tiap baris
def parse_population(row):
    cells = row.find_all(['th', 'td'])
    if len(cells) < 12: # min 12 col
        return None
    
    rank = cells[0].get_text(strip=True)
    country_cell = cells[1]
    url = country_cell.find('a')['href'] if country_cell.find('a') else None
    country = get_country(country_cell)
    
    return {
        "rank": rank,
        "country": country,
        "tahun": 2024,
        "url": url,
    }

def parse_population_country(row):
    cells = row.find_all(['th', 'td'])
    if len(cells) < 13: # min 13 col
        return None
    
    population = cells[1].get_text(strip=True)
    yearly_pct_change = cells[2].get_text(strip=True)
    yearly_change = cells[3].get_text(strip=True)
    net_migrants = cells[4].get_text(strip=True)
    median_age = cells[5].get_text(strip=True)
    fertility_rate = cells[6].get_text(strip=True)
    density_p_km2 = cells[7].get_text(strip=True)
    urban_pop_pct = cells[8].get_text(strip=True)
    urban_population = cells[9].get_text(strip=True)
    world_pop_share = cells[10].get_text(strip=True)
    
    return {
        "population": population,
        "yearly_pct_change": yearly_pct_change,
        "yearly_change": yearly_change,
        "net_migrants": net_migrants,
        "median_age": median_age,
        "fertility_rate": fertility_rate,
        "density_p_km2": density_p_km2,
        "urban_pop_pct": urban_pop_pct,
        "urban_population": urban_population,
        "world_pop_share": world_pop_share
    }

def clean_population(data):
    return {
        "population": remove_sign(data.get("population")),
        "yearly_pct_change": remove_pct(data.get("yearly_pct_change")),
        "yearly_change": remove_sign(data.get("yearly_change")),
        "net_migrants": remove_sign(data.get("net_migrants")),
        "median_age": remove_sign_float(data.get("median_age")),
        "fertility_rate": remove_sign_float(data.get("fertility_rate")),
        "density_p_km2": remove_sign(data.get("density_p_km2")),
        "urban_pop_pct": remove_pct(data.get("urban_pop_pct")),
        "urban_population": remove_sign(data.get("urban_population")),
        "world_pop_share_pct": remove_pct(data.get("world_pop_share"))
    }

# ambil data dari tiap negara dgn url yang beda2
def get_data(url):
    soup_detail = fetch("https://www.worldometers.info" + url)
    tables = soup_detail.find_all("table")
    if not tables:
        return None
    
    for row in tables[0].find_all('tr'):
        cells = row.find_all(['th', 'td'])
        if cells and cells[0].get_text(strip=True) == "2024":
            return parse_population_country(row)
    return None

soup = fetch("https://www.worldometers.info/world-population/population-by-country//")
tables = soup.find_all("table")

url_data = []

rows = tables[0].find_all('tr')[1:] # skip header
for row in rows:
    parsed = parse_population(row)
    if parsed:
        url_data.append(parsed)

print("Total Negara:", len(url_data))

population_data = []

for i, item in enumerate(url_data):
    if not item['url']:
        continue
    
    data = get_data(item['url'])
    if data is None:
        print("Data tidak ada untuk negara:", item['country'])
        continue
    
    cleaned = clean_population(data)
    record = {
        "rank": int(item['rank']),
        "country": item['country'],
        "tahun": int(item['tahun']),
        **cleaned
    }

    population_data.append(record)
    time.sleep(4) # 15 request / menit

with open(os.path.join("Data Scraping", "data", "population.json"), "w", encoding="utf-8") as f:
    json.dump(population_data, f, indent=4, ensure_ascii=False)