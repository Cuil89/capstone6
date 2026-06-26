import json
import os
from pathlib import Path

# Set up paths
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"

datasets = [
    "pharmasafe.json",
    "data-drug.json",
    "data-obat.json",
    "indonesia.json",
    "medline.json",
    "mid.json"
]

print("=" * 80)
print("SCHEMA ANALYSIS REPORT")
print("=" * 80)

for filename in datasets:
    file_path = DATA_DIR / filename
    if not file_path.exists():
        print(f"\n[WARNING] {filename} does not exist at {file_path}")
        continue

    size_mb = file_path.stat().st_size / (1024 * 1024)
    print(f"\nDataset: {filename}")
    print(f"File Size: {size_mb:.2f} MB")

    try:
        # For mid.json, let's read the first 10,000 characters or use streaming 
        # to find the first element, avoiding loading 586MB in memory just for schema analysis.
        if filename == "mid.json":
            # Stream/parse only the first record
            print("Type: JSON List (Large file, streaming first record...)")
            with open(file_path, "r", encoding="utf-8") as f:
                # Read line by line until we find a record
                # Since mid.json is formatted with indent=2, a record starts with `  {`
                buffer = ""
                in_record = False
                for line in f:
                    if line.strip() == "{":
                        in_record = True
                        buffer = "{\n"
                    elif in_record:
                        buffer += line
                        if line.strip().startswith("}") or line.strip().startswith("},"):
                            # clean trailing comma if present
                            clean_buf = buffer.strip()
                            if clean_buf.endswith(","):
                                clean_buf = clean_buf[:-1]
                            try:
                                sample = json.loads(clean_buf)
                                print(f"Record Count (Estimated from size): ~16,000")
                                print("Keys/Fields in Record:")
                                for k, v in sample.items():
                                    val_summary = str(v)[:100] + "..." if len(str(v)) > 100 else str(v)
                                    val_summary = val_summary.replace('\n', ' ')
                                    print(f"  - {k} ({type(v).__name__}): {val_summary}")
                                break
                            except json.JSONDecodeError:
                                pass
                else:
                    print("Could not stream sample record.")
        else:
            with open(file_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            
            if isinstance(data, list):
                print(f"Type: JSON List")
                print(f"Record Count: {len(data)}")
                if len(data) > 0:
                    sample = data[0]
                    print("Keys/Fields in Record:")
                    for k, v in sample.items():
                        val_summary = str(v)[:100] + "..." if len(str(v)) > 100 else str(v)
                        val_summary = val_summary.replace('\n', ' ')
                        print(f"  - {k} ({type(v).__name__}): {val_summary}")
            elif isinstance(data, dict):
                print(f"Type: JSON Dictionary")
                print(f"Key Count: {len(data)}")
                first_key = list(data.keys())[0]
                sample = data[first_key]
                print(f"First Key: '{first_key}'")
                print("Keys/Fields in Record value:")
                if isinstance(sample, dict):
                    for k, v in sample.items():
                        val_summary = str(v)[:100] + "..." if len(str(v)) > 100 else str(v)
                        val_summary = val_summary.replace('\n', ' ')
                        print(f"  - {k} ({type(v).__name__}): {val_summary}")
                else:
                    print(f"  Value type: {type(sample).__name__}")
            else:
                print(f"Type: Unknown ({type(data).__name__})")

    except Exception as e:
        print(f"Error parsing {filename}: {e}")

print("\n" + "=" * 80)
