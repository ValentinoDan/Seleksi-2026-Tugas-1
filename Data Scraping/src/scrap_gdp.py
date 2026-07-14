from utils import fetch, remove_sign, remove_pct
import json, os

# ambil data GDP tiap baris
def parse_gdp(row):
    cells = row.find_all(['th', 'td'])
    if len(cells) < 7: # min 7 col
        return None
    
    rank = cells[0].get_text(strip=True)
    country = cells[1].get_text(strip=True)
    gdp = cells[3].get_text(strip=True) # nilai GDP full
    gdp_growth = cells[4].get_text(strip=True)
    gdp_per_capita = cells[5].get_text(strip=True)
    share_of_world = cells[6].get_text(strip=True)
    
    return {
        "rank": rank,
        "country": country,
        "gdp_value": gdp,
        "gdp_growth": gdp_growth,
        "gdp_per_capita": gdp_per_capita,
        "share_of_world_gdp": share_of_world
    }

def clean_gdp(data):
    return {
        "rank": int(data['rank']),
        "country": data['country'],
        "tahun": 2024,
        "gdp_value": remove_sign(data.get("gdp_value")),
        "gdp_growth_pct": remove_pct(data.get("gdp_growth")),
        "gdp_per_capita": remove_sign(data.get("gdp_per_capita")),
        "share_of_world_gdp_pct": remove_pct(data.get("share_of_world_gdp"))
    }

soup = fetch("https://www.worldometers.info/gdp/gdp-by-country/")
tables = soup.find_all("table")

gdp_data = []

# tables[1] pake data World Bank
rows = tables[1].find_all('tr')[1:] # skip header
for row in rows:
    parsed = parse_gdp(row)
    if parsed:
        gdp_data.append(parsed)

gdp_cleaned = [clean_gdp(d) for d in gdp_data]

with open(os.path.join("Data Scraping", "data", "gdp.json"), "w", encoding="utf-8") as f:
    json.dump(gdp_cleaned, f, indent=4, ensure_ascii=False)

