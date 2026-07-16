from utils import fetch, get_country
import json, os, time

# ambil nama benua dan url
def parse_region(row):
    cells = row.find_all(['th', 'td'])
    if len(cells) < 2:
        return None
    
    region_cell = cells[1]
    region = region_cell.get_text(strip=True)
    url = region_cell.find('a')['href'] if region_cell.find('a') else None
    
    return {
        "region": region, 
        "url": url
    }

# ambil negara-negara dalam suatu benua
def get_countries(url):
    url = "https://www.worldometers.info" + url

    # hapus "/" paling kanan, trus ganti "/population/" ama "/population/countries-in-" + "-by-population/"
    country_url = url.rstrip('/').replace("/population/", "/population/countries-in-") + "-by-population/"

    soup = fetch(country_url)
    tables = soup.find_all("table")
    if not tables:
        return []
    
    countries = []
    for row in tables[0].find_all('tr')[1:]:
        cells = row.find_all(['th', 'td'])
        if len(cells) < 2:
            continue
        countries.append(get_country(cells[1]))
    
    return countries

soup = fetch("https://www.worldometers.info/world-population/population-by-region/")
tables = soup.find_all("table")

regions = []
for row in tables[0].find_all('tr')[1:]:
    parsed = parse_region(row)
    if parsed:
        regions.append(parsed)

print(f"Total Benua: {len(regions)}")

country_region = []

for region in regions:
    if not region['url']:
        continue
    
    countries = get_countries(region['url'])
    
    for country in countries:
        country_region.append({
            "country": country, 
            "region": region['region']
        })
    
    time.sleep(4) # 15 request / menit

with open(os.path.join("Data Scraping", "data", "region.json"), "w", encoding="utf-8") as f:
    json.dump(country_region, f, indent=4, ensure_ascii=False)