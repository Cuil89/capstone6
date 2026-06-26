import json
import os
import argparse
from pathlib import Path
import numpy as np
import faiss
from sentence_transformers import SentenceTransformer
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
import time

# Set up paths
BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = BASE_DIR / "output"

app = FastAPI(
    title="RAG Medical Chatbot API",
    description="semantic retrieval and simulated RAG response server using FAISS and SentenceTransformers",
    version="1.0.0"
)

# Global variables for models and indices
model = None
index_flat = None
index_ivf = None
metadata = []
model_name = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"

# Request schemas
class SearchRequest(BaseModel):
    query: str
    k: int = 5
    index_type: str = "flat"  # "flat" or "ivf"

class ChatRequest(BaseModel):
    message: str
    index_type: str = "flat"

@app.on_event("startup")
def startup_event():
    global model, index_flat, index_ivf, metadata
    
    # Load metadata
    metadata_file = OUTPUT_DIR / "metadata.json"
    if not metadata_file.exists():
        raise RuntimeError(f"metadata.json not found at {metadata_file}. Please run index script first.")
    
    with open(metadata_file, "r", encoding="utf-8") as f:
        metadata = json.load(f)
    print(f"Loaded {len(metadata)} metadata records.")

    # Load FAISS indices
    flat_file = OUTPUT_DIR / "faiss_index_flatl2.faiss"
    ivf_file = OUTPUT_DIR / "faiss_index_ivfflat.faiss"

    if flat_file.exists():
        index_flat = faiss.read_index(str(flat_file))
        print("Loaded Flat L2 FAISS index.")
    else:
        print("[WARNING] Flat FAISS index not found.")

    if ivf_file.exists():
        index_ivf = faiss.read_index(str(ivf_file))
        print("Loaded IVF Flat FAISS index.")
    else:
        print("[WARNING] IVF Flat FAISS index not found.")

    if not index_flat and not index_ivf:
        raise RuntimeError("No FAISS index files found in output/.")

    # Load model
    print(f"Loading embedding model: {model_name}...")
    model = SentenceTransformer(model_name)
    print("Embedding model loaded successfully.")

@app.get("/")
@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "model": model_name,
        "indexed_records": len(metadata),
        "has_flat_index": index_flat is not None,
        "has_ivf_index": index_ivf is not None
    }

@app.post("/search")
def search(req: SearchRequest):
    global model, index_flat, index_ivf, metadata
    
    if not req.query.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")

    # Select index
    index = index_flat if req.index_type.lower() == "flat" else index_ivf
    if index is None:
        raise HTTPException(
            status_code=400, 
            detail=f"Requested index type '{req.index_type}' is not loaded."
        )

    start_time = time.time()

    # 1. Brand name keyword match (Keyword Search)
    query_words = set([w.strip('?,.()_-"\'').lower() for w in req.query.split() if w.strip('?,.()_-"\'')])
    
    # Common medical forms to skip as brand names
    GENERIC_TERMS = {"tablet", "kapsul", "sirup", "cair", "obat", "doen", "kaplet", "tetes", "cream", "salep", "gel", "injection", "infus", "anak", "dewasa", "forte"}
    
    keyword_results = []
    if query_words:
        for doc in metadata:
            title = doc.get("title", "").strip()
            if not title:
                continue
            title_words = [w.strip('?,.()_-"\'').lower() for w in title.split() if w.strip('?,.()_-"\'')]
            if not title_words:
                continue
            
            # Determine brand word: first word, or second if first is generic
            brand_word = title_words[0]
            if brand_word in GENERIC_TERMS and len(title_words) > 1:
                brand_word = title_words[1]
                
            if len(brand_word) >= 3 and brand_word in query_words:
                # Calculate title-to-query word overlap
                matched_words = [w for w in title_words if w in query_words]
                overlap_ratio = len(matched_words) / len(title_words)
                # Perfect match gets score 0.1, partial matches scaled up to 0.6
                score = 0.5 * (1.0 - overlap_ratio) + 0.1
                keyword_results.append((score, doc))

        # Sort keyword matches by score
        keyword_results.sort(key=lambda x: x[0])

    # 2. Semantic Search using FAISS
    query_vector = model.encode([req.query], convert_to_numpy=True).astype('float32')
    # Retrieve double the requested k so we can merge & deduplicate effectively
    distances, indices = index.search(query_vector, req.k * 2)
    
    semantic_results = []
    for dist, idx in zip(distances[0], indices[0]):
        if idx == -1 or idx >= len(metadata):
            continue
        semantic_results.append((float(dist), metadata[idx]))

    # 3. Merge and Deduplicate Results
    seen_ids = set()
    merged_results = []

    # Insert keyword results first
    for score, doc in keyword_results:
        if doc.get("id") not in seen_ids:
            seen_ids.add(doc.get("id"))
            merged_results.append({
                "score": score,
                "id": doc.get("id"),
                "source": doc.get("source"),
                "title": doc.get("title"),
                "category": doc.get("category"),
                "text": doc.get("text")
            })

    # Insert semantic results
    for score, doc in semantic_results:
        if doc.get("id") not in seen_ids:
            seen_ids.add(doc.get("id"))
            merged_results.append({
                "score": score,
                "id": doc.get("id"),
                "source": doc.get("source"),
                "title": doc.get("title"),
                "category": doc.get("category"),
                "text": doc.get("text")
            })

    # Cut off at requested k
    results = merged_results[:req.k]
    search_time = time.time() - start_time

    return {
        "query": req.query,
        "index_type": req.index_type,
        "search_time_seconds": search_time,
        "results": results
    }

