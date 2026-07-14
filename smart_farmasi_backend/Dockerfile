# Gunakan versi Python 3.10 yang ringan (slim)
FROM python:3.10-slim

# Mencegah python menulis file .pyc dan memastikan output langsung muncul di terminal
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

# Install dependency sistem yang dibutuhkan oleh opencv dan dlib
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Mengubah versi dlib khusus Windows menjadi dlib umum untuk Linux
RUN sed -i 's|dlib @ https://github.com/sachadee/Dlib/raw/main/dlib-20.0.0-cp310-cp310-win_amd64.whl|dlib|g' requirements.txt

# Install library python dan Gunicorn (web server untuk production)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn

COPY . .

# Expose port yang digunakan Cloud Run (8080)
EXPOSE 8080

# Jalankan aplikasi menggunakan Gunicorn untuk performa maksimal
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--threads", "8", "--timeout", "0", "run:app"]
