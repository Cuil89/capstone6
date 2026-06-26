from pathlib import Path
import pandas as pd
import json

# ==========================
# Folder
# ==========================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR
OUTPUT_DIR = BASE_DIR / "output"

OUTPUT_DIR.mkdir(exist_ok=True)

# ==========================
# Load Dataset
# ==========================

obat = pd.read_csv(DATA_DIR/"data-obat.csv", sep="|", engine="python")
dosis = pd.read_csv(DATA_DIR/"data-dosis.csv", sep="|", engine="python")
efek = pd.read_csv(DATA_DIR/"data-efeksamping.csv", sep="|", engine="python")
kontra = pd.read_csv(DATA_DIR/"data-kontraindikasi.csv", sep="|", engine="python")
interaksi = pd.read_csv(DATA_DIR/"data-interaksiobat.csv", sep="|", engine="python")
komposisi = pd.read_csv(DATA_DIR/"data-komposisi.csv", sep="|", engine="python")
harga = pd.read_csv(DATA_DIR/"data-harga.csv", sep="|", engine="python")
aturan = pd.read_csv(DATA_DIR/"data-aturan.csv", sep="|", engine="python")
jangka = pd.read_csv(DATA_DIR/"data-jangkawaktupenggunaan.csv", sep="|", engine="python")

print("Dataset berhasil dibaca.")

# ==========================
# Helper
# ==========================

def gabung(df, kolom):
    return (
        df.groupby("id_obat")[kolom]
        .apply(lambda x: "\n".join(x.astype(str).dropna().unique()))
        .to_dict()
    )

# ==========================
# Dictionary
# ==========================

dict_dosis = gabung(dosis, "dosis")
dict_efek = gabung(efek, "efek_samping")
dict_kontra = gabung(kontra, "kontra_indikasi")
dict_interaksi = gabung(interaksi, "interaksi_obat")

dict_aturan = gabung(aturan, "aturan_pemakaian")
dict_jangka = gabung(jangka, "jangka_waktu_penggunaan")

dict_harga = (
    harga.groupby("id_obat")
    .apply(lambda x:
        "\n".join(
            f"{r.satuan}: Rp {r.harga}"
            for _, r in x.iterrows()
        )
    )
    .to_dict()
)

dict_komposisi = (
    komposisi.groupby("id_obat")
    .apply(lambda x:
        "\n".join(
            f"{r.nama} {r.jumlah} {r.satuan}"
            for _, r in x.iterrows()
        )
    )
    .to_dict()
)

# ==========================
# Build Knowledge
# ==========================

knowledge = []

for _, row in obat.iterrows():

    idx = row["id"]

    text = f"""
Nama Obat:
{row['nama_obat']}

Kategori Penyakit:
{row['kategori_penyakit']}

Indikasi:
{row['indikasi']}

Dosis:
{dict_dosis.get(idx,'-')}

Efek Samping:
{dict_efek.get(idx,'-')}

Kontraindikasi:
{dict_kontra.get(idx,'-')}

Interaksi Obat:
{dict_interaksi.get(idx,'-')}

Komposisi:
{dict_komposisi.get(idx,'-')}

Harga:
{dict_harga.get(idx,'-')}

Aturan Pakai:
{dict_aturan.get(idx,'-')}

Jangka Penggunaan:
{dict_jangka.get(idx,'-')}
"""

    knowledge.append({
        "source":"Pharma-safe",
        "title":row["nama_obat"],
        "category":row["kategori_penyakit"],
        "text":text.strip()
    })


# ==========================
# Save JSON
# ==========================

output = OUTPUT_DIR / "pharmasafe.json"

with open(output,"w",encoding="utf-8") as f:
    json.dump(
        knowledge,
        f,
        ensure_ascii=False,
        indent=2
    )

print("="*60)
print("Total Knowledge :",len(knowledge))
print("Saved :",output)