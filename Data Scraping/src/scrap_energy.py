from utils import fetch, remove_sign, remove_pct, remove_sign_float, get_country
import json, os, re, time

# ambil data energi tiap baris
def parse_energy(row):
    cells = row.find_all(['th', 'td'])
    if len(cells) < 5: # min 5 col
        return None
    
    rank = cells[0].get_text(strip=True)
    country_cell = cells[1]
    url = country_cell.find('a')['href'] if country_cell.find('a') else None
    country = get_country(country_cell)
    consumption = cells[2].get_text(strip=True) # konsumsi energi dalam BTU
    world_share_pct = cells[3].get_text(strip=True)
    per_capita = cells[4].get_text(strip=True)
    
    return {
        "rank": rank,
        "country": country,
        "url": url,
        "consumption": consumption,
        "world_share_pct": world_share_pct,
        "per_capita": per_capita
    }

def parse_energy_detail(soup):
    result = {k: None for k in [
        'oil_btu', 'oil_pct', 'gas_btu', 'gas_pct', 'coal_btu', 'coal_pct',
        'fossil_btu', 'fossil_pct', 'renewable_btu', 'renewable_pct'
    ]}
    
    # cari oil, gas, coal
    for div in soup.find_all('div', class_='text-lg'):
        link = div.find('a')
        span = div.find('span', class_='font-bold')
        if not link or not span:
            continue
        
        label = link.get_text(strip=True).lower()
        text = span.get_text(strip=True)
        btu_match = re.search(r'([\d,]+)\s*BTU', text)
        pct_match = re.search(r'\((\d+)%\)', text)
        btu = int(btu_match.group(1).replace(',', '')) if btu_match else None
        pct = int(pct_match.group(1)) if pct_match else None
        
        for key in ['oil', 'gas', 'coal']:
            if key in label:
                result[f'{key}_btu'], result[f'{key}_pct'] = btu, pct
    
    # cari fossil dan renewable
    pct_divs = soup.find_all('div', class_=lambda c: c and 'text-zinc-400' in c and 'font-bold' in c and 'text-2xl' in c)
    btu_divs = soup.find_all('div', class_=lambda c: c and 'text-center' in c and 'text-2xl' in c and 'font-bold' in c and 'text-zinc-400' not in c)
    
    for pct_div, btu_div in zip(pct_divs, btu_divs):
        heading = pct_div.find_previous(string=lambda t: t and ('Non Renewable' in t or 'Renewable and Nuclear' in t))
        if not heading:
            continue
        key = 'fossil' if 'Non Renewable' in heading else 'renewable'
        result[f'{key}_pct'] = int(pct_div.get_text(strip=True).replace('%', ''))
        result[f'{key}_btu'] = int(btu_div.get_text(strip=True).replace('BTU', '').replace(',', ''))
    
    return result

soup = fetch("https://www.worldometers.info/energy/")
tables = soup.find_all("table")

url_data = []

rows = tables[0].find_all('tr')[1:]  # skip header
for row in rows:
    parsed = parse_energy(row)
    if parsed:
        url_data.append(parsed)

print("Total Negara:", len(url_data))

energy_data = []
for i, item in enumerate(url_data):
    if not item['url']:
        continue
    
    soup_url = fetch("https://www.worldometers.info" + item['url'])
    result = parse_energy_detail(soup_url)
    
    record = {
        "rank": int(item['rank']),
        "country": item['country'],
        "tahun": 2017,
        "consumption_btu": remove_sign(item.get("consumption")),
        "world_share_pct": remove_pct(item.get("world_share_pct")),
        "per_capita_btu": remove_sign(item.get("per_capita")),
        **result
    }
    
    energy_data.append(record)
    time.sleep(4) # 15 request / menit

with open(os.path.join("Data Scraping", "data", "energy.json"), "w", encoding="utf-8") as f:
    json.dump(energy_data, f, indent=4, ensure_ascii=False)