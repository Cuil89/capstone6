import json
from pathlib import Path
import numpy as np
import faiss
import time
from datetime import datetime

# Set up paths
BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = BASE_DIR / "output"

def main():
    embeddings_file = OUTPUT_DIR / "embeddings.npy"
    if not embeddings_file.exists():
        print(f"Error: embeddings.npy not found at {embeddings_file}. Please run script 04 first.")
        return

    # Determine which metadata file to load (subset if limit was used, else full)
    subset_file = OUTPUT_DIR / "normalized_knowledge_subset.json"
    full_file = OUTPUT_DIR / "normalized_knowledge.json"
    
    metadata_file_to_use = subset_file if subset_file.exists() else full_file
    if not metadata_file_to_use.exists():
        print(f"Error: Normalized knowledge metadata file not found. Please run scripts 02/03 first.")
        return

    print(f"Loading embeddings from {embeddings_file}...")
    embeddings = np.load(embeddings_file).astype('float32')
    print(f"Loaded embeddings with shape: {embeddings.shape}")

    print(f"Loading metadata from {metadata_file_to_use}...")
    with open(metadata_file_to_use, "r", encoding="utf-8") as f:
        knowledge = json.load(f)

    if len(knowledge) != len(embeddings):
        print(f"[WARNING] Length mismatch! Metadata has {len(knowledge)} items, but embeddings has {len(embeddings)} items.")
        # Align lengths
        min_len = min(len(knowledge), len(embeddings))
        knowledge = knowledge[:min_len]
        embeddings = embeddings[:min_len]

    dimension = embeddings.shape[1]
    print(f"Embedding dimension: {dimension}")

    # 1. Build Flat L2 Index
    print("Building Flat L2 Index (exact search)...")
    start_time = time.time()
    index_flat = faiss.IndexFlatL2(dimension)
    index_flat.add(embeddings)
    flat_time = time.time() - start_time
    
    flat_file = OUTPUT_DIR / "faiss_index_flatl2.faiss"
    faiss.write_index(index_flat, str(flat_file))
    print(f"Flat L2 Index built in {flat_time:.4f}s and saved to: {flat_file}")

    # 2. Build IVF Flat Index
    print("Building IVF Flat Index (approximate search)...")
    start_time = time.time()
    # IVF Flat partitions the vectors into nlist clusters
    nlist = min(100, len(embeddings))  # scale clusters to data size
    if nlist < 1:
        nlist = 1
    quantizer = faiss.IndexFlatL2(dimension)
    index_ivf = faiss.IndexIVFFlat(quantizer, dimension, nlist, faiss.METRIC_L2)
    
    print(f"Training IVF Index with nlist={nlist} on {len(embeddings)} vectors...")
    index_ivf.train(embeddings)
    index_ivf.add(embeddings)
    ivf_time = time.time() - start_time
    
    ivf_file = OUTPUT_DIR / "faiss_index_ivfflat.faiss"
    faiss.write_index(index_ivf, str(ivf_file))
    print(f"IVF Flat Index built in {ivf_time:.4f}s and saved to: {ivf_file}")

    # 3. Save metadata.json
    print("Creating and saving metadata.json...")
    metadata_list = []
    for item in knowledge:
        metadata_list.append({
            "id": item.get("id"),
            "source": item.get("source"),
            "title": item.get("title"),
            "category": item.get("category"),
            "text": item.get("text")
        })
        
    metadata_output = OUTPUT_DIR / "metadata.json"
    with open(metadata_output, "w", encoding="utf-8") as f:
        json.dump(metadata_list, f, ensure_ascii=False, indent=2)
    print(f"Metadata mapping saved to: {metadata_output}")

    # 4. Save checkpoint.txt
    checkpoint_file = OUTPUT_DIR / "checkpoint.txt"
    timestamp = datetime.now().isoformat()
    with open(checkpoint_file, "w", encoding="utf-8") as f:
        f.write(f"FAISS Indexing Completed Successfully!\n")
        f.write(f"Timestamp: {timestamp}\n")
        f.write(f"Number of Indexed Documents: {len(embeddings)}\n")
        f.write(f"Embedding Dimension: {dimension}\n")
        f.write(f"Flat L2 Index: faiss_index_flatl2.faiss\n")
        f.write(f"IVF Flat Index: faiss_index_ivfflat.faiss\n")
    print(f"Checkpoint saved to: {checkpoint_file}")

    print("\n" + "=" * 80)
    print("FAISS Indexing Complete!")
    print("=" * 80)

if __name__ == "__main__":
    main()
