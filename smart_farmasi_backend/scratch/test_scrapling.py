"""
Test Scrapling Adaptor (pure HTML parser - tidak butuh browser/curl_cffi)
untuk parse WHO, dan test CDC RSS + ECDC API.
"""
import sys, requests, re, xml.etree.ElementTree as ET
sys.path.insert(0, '.')

from scrapling.parser import Adaptor

print("=" * 60)
print("TEST 1: Scrapling Adaptor - WHO DON API response (JSON->HTML)")
print("=" * 60)

# Ambil dari WHO API, lalu parse Summary yang mengandung HTML
headers = {'User-Agent': 'Mozilla/5.0', 'Accept': 'application/json'}
r = requests.get('https://www.who.int/api/news/diseaseoutbreaknews', headers=headers, timeout=20)
data = r.json()
items = sorted(data.get('value', []), key=lambda x: x.get('PublicationDateAndTime', ''), reverse=True)

print(f"WHO DON: {len(items)} items total")
for item in items[:5]:
    title = item.get('Title', '')
    date  = item.get('PublicationDateAndTime', '')[:10]
    url   = 'https://www.who.int' + item.get('ItemDefaultUrl', '')
    
    # Parse HTML summary dengan Scrapling Adaptor
    raw_summary = (
        item.get('Summary') or 
        item.get('Overview') or 
        item.get('Assessment') or 
        ''
    )
    if raw_summary and '<' in raw_summary:
        page = Adaptor(raw_summary)
        summary = page.get_all_text(ignore_tags=['script','style'], separator=' ').strip()[:200]
    else:
        summary = raw_summary[:200]
    
    print(f"\n[{date}] {title}")
    print(f"  URL: {url}")
    print(f"  Summary: {summary[:150]}")

print("\n" + "=" * 60)
print("TEST 2: Scrapling Adaptor - WHO Outbreak page scraping")
print("=" * 60)

try:
    r2 = requests.get(
        'https://www.who.int/emergencies/disease-outbreak-news',
        headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'},
        timeout=20
    )
    print(f"HTTP Status: {r2.status_code}")
    page2 = Adaptor(r2.text, url=r2.url)
    
    # Find DON article links
    don_links = [l for l in page2.css('a[href]') if 'DON' in (l.attrib.get('href') or '')]
    print(f"DON links in page: {len(don_links)}")
    for lnk in don_links[:5]:
        href = lnk.attrib.get('href', '')
        txt = lnk.text.strip()[:60] if lnk.text else ''
        print(f"  {href} | {txt}")
    
    # Extract any paragraph text  
    all_text = page2.get_all_text(ignore_tags=['script','style','nav','header','footer'], separator='\n')
    lines = [l.strip() for l in all_text.split('\n') if len(l.strip()) > 30]
    print(f"Content lines extracted: {len(lines)}")
    for line in lines[:5]:
        print(f"  > {line[:100]}")
        
except Exception as e:
    print(f"WHO page scrape error: {e}")

print("\n" + "=" * 60)
print("TEST 3: CDC RSS Feed")
print("=" * 60)

try:
    r3 = requests.get('https://tools.cdc.gov/api/v2/resources/media/316422.rss', 
                      headers={'User-Agent': 'Mozilla/5.0'}, timeout=20)
    print(f"CDC RSS Status: {r3.status_code}")
    root = ET.fromstring(r3.content)
    channel = root.find('channel')
    items_cdc = channel.findall('item') if channel else []
    print(f"CDC RSS items: {len(items_cdc)}")
    for item in items_cdc[:3]:
        title = item.findtext('title', '')
        link  = item.findtext('link', '')
        desc  = item.findtext('description', '')[:100]
        date  = item.findtext('pubDate', '')[:30]
        print(f"  [{date}] {title}")
        print(f"    {link}")
        print(f"    {desc}")
        print()
except Exception as e:
    print(f"CDC RSS error: {e}")

print("\n" + "=" * 60)
print("TEST 4: ECDC (European CDC) RSS Feed")
print("=" * 60)

try:
    r4 = requests.get(
        'https://www.ecdc.europa.eu/en/rss.xml',
        headers={'User-Agent': 'Mozilla/5.0'}, timeout=20
    )
    print(f"ECDC RSS Status: {r4.status_code}")
    root4 = ET.fromstring(r4.content)
    chan4 = root4.find('channel')
    items4 = chan4.findall('item') if chan4 else []
    print(f"ECDC items: {len(items4)}")
    for it in items4[:3]:
        print(f"  [{it.findtext('pubDate','')[:20]}] {it.findtext('title','')[:80]}")
except Exception as e:
    print(f"ECDC error: {e}")

print("\nAll tests done!")
