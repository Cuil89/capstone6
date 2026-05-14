import requests

headers = {'User-Agent': 'Mozilla/5.0', 'Accept': 'application/json'}
r = requests.get('https://www.who.int/api/news/diseaseoutbreaknews', headers=headers, 
    params={'sf_culture': 'en'}, timeout=15)
data = r.json()
items = data.get('value', [])
# Sort by date descending in Python
items_sorted = sorted(items, key=lambda x: x.get('PublicationDateAndTime', ''), reverse=True)
print(f'Total items: {len(items_sorted)}')
for item in items_sorted[:8]:
    date = item.get('PublicationDateAndTime', '')[:10]
    title = item.get('Title', '')[:80]
    url = item.get('ItemDefaultUrl', '')
    summ = (item.get('Summary') or item.get('Overview') or item.get('Assessment') or '')[:100]
    print(f"Date: {date} | Title: {title}")
    print(f"  URL: {url} | Summary: {summ}")
    print()
