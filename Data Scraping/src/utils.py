import requests
from bs4 import BeautifulSoup

headers = {"User-Agent": "basdat-scraper-assignment (contact: 13524104@std.stei.itb.ac.id)"}

# fetch url
def fetch(url):
    response = requests.get(url, headers=headers)
    return BeautifulSoup(response.content, "html.parser")

# remove $ dan ubah ke int
def remove_sign(text):
    if not text:
        return None
    text = text.replace("$", "").replace(",", "").replace("−", "-").strip()
    try:
        return int(text)
    except ValueError:
        return None
    
# remove % dan ubah ke float
def remove_pct(text):
    if not text:
        return None
    text = text.replace("%", "").replace("−", "-").strip()
    try:
        return float(text)
    except ValueError:
        return None
    
# remove $ dan ubah ke float
def remove_sign_float(text):
    if not text:
        return None
    text = text.replace(",", "").replace("−", "-").strip()
    try:
        return float(text)
    except ValueError:
        return None
    
# ambil negara pertama aja (ada beberapa kasus pada suatu rank memiliki beberapa negara)
def get_country(cell):
    link = cell.find('a', title=True)
    if link:
        return link['title']
    return cell.get_text(strip=True)