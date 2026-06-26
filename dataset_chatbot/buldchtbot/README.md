# RAG Medical Chatbot Pipeline

This repository implements a complete end-to-end RAG (Retrieval-Augmented Generation) pipeline for medical information retrieval. It features schema analysis, data normalization, deduplication, streaming text chunking for large files, vector embedding generation, dual-index FAISS search structures, and a FastAPI server.

## Repository Structure

```
rag-medical-chatbot/
│
├── data/                             # Raw Preprocessed Datasets
│   ├── pharmasafe.json               # Indonesian drug info
│   ├── data-drug.json                # English drug dataset (JSON List)
│   ├── data-obat.json                # Indonesian drug dataset (JSON List)
│   ├── indonesia.json                # Indonesian drug and disease dataset
│   ├── medline.json                  # MedlinePlus health topics (XML source)
│   └── mid.json                      # Large Medical Info Dataset (559MB)
│
├── scripts/                          # Pipeline Execution Scripts
│   ├── 01_schema_analysis.py         # Step 1: Inspect schemas and sample entries
│   ├── 02_normalize_and_deduplicate.py# Step 2: Standardize & deduplicate core datasets
│   ├── 03_stream_chunk_mid.py        # Step 3: Stream and chunk the large MID dataset
│   ├── 04_embedding.py               # Step 4: Generate semantic text embeddings
│   ├── 05_faiss_indexing.py          # Step 5: Build Flat L2 & IVF Flat indices
│   └── 06_api_server.py              # Step 6: Serve FastAPI endpoint
│
├── output/                           # Build Artifacts & Indexes
│   ├── normalized_knowledge.json     # Output from Step 2 & 3
│   ├── embeddings.npy                # Numpy embeddings array (from Step 4)
│   ├── faiss_index_flatl2.faiss      # Flat exact index (from Step 5)
│   ├── faiss_index_ivfflat.faiss     # Trained approximate index (from Step 5)
│   ├── metadata.json                 # Document-to-Index mappings (from Step 5)
│   └── checkpoint.txt                # Job completion signature (from Step 5)
│
├── requirements.txt                  # System dependencies
└── README.md                         # Project documentation
```

---

## Installation

Install the required Python packages:

```bash
pip install -r requirements.txt
```

---

## Step-by-Step Pipeline Execution

### Step 1: Schema Analysis
Run this to understand the formats, fields, record counts, and sizes of the input datasets:
```bash
python scripts/01_schema_analysis.py
```

### Step 2: Normalize and Deduplicate Core Datasets
Merges the smaller JSON datasets (`pharmasafe`, `data-drug`, `data-obat`, `indonesia`, and `medline`), standardizes them to a single layout (`id`, `source`, `title`, `category`, `text`), and removes duplicates:
```bash
python scripts/02_normalize_and_deduplicate.py
```

### Step 3: Memory-Efficient Stream Chunking (for `mid.json`)
The `mid.json` dataset is very large (559MB). To prevent Out Of Memory (OOM) errors, this script streams the file line-by-line, chunks the drug descriptions into 800-character segments (with 100-character overlap) avoiding broken words, and appends them to the knowledge base:
```bash
python scripts/03_stream_chunk_mid.py
```

### Step 4: Generate Embeddings
Generates semantic embeddings for each document in the knowledge base.
> [!TIP]
> Since the dataset contains ~840k records, generating embeddings on CPU can take a long time. For quick verification and local testing, run with the `--limit` flag to process only a subset (e.g. 1000 items):
```bash
# Recommended for testing (1000 documents)
python scripts/04_embedding.py --limit 1000

# Full run (processes all ~840k documents)
python scripts/04_embedding.py
```

### Step 5: Build FAISS Indices
Loads the generated embeddings and document files, builds both an exact Flat L2 index and a trained cluster IVF Flat index, and writes the metadata mapping to `output/metadata.json`:
```bash
python scripts/05_faiss_indexing.py
```

### Step 6: Start the API Server
Starts a FastAPI web server hosting semantic search and RAG completions:
```bash
python scripts/06_api_server.py --port 8000
```

---

## API Endpoints

Once the API server is running, you can access the interactive documentation at `http://127.0.0.1:8000/docs`.

### 1. Semantic Search
**POST** `/search`
- **Request Body**:
  ```json
  {
    "query": "sakit kepala",
    "k": 3,
    "index_type": "flat"
  }
  ```
- **Response**: Returns the top `k` most semantically similar documents, along with their metadata and L2 scores.

### 2. Chat / RAG Endpoint
**POST** `/chat`
- **Request Body**:
  ```json
  {
    "message": "What is the recommended dosage for paracetamol?",
    "index_type": "flat"
  }
  ```
- **Response**: Returns a synthesized RAG response text along with the specific document sources used.