@app.post("/chat")
def chat(req: ChatRequest):
    # Perform search to retrieve top-3 contexts
    search_req = SearchRequest(query=req.message, k=3, index_type=req.index_type)
    search_res = search(search_req)
    results = search_res["results"]

    if not results:
        return {
            "answer": "Maaf, saya tidak dapat menemukan informasi medis yang relevan untuk pertanyaan Anda.",
            "sources": []
        }

    # Format retrieved contexts
    contexts = []
    sources = []
    for idx, doc in enumerate(results):
        contexts.append(f"[{idx+1}] {doc['title']} (Sumber: {doc['source']}):\n{doc['text']}")
        sources.append({
            "title": doc["title"],
            "source": doc["source"],
            "category": doc["category"],
            "id": doc["id"]
        })

    context_str = "\n\n".join(contexts)

    # Simulate RAG reasoning and generation
    prompt = f"""
Simulated RAG Chatbot Completion based on search results:
User: {req.message}

Contexts retrieved:
{context_str}
"""
    
    # Simple rule-based generation to output a professional response
    best_match = results[0]
    
    # Let's craft a helpful answer
    lang = "en" if best_match["source"] in ("MedlinePlus", "MID") else "id"
    
    if lang == "id":
        answer = f"Berdasarkan dokumen kesehatan terkait **{best_match['title']}** (Sumber: {best_match['source']}):\n\n"
        # Extract name, indication, or description if present
        text_lines = best_match["text"].split("\n")
        # Format the text nicer
        clean_text = "\n".join([line.strip() for line in text_lines if line.strip()][:8])
        answer += clean_text + "\n\n*Catatan: Selalu konsultasikan dengan dokter atau apoteker Anda sebelum mengonsumsi obat.*"
    else:
        answer = f"Based on medical information regarding **{best_match['title']}** (Source: {best_match['source']}):\n\n"
        text_lines = best_match["text"].split("\n")
        clean_text = "\n".join([line.strip() for line in text_lines if line.strip()][:8])
        answer += clean_text + "\n\n*Note: Please consult with a healthcare professional before making any medical decisions.*"

    return {
        "answer": answer,
        "sources": sources,
        "search_time_seconds": search_res["search_time_seconds"]
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Start the RAG Medical Chatbot API server.")
    parser.add_argument("--host", type=str, default="127.0.0.1", help="Host IP to bind server to.")
    parser.add_argument("--port", type=int, default=8000, help="Port to run server on.")
    parser.add_argument("--model", type=str, default="sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2", 
                        help="Model name for generating embeddings.")
    args = parser.parse_args()
    
    model_name = args.model
    uvicorn.run(app, host=args.host, port=args.port)
