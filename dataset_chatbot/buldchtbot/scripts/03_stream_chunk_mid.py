import json
import os
from pathlib import Path
from transformers import AutoTokenizer
import ijson
import time

# Set up paths
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
OUTPUT_DIR = BASE_DIR / "output"
OUTPUT_DIR.mkdir(exist_ok=True)

# Load tokenizer for token-based chunking
MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
print(f"Loading tokenizer: {MODEL_NAME}...")
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

def process_batch(batch_items, temp_f, max_tokens=500, overlap=75):
    # Extract texts
    texts = [item["text"] for item in batch_items]
    
    # Batch encode texts using transformers Rust-based tokenizer (multi-threaded)
    encodings = tokenizer(texts, add_special_tokens=False)
    input_ids_list = encodings["input_ids"]
    
    chunks_to_decode = []
    chunk_metadata = [] # maps decoded text index back to batch_items index and chunk index
    
    for item_idx, tokens in enumerate(input_ids_list):
        if len(tokens) <= max_tokens:
            chunks_to_decode.append(tokens)
            chunk_metadata.append((item_idx, 0))
        else:
            start = 0
            c_idx = 0
            while start < len(tokens):
                current_start = start
                if start > 0:
                    current_start = max(0, start - overlap)
                end = current_start + max_tokens
                chunk_tokens = tokens[current_start:end]
                
                chunks_to_decode.append(chunk_tokens)
                chunk_metadata.append((item_idx, c_idx))
                
                c_idx += 1
                if end >= len(tokens):
                    break
                start = end
                
    # Batch decode all chunk tokens in parallel
    decoded_texts = tokenizer.batch_decode(chunks_to_decode, skip_special_tokens=True)
    
    # Write to file
    chunk_count = 0
    for (item_idx, c_idx), decoded_text in zip(chunk_metadata, decoded_texts):
        decoded_text = decoded_text.strip()
        if decoded_text:
            item = batch_items[item_idx]
            chunk_record = {
                "id": f"{item['id']}_chunk_{c_idx}",
                "source": item["source"],
                "title": item["title"],
                "category": item["category"],
                "text": decoded_text
            }
            temp_f.write(json.dumps(chunk_record, ensure_ascii=False) + "\n")
            chunk_count += 1
            
    return chunk_count

def main():
    normalized_knowledge_file = OUTPUT_DIR / "normalized_knowledge.json"
    temp_chunks_file = OUTPUT_DIR / "mid_chunks_temp.jsonl"
    checkpoint_file = OUTPUT_DIR / "checkpoint_mid.txt"
    mid_path = DATA_DIR / "mid.json"
    
    if not mid_path.exists():
        print(f"Error: mid.json not found at {mid_path}")
        return

    # Determine starting index from checkpoint
    start_idx = 0
    if checkpoint_file.exists():
        try:
            with open(checkpoint_file, "r") as cf:
                start_idx = int(cf.read().strip())
            print(f"Resuming from checkpoint. Starting at record index: {start_idx}")
        except Exception:
            print("Checkpoint file exists but is corrupted. Starting from index 0.")
            start_idx = 0

    # Open temporary chunks file in append mode
    mode = "a" if start_idx > 0 else "w"
    temp_f = open(temp_chunks_file, mode, encoding="utf-8")

    print("Streaming and batch token-chunking mid.json...")
    processed_count = 0
    chunked_count = 0
    batch_size = 1000
    batch_items = []
    
    start_time = time.time()
    last_print_time = start_time

    # Open mid.json in binary mode
    with open(mid_path, "rb") as f:
        parser = ijson.items(f, "item")
        for idx, item in enumerate(parser):
            if idx < start_idx:
                processed_count = idx + 1
                continue

            item_id = item.get("id", f"mid_{idx}")
            source = item.get("source", "MID")
            title = item.get("title", "").strip()
            category = item.get("category", "").strip()
            text = item.get("text", "").strip()

            if text:
                batch_items.append({
                    "id": item_id,
                    "source": source,
                    "title": title,
                    "category": category,
                    "text": text
                })

            processed_count += 1

            # Process in batches
            if len(batch_items) >= batch_size:
                new_chunks = process_batch(batch_items, temp_f)
                chunked_count += new_chunks
                batch_items = []
                
                # Write checkpoint and flush
                temp_f.flush()
                with open(checkpoint_file, "w") as cf:
                    cf.write(str(processed_count))
                
                current_time = time.time()
                elapsed = current_time - last_print_time
                if elapsed > 10:  # print progress every 10s
                    rate = processed_count / (current_time - start_time)
                    print(f"Processed {processed_count} records. Wrote {chunked_count} chunks. Speed: {rate:.1f} records/sec")
                    last_print_time = current_time

        # Process remaining items in final batch
        if batch_items:
            new_chunks = process_batch(batch_items, temp_f)
            chunked_count += new_chunks
            temp_f.flush()
            with open(checkpoint_file, "w") as cf:
                cf.write(str(processed_count))

    temp_f.close()
    print(f"Finished streaming mid.json. Total processed: {processed_count}. New chunks generated: {chunked_count}")

    # Merge temporary chunks with base normalized_knowledge.json
    print("Merging chunks into final normalized_knowledge.json...")
    
    if normalized_knowledge_file.exists():
        with open(normalized_knowledge_file, "r", encoding="utf-8") as nkf:
            try:
                knowledge = json.load(nkf)
            except Exception:
                knowledge = []
    else:
        knowledge = []
        
    print(f"Loaded {len(knowledge)} existing records from normalized_knowledge.json")

    # Read and append all temporary chunks
    if temp_chunks_file.exists():
        with open(temp_chunks_file, "r", encoding="utf-8") as tcf:
            for line in tcf:
                if line.strip():
                    knowledge.append(json.loads(line.strip()))

    # Write merged knowledge back
    print(f"Saving final combined {len(knowledge)} records to normalized_knowledge.json...")
    with open(normalized_knowledge_file, "w", encoding="utf-8") as nkf:
        json.dump(knowledge, nkf, ensure_ascii=False, indent=2)

    # Clean up temporary files
    if temp_chunks_file.exists():
        os.remove(temp_chunks_file)
    if checkpoint_file.exists():
        os.remove(checkpoint_file)

    print("\n" + "=" * 80)
    print("Streaming and Token-based Chunking Complete!")
    print(f"Total merged records: {len(knowledge)}")
    print("=" * 80)

if __name__ == "__main__":
    main()
