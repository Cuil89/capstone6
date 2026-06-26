from pathlib import Path
import pandas as pd
import json

# ==========================
# Folder
# ==========================

BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = BASE_DIR / "output"

OUTPUT_DIR.mkdir(exist_ok=True)

# ==========================
# Load Dataset
# ==========================

obat = pd.read_csv(BASE_DIR / "processed_data_obat.csv")
penyakit = pd.read_csv(BASE_DIR / "processed_data_penyakit.csv")

print("Dataset Indonesia berhasil dibaca.")

knowledge = []

# ==========================
# DATA OBAT
# ==========================

for idx, row in obat.iterrows():

    text = f"""
Nama Obat:
{row['Nama Obat']}

Deskripsi:
{row['Deskripsi Obat']}

Peringatan:
{row['Peringatan Sebelum Mengonsumsi Obat']}

Dosis:
{row['Dosis dan Aturan Pakai Obat']}

Efek Samping:
{row['Efek Samping dan Bahaya Obat']}

Digunakan Untuk:
{row['Penyakit sesuai dengan obat']}

Merek Dagang:
{row['Merek Dagang']}
"""

    knowledge.append({
        "id": f"indo_drug_{idx}",
        "source": "Indonesian Pharmaceutical",
        "type": "drug",
        "title": row["Nama Obat"],
        "category": row["Penyakit sesuai dengan obat"],
        "text": text.strip()
    })

# ==========================
# DATA PENYAKIT
# ==========================

for idx, row in penyakit.iterrows():

    text = f"""
Nama Penyakit:
{row['Nama Penyakit']}

Deskripsi:
{row['Deskripsi Penyakit']}

Penyebab:
{row['Penyebab Penyakit']}

Gejala:
{row['Gejala Penyakit']}
"""

    knowledge.append({
        "id": f"indo_disease_{idx}",
        "source": "Indonesian Pharmaceutical",
        "type": "disease",
        "title": row["Nama Penyakit"],
        "category": "Disease",
        "text": text.strip()
    })

# ==========================
# Save
# ==========================

output = OUTPUT_DIR / "indonesia.json"

with open(output, "w", encoding="utf-8") as f:
    json.dump(
        knowledge,
        f,
        ensure_ascii=False,
        indent=2
    )

print("="*60)
print("Total Knowledge :", len(knowledge))
print("Saved :", output)