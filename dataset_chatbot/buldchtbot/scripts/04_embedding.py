import json
import argparse
from pathlib import Path
import numpy as np
from sentence_transformers import SentenceTransformer
import time

# Set up paths
BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = BASE_DIR / "output"

def main():
    parser = argparse.ArgumentParser(description="Generate embeddings for the normalized medical knowledge base.")
    parser.add_argument("--model", type=str, default="sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2", 
                        help="SentenceTransformer model name to use.")
    parser.add_argument("--limit", type=int, default=None, 
                        help="Limit the number of records to process for quick testing (e.g. 1000).")
    parser.add_argument("--batch-size", type=int, default=64, 
                        help="Batch size for generating embeddings.")
    args = parser.parse_args()

    input_file = OUTPUT_DIR / "normalized_knowledge.json"
    if not input_file.exists():
        print(f"Error: normalized_knowledge.json not found at {input_file}. Please run scripts 02 and 03 first.")
        return

    print("Loading normalized knowledge...")
    with open(input_file, "r", encoding="utf-8") as f:
        knowledge = json.load(f)

    total_records = len(knowledge)
    print(f"Loaded {total_records} total records.")

    if args.limit is not None:
        print(f"Limiting to the first {args.limit} records for testing...")
        knowledge = knowledge[:args.limit]
        total_records = len(knowledge)

    # Extract texts to embed
    texts = [item.get("text", "") for item in knowledge]

    print(f"Loading embedding model: {args.model}...")
    model = SentenceTransformer(args.model)

    print(f"Generating embeddings for {total_records} documents (Batch size: {args.batch_size})...")
    start_time = time.time()
    
    embeddings = model.encode(
        texts,
        batch_size=args.batch_size,
        show_progress_bar=True,
        convert_to_numpy=True
    )
    
    elapsed_time = time.time() - start_time
    print(f"Embeddings generated in {elapsed_time:.2f} seconds ({total_records / elapsed_time:.2f} docs/sec).")
    print(f"Embeddings shape: {embeddings.shape}")

    # Save embeddings to output/
    embeddings_file = OUTPUT_DIR / "embeddings.npy"
    np.save(embeddings_file, embeddings)
    print(f"Embeddings saved successfully to: {embeddings_file}")

    # Save the subset of knowledge we actually embedded as a metadata check if limit was used
    if args.limit is not None:
        subset_file = OUTPUT_DIR / "normalized_knowledge_subset.json"
        with open(subset_file, "w", encoding="utf-8") as f:
            json.dump(knowledge, f, ensure_ascii=False, indent=2)
        print(f"Saved subset metadata to: {subset_file}")

if __name__ == "__main__":
    main()
