from utils import fetch, remove_sign, remove_pct, remove_sign_float, get_country
import json, os

# ambil data CO2 tiap baris
def parse_co2(row):
    cells = row.find_all(['th', 'td'])
    if len(cells) < 6: # min 6 col
        return None
    
    rank = cells[0].get_text(strip=True)
    country = get_country(cells[1])
    co2_emission = cells[2].get_text(strip=True) # kadar CO2 dalam ton
    one_year_change_pct = cells[3].get_text(strip=True)
    co2_per_capita = cells[4].get_text(strip=True) # dalam ton
    share_of_world_pct = cells[5].get_text(strip=True)
    
    return {
        "rank": rank,
        "country": country,
        "co2_emission": co2_emission,
        "one_year_change_pct": one_year_change_pct,
        "co2_per_capita": co2_per_capita,
        "share_of_world_pct": share_of_world_pct
    }

def clean_co2(data):
    return {
        "rank": int(data['rank']),
        "country": data['country'],
        "tahun": 2024,
        "co2_emission_ton": remove_sign(data.get("co2_emission")),
        "one_year_change_pct": remove_pct(data.get("one_year_change_pct")),
        "co2_per_capita_ton": remove_sign_float(data.get("co2_per_capita")),
        "share_of_world_co2_pct": remove_pct(data.get("share_of_world_pct"))
    }

soup = fetch("https://www.worldometers.info/co2-emissions/co2-emissions-by-country/")
tables = soup.find_all("table")

co2_data = []

rows = tables[0].find_all('tr')[1:]  # skip header
for row in rows:
    parsed = parse_co2(row)
    if parsed:
        co2_data.append(parsed)

co2_cleaned = [clean_co2(d) for d in co2_data]

with open(os.path.join("Data Scraping", "data", "co2.json"), "w", encoding="utf-8") as f:
    json.dump(co2_cleaned, f, indent=4, ensure_ascii=False)