from pathlib import Path
import pandas as pd
import json

BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = BASE_DIR / "output"

OUTPUT_DIR.mkdir(exist_ok=True)

df = pd.read_excel(BASE_DIR / "MID.xlsx")

print("MID berhasil dibaca.")

knowledge = []

for idx, row in df.iterrows():

    text = f"""
Nama Obat:
{row['Name']}

Kegunaan:
{row['ProductUses']}

Manfaat:
{row['ProductBenefits']}

Efek Samping:
{row['SideEffect']}

Cara Pakai:
{row['HowToUse']}

Safety Advice:
{row['SafetyAdvice']}

Therapeutic Class:
{row['Therapeutic_Class']}

Action Class:
{row['Action_Class']}
"""

    knowledge.append({
        "id": f"mid_{idx}",
        "source": "MID",
        "type": "drug",
        "title": row["Name"],
        "category": row["Therapeutic_Class"],
        "text": text.strip()
    })

output = OUTPUT_DIR / "mid.json"

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