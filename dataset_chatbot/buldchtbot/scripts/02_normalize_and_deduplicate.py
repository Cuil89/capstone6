import json
from pathlib import Path

# Set up paths
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
OUTPUT_DIR = BASE_DIR / "output"
OUTPUT_DIR.mkdir(exist_ok=True)

# normalized_dict maps title.strip().lower() -> record_dict
normalized_dict = {}

def process_record(title, text, source, category, record_id):
    title = title.strip()
    if not title:
        return
    text = text.strip()
    if not text:
        return
        
    title_key = title.lower()
    
    new_record = {
        "id": record_id,
        "source": source,
        "title": title,
        "category": category,
        "text": text
    }
    
    if title_key not in normalized_dict:
        normalized_dict[title_key] = new_record
    else:
        # Deduplication based on title/name: keep the one with the richer/longer description
        existing_record = normalized_dict[title_key]
        if len(text) > len(existing_record["text"]):
            normalized_dict[title_key] = new_record

# 1. Process pharmasafe.json
pharmasafe_path = DATA_DIR / "pharmasafe.json"
if pharmasafe_path.exists():
    with open(pharmasafe_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    for idx, item in enumerate(data):
        process_record(
            title=item.get("title", ""),
            text=item.get("text", ""),
            source=item.get("source", "Pharma-safe"),
            category=item.get("category", ""),
            record_id=f"pharmasafe_{idx}"
        )
    print(f"Processed pharmasafe.json. Unique titles so far: {len(normalized_dict)}")

# 2. Process data-drug.json
data_drug_path = DATA_DIR / "data-drug.json"
if data_drug_path.exists():
    with open(data_drug_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    for idx, item in enumerate(data):
        name = item.get("name", "")
        category = item.get("category", "")
        indication = item.get("indication", "")
        
        # Helper to format list of dicts
        def format_list(lst, key):
            if not isinstance(lst, list):
                return str(lst) if lst else "-"
            parts = []
            for d in lst:
                if isinstance(d, dict):
                    parts.extend(f"{k}: {v}" for k, v in d.items() if v)
                else:
                    parts.append(str(d))
            return " | ".join(parts) if parts else "-"

        price = format_list(item.get("price"), "price")
        composition = format_list(item.get("composition"), "composition")
        side_effect = format_list(item.get("side_effect"), "side_effect")
        drug_interaction = format_list(item.get("drug_interaction"), "drug_interaction")
        contra_indication = format_list(item.get("contra_indication"), "contra_indication")
        dose = format_list(item.get("dose"), "dose")
        rule = format_list(item.get("rule"), "rule")
        usage_periode = format_list(item.get("usage_periode"), "usage_periode")

        text = f"""
Name: {name}
Category: {category}
Indication: {indication}
Price: {price}
Composition: {composition}
Side Effects: {side_effect}
Drug Interaction: {drug_interaction}
Contra-indication: {contra_indication}
Dose: {dose}
Rules: {rule}
Usage Period: {usage_periode}
""".strip()

        process_record(
            title=name,
            text=text,
            source="data-drug",
            category=category,
            record_id=f"data_drug_{item.get('id', idx)}"
        )
    print(f"Processed data-drug.json. Unique titles so far: {len(normalized_dict)}")

# 3. Process data-obat.json
data_obat_path = DATA_DIR / "data-obat.json"
if data_obat_path.exists():
    with open(data_obat_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    for idx, item in enumerate(data):
        nama = item.get("nama_obat", "")
        category = item.get("kategori_penyakit", "")
        
        def format_obat_list(lst):
            if not isinstance(lst, list):
                return str(lst) if lst else "-"
            parts = []
            for d in lst:
                if isinstance(d, dict):
                    parts.extend(f"{k}: {v}" for k, v in d.items() if v)
                elif isinstance(d, str):
                    parts.append(d)
            return " | ".join(parts) if parts else "-"

        harga = format_obat_list(item.get("harga"))
        indikasi = format_obat_list(item.get("indikasi"))
        komposisi = format_obat_list(item.get("komposisi"))
        efek_samping = format_obat_list(item.get("efek_samping"))
        kontra_indikasi = format_obat_list(item.get("kontra_indikasi"))
        interaksi_obat = format_obat_list(item.get("interaksi_obat"))
        
        # Dosis might be a dict or string
        dosis_val = item.get("dosis")
        if isinstance(dosis_val, dict):
            dosis = " | ".join(f"{k}: {v}" for k, v in dosis_val.items() if v)
        else:
            dosis = str(dosis_val) if dosis_val else "-"
            
        aturan = format_obat_list(item.get("aturan_pakai"))
        jangka = format_obat_list(item.get("jangka_waktu_penggunaan"))

        text = f"""
Nama Obat: {nama}
Kategori: {category}
Harga: {harga}
Indikasi: {indikasi}
Komposisi: {komposisi}
Efek Samping: {efek_samping}
Kontraindikasi: {kontra_indikasi}
Interaksi Obat: {interaksi_obat}
Dosis: {dosis}
Aturan Pakai: {aturan}
Jangka Waktu Penggunaan: {jangka}
""".strip()

        process_record(
            title=nama,
            text=text,
            source="data-obat",
            category=category,
            record_id=f"data_obat_{idx}"
        )
    print(f"Processed data-obat.json. Unique titles so far: {len(normalized_dict)}")

# 4. Process indonesia.json
indonesia_path = DATA_DIR / "indonesia.json"
if indonesia_path.exists():
    with open(indonesia_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    for idx, item in enumerate(data):
        process_record(
            title=item.get("title", ""),
            text=item.get("text", ""),
            source=item.get("source", "Indonesian Pharmaceutical"),
            category=item.get("category", ""),
            record_id=item.get("id", f"indo_{idx}")
        )
    print(f"Processed indonesia.json. Unique titles so far: {len(normalized_dict)}")

# 5. Process medline.json
medline_path = DATA_DIR / "medline.json"
if medline_path.exists():
    with open(medline_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    for idx, item in enumerate(data):
        process_record(
            title=item.get("title", ""),
            text=item.get("text", ""),
            source=item.get("source", "MedlinePlus"),
            category=item.get("category", ""),
            record_id=item.get("id", f"medline_{idx}")
        )
    print(f"Processed medline.json. Unique titles so far: {len(normalized_dict)}")

# Convert dict to list
normalized_data = list(normalized_dict.values())

# Save to output/normalized_knowledge.json
output_file = OUTPUT_DIR / "normalized_knowledge.json"
with open(output_file, "w", encoding="utf-8") as f:
    json.dump(normalized_data, f, ensure_ascii=False, indent=2)

print("\n" + "=" * 80)
print(f"Normalization & Deduplication Complete!")
print(f"Saved {len(normalized_data)} unique title records to: {output_file}")
print("=" * 80)
