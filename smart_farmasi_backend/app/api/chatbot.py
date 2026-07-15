from flask_restful import Resource
from flask import request, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
import requests
import os
import subprocess
import socket
import time
from app.models import UserActivity, ChatHistory, ChatSession, db
import datetime

def is_port_open(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.3)
        try:
            s.connect(("127.0.0.1", port))
            return True
        except:
            return False

def check_and_start_search_service(search_url):
    try:
        port = int(search_url.split(":")[-1].replace("/", ""))
    except:
        port = 8000

    if not is_port_open(port):
        # Dynamically locate the python interpreter and script relative to this file
        current_dir = os.path.dirname(os.path.abspath(__file__)) # smart_farmasi_backend/app/api
        app_dir = os.path.dirname(current_dir) # smart_farmasi_backend/app
        backend_dir = os.path.dirname(app_dir) # smart_farmasi_backend
        workspace_root = os.path.dirname(backend_dir) # capstone6
        
        chatbot_dir = os.path.join(workspace_root, 'dataset_chatbot', 'buldchtbot')
        venv_python = os.path.join(chatbot_dir, '.venv', 'Scripts', 'python.exe')
        if not os.path.exists(venv_python):
            venv_python = os.path.join(chatbot_dir, '.venv', 'bin', 'python')
        api_script = os.path.join(chatbot_dir, 'scripts', '06_api_server.py')
        
        if os.path.exists(venv_python) and os.path.exists(api_script):
            try:
                subprocess.Popen(
                    [venv_python, api_script, "--port", str(port)],
                    cwd=chatbot_dir,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    close_fds=True
                )
                time.sleep(0.5) # Give it a brief moment to initiate process
                return True, "Starting database search engine..."
            except Exception as e:
                return False, f"Failed to launch database engine: {str(e)}"
        return False, "Database search engine environment not found."
    return True, "Database search engine online."

def retrieve_contexts(query, search_url):
    try:
        response = requests.post(
            f"{search_url}/search",
            json={"query": query, "k": 12, "index_type": "flat"},
            timeout=3.0
        )
        if response.status_code == 200:
            return response.json().get("results", [])
    except Exception as e:
        print(f"Error querying search service: {e}")
    return []

def _build_system_content(contexts):
    # Absolute topic guardrail at the very top of prompt
    guardrail_header = """PENTING: BATASAN TOPIK MUTLAK (WAJIB DIIKUTI SECARA KETAT)
Anda HANYA diperbolehkan menjawab pertanyaan seputar kesehatan, obat-obatan, gejala penyakit, gaya hidup sehat, tips medis, atau fitur aplikasi SEHATI.
Jika pengguna bertanya tentang hal lain di luar topik kesehatan (seperti coding/pemrograman, bahasa komputer, matematika, sejarah, politik umum, resep masakan non-diet, tips teknologi, dll), Anda WAJIB MENOLAK secara sopan dan tegas. 
JANGAN PERNAH memberikan contoh kode program (seperti python, javascript, dll), rumus matematika, atau informasi non-kesehatan lainnya.
Contoh penolakan: "Maaf, saya hanya dapat membantu menjawab pertanyaan seputar kesehatan dan obat-obatan."
"""

    if contexts:
        context_str = ""
        for i, doc in enumerate(contexts):
            context_str += f"\n[Dokumen {i+1}] (Sumber: {doc.get('source', 'Unknown')})\n{doc.get('text', '')}\n"
            
        return f"""Anda adalah Asisten Kesehatan SEHATI (Smart Farmasi) yang sangat profesional, ramah, dan penuh empati. Tugas Anda adalah memberikan informasi obat/kesehatan secara AKURAT, RINGKAS, dan mudah dipahami oleh orang awam layaknya apoteker pribadi.

{guardrail_header}

Gunakan data obat/kesehatan dari database internal SEHATI berikut jika relevan:
{context_str}

ATURAN RESPON & FORMAT TAMPILAN:
1. Bahasa Natural & Awam (PENTING!): Gunakan bahasa Indonesia sehari-hari yang sangat natural, seolah sedang ngobrol santai dengan teman. HINDARI bahasa kaku atau robotik. TERJEMAHKAN semua istilah medis rumit ke bahasa umum yang dimengerti semua orang (contoh: jangan sebut "dispepsia", sebut "sakit lambung/maag").
2. Rekomendasi Obat yang Umum & Ampuh: Jika pengguna meminta saran obat untuk penyakit tertentu (misal: maag/lambung, pusing, batuk), PILIHLAH obat dari database SEHATI yang paling umum, banyak dikenal luas oleh masyarakat, dan terbukti ampuh (seperti Promag untuk lambung, Paracetamol untuk demam, dll). Sebisa mungkin sebutkan NAMA MERK OBAT yang spesifik dan populer (misal: "Bisolvon", "Mylanta") alih-alih hanya menyebut nama generik/golongan obat (misal: "ekspektoran").
3. Empati & Wajib Klarifikasi: Tunjukkan empati (misal: "Waduh, semoga cepat sembuh ya!"). JIKA keluhan yang diberikan sangat umum atau kurang spesifik (misalnya hanya bilang "sakit kepala", "sakit perut", atau "gatal"), ANDA DILARANG KERAS menyebut nama obat apapun! Anda HANYA BOLEH bertanya balik untuk memperjelas gejala (misal: "Sakit kepalanya seperti apa? Berdenyut, berputar, atau terasa berat?"). Hentikan jawaban Anda setelah bertanya, jangan tambahkan rekomendasi apapun. Baru berikan obat di pesan berikutnya jika gejalanya sudah jelas.
4. Singkat & Padat: Maksimal 120-180 kata. Jawab langsung ke inti pertanyaan.
5. STRUKTUR & TAMPILAN (SANGAT PENTING):
   - JANGAN PERNAH MENGGUNAKAN SIMBOL BINTANG (*). Anda dilarang memformat teks menjadi tebal (bold) menggunakan **teks**. Tulis saja teks biasa (plain text).
   - DILARANG KERAS menggunakan bullet points standar seperti (-) atau (•).
   - Sebagai ganti format di atas, JIKA Anda ingin membuat list, GUNAKAN EMOJI di awal baris (contoh: 🩺, 💊, 👉, ⚠️).
6. Format Penjelasan Obat Khusus:
   Jika menjelaskan atau merekomendasikan obat, WAJIB gunakan format emoji rapi berikut (JANGAN GUNAKAN **BOLD** DI SINI, TULIS TEKS BIASA):
   💊 NAMA & GUNA OBAT: (sebutkan nama obat dan kegunaannya tanpa tanda bintang)
   ⏱️ DOSIS & ATURAN: (dosis dan panduan usia dengan bahasa awam)
   ⚠️ EFEK SAMPING: (efek samping utama)
7. Penanganan Sumber: Jika obat tidak ada di database, sampaikan dengan bahasa santai bahwa obat tidak ditemukan di database SEHATI, lalu berikan saran medis umum.
8. Disclaimer Medis: Selalu akhiri dengan baris baru persis seperti ini (tanpa bintang/simbol lain):

📌 Catatan: Informasi ini hanya saran awal ya. Selalu pastikan baca aturan pakai atau konsultasikan dengan apoteker/dokter!"""
    else:
        return f"""Anda adalah Asisten Kesehatan SEHATI (Smart Farmasi) yang sangat profesional, ramah, dan penuh empati. Tugas Anda adalah memberikan informasi kesehatan umum secara AKURAT, RINGKAS, dan menggunakan bahasa awam.

{guardrail_header}

Catatan: Database internal sedang memuat/offline. Jawablah menggunakan pengetahuan medis umum Anda secara singkat dan aman.

ATURAN RESPON & FORMAT TAMPILAN:
1. Bahasa Natural & Awam (PENTING!): Gunakan bahasa Indonesia sehari-hari yang sangat natural, seolah sedang ngobrol santai. HINDARI bahasa kaku/robotik. Terjemahkan istilah medis rumit ke bahasa masyarakat umum.
2. Empati & Wajib Klarifikasi: Tunjukkan empati. JIKA keluhan sangat umum (misal "sakit kepala"), DILARANG KERAS menyebut obat apapun. WAJIB bertanya balik untuk memperjelas gejala dan Hentikan jawaban setelah bertanya.
3. Singkat & Padat: Maksimal 120-180 kata.
4. STRUKTUR & TAMPILAN (SANGAT PENTING):
   - JANGAN PERNAH MENGGUNAKAN SIMBOL BINTANG (*). Anda dilarang memformat teks menjadi tebal (bold) menggunakan **teks**. Tulis saja teks biasa.
   - DILARANG KERAS menggunakan bullet points standar seperti (-) atau (•).
   - Sebagai gantinya, GUNAKAN EMOJI di awal baris (contoh: 🩺, 💡, 👉, ⚠️).
5. Disclaimer Medis: Selalu akhiri dengan baris baru persis seperti ini (tanpa bintang/simbol lain):

📌 Catatan: Informasi ini hanya saran awal ya. Selalu pastikan baca aturan pakai atau konsultasikan dengan apoteker/dokter!"""

def call_openrouter(query, contexts, api_key, model_name, chat_history=[]):
    url = "https://openrouter.ai/api/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://sehati-app.com",
        "X-Title": "SEHATI Chatbot"
    }
    system_content = _build_system_content(contexts)
    
    messages = [{"role": "system", "content": system_content}]
    for msg in chat_history:
        messages.append({"role": "user", "content": msg['user_message']})
        if msg.get('bot_response'):
            messages.append({"role": "assistant", "content": msg['bot_response']})
    messages.append({"role": "user", "content": query})

    payload = {
        "model": model_name,
        "messages": messages,
        "temperature": 0.3
    }
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=25.0)
        if response.status_code == 200:
            res_data = response.json()
            choices = res_data.get("choices", [])
            if choices:
                return choices[0].get("message", {}).get("content", "").strip()
        else:
            print(f"OpenRouter Error Status {response.status_code}: {response.text}")
    except Exception as e:
        print(f"Error calling OpenRouter: {e}")
    return None

def call_groq(query, contexts, api_key, model_name, chat_history=[]):
    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    system_content = _build_system_content(contexts)
    
    messages = [{"role": "system", "content": system_content}]
    for msg in chat_history:
        messages.append({"role": "user", "content": msg['user_message']})
        if msg.get('bot_response'):
            messages.append({"role": "assistant", "content": msg['bot_response']})
    messages.append({"role": "user", "content": query})

    payload = {
        "model": model_name,
        "messages": messages,
        "temperature": 0.3
    }
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=25.0)
        if response.status_code == 200:
            res_data = response.json()
            choices = res_data.get("choices", [])
            if choices:
                return choices[0].get("message", {}).get("content", "").strip()
        else:
            print(f"Groq Error Status {response.status_code}: {response.text}")
    except Exception as e:
        print(f"Error calling Groq: {e}")
    return None

def call_gemini_direct(query, contexts, api_key, chat_history=[]):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={api_key}"
    headers = {"Content-Type": "application/json"}
    system_content = _build_system_content(contexts)
    
    # In Gemini v1beta, we can use systemInstruction, but for robust compatibility with multi-turn we will just append it as a developer/system or embed it in the first message.
    # Alternatively, the new v1beta API supports systemInstruction field natively:
    contents = []
    for msg in chat_history:
        contents.append({"role": "user", "parts": [{"text": msg['user_message']}]})
        if msg.get('bot_response'):
            contents.append({"role": "model", "parts": [{"text": msg['bot_response']}]})
    contents.append({"role": "user", "parts": [{"text": f"Pertanyaan Pengguna: {query}"}]})

    payload = {
        "systemInstruction": {
            "parts": [{"text": system_content}]
        },
        "contents": contents,
        "generationConfig": {
            "temperature": 0.3
        }
    }
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=25.0)
        if response.status_code == 200:
            res_data = response.json()
            candidates = res_data.get("candidates", [])
            if candidates:
                content = candidates[0].get("content", {})
                parts = content.get("parts", [])
                if parts:
                    return parts[0].get("text", "").strip()
        else:
            print(f"Gemini API Error Status {response.status_code}: {response.text}")
    except Exception as e:
        print(f"Error calling Gemini: {e}")
    return None

class ChatbotAPI(Resource):
    @jwt_required()
    def post(self):
        try:
            user_id = get_jwt_identity()
            data = request.get_json()
            
            if not data or 'message' not in data:
                return {'message': 'Missing message'}, 400
                
            user_message = data['message']
            
            # 1. Retrieve config values
            api_key = current_app.config.get('OPENROUTER_API_KEY')
            model_name = current_app.config.get('OPENROUTER_MODEL', 'google/gemini-2.5-flash')
            search_url = current_app.config.get('SEARCH_SERVICE_URL', 'http://127.0.0.1:8001')
            gemini_key = current_app.config.get('GEMINI_API_KEY') or os.environ.get('GEMINI_API_KEY')
            groq_key = current_app.config.get('GROQ_API_KEY') or os.environ.get('GROQ_API_KEY')
            groq_model = current_app.config.get('GROQ_MODEL', 'llama-3.3-70b-specdec')
            
            # 2. Check search service & startup if offline
            check_and_start_search_service(search_url)
            
            # 3. Handle chat session & retrieve history BEFORE calling API
            session_id = data.get('session_id')
            chat_session = None
            chat_history = []
            
            if session_id:
                chat_session = ChatSession.query.filter_by(
                    id=int(session_id), user_id=int(user_id)
                ).first()
                if chat_session:
                    # Get up to 10 previous messages for context memory
                    past_messages = ChatHistory.query.filter_by(session_id=chat_session.id).order_by(ChatHistory.timestamp.desc()).limit(10).all()
                    # Reverse to chronological order
                    past_messages.reverse()
                    for msg in past_messages:
                        chat_history.append({
                            'user_message': msg.user_message,
                            'bot_response': msg.bot_response
                        })
            
            # 4. Retrieve relevant medical contexts
            contexts = retrieve_contexts(user_message, search_url)
            # Filter out completely unrelated search results (score > 22.0)
            contexts = [c for c in contexts if c.get("score", 99.0) <= 22.0]
            
            # 5. Generate RAG response via multi-provider strategy
            ai_response = None
            
            # Try Groq first (extremely fast & high limits)
            if not ai_response and groq_key:
                print("Trying Groq API...")
                ai_response = call_groq(user_message, contexts, groq_key, groq_model, chat_history)
                
            # Try OpenRouter second
            if not ai_response and api_key:
                print("Trying OpenRouter API...")
                ai_response = call_openrouter(user_message, contexts, api_key, model_name, chat_history)
                
            # Try direct Gemini third
            if not ai_response and gemini_key:
                print("Trying direct Gemini API...")
                ai_response = call_gemini_direct(user_message, contexts, gemini_key, chat_history)
                
            # Final hardcoded fallback if all APIs fail
            if not ai_response:
                ai_response = self._get_fallback_response(user_message)
            
            # 6. Save activity and chat log to database
            activity = UserActivity(
                user_id=int(user_id),
                activity_type='chatbot',
                description=f"User asked: {user_message[:50]}..."
            )
            db.session.add(activity)

            if not chat_session:
                # Auto-create new session with title from first message
                title = user_message[:50].strip()
                if len(user_message) > 50:
                    title += '...'
                chat_session = ChatSession(
                    user_id=int(user_id),
                    title=title,
                )
                db.session.add(chat_session)
                db.session.flush()  # get ID before commit
            else:
                # Update session updated_at
                chat_session.updated_at = datetime.datetime.utcnow()

            chat_log = ChatHistory(
                user_id=int(user_id),
                session_id=chat_session.id,
                user_message=user_message,
                bot_response=ai_response
            )
            db.session.add(chat_log)
            db.session.commit()

            return {
                'reply': ai_response,
                'session_id': chat_session.id,
                'status': 'success'
            }, 200
        except Exception as e:
            db.session.rollback()
            return {'message': f'Internal Server Error: {str(e)}'}, 500

    def _get_fallback_response(self, message):
        return (
            "Maaf, asisten SEHATI sedang mengalami gangguan jaringan saat menghubungi mesin kecerdasan buatan. "
            "Namun, untuk pertanyaan Anda mengenai kesehatan, mohon pastikan:\n"
            "• Membaca aturan pakai pada kemasan obat secara teliti.\n"
            "• Istirahat yang cukup dan minum air putih.\n"
            "• Jika gejala berlanjut lebih dari 3 hari atau terasa parah, segera hubungi dokter atau apoteker terdekat.\n\n"
            "Silakan coba kirimkan kembali pertanyaan Anda beberapa saat lagi."
        )

class ChatHistoryAPI(Resource):
    """GET history for a specific session, DELETE all sessions for current user."""

    @jwt_required()
    def get(self):
        try:
            user_id = get_jwt_identity()
            session_id = request.args.get('session_id')
            if session_id:
                history = ChatHistory.query.filter_by(
                    user_id=int(user_id), session_id=int(session_id)
                ).order_by(ChatHistory.timestamp.asc()).all()
            else:
                history = ChatHistory.query.filter_by(
                    user_id=int(user_id)
                ).order_by(ChatHistory.timestamp.asc()).all()
            return {
                'status': 'success',
                'history': [h.to_dict() for h in history]
            }, 200
        except Exception as e:
            return {'message': f'Internal Server Error: {str(e)}'}, 500

    @jwt_required()
    def delete(self):
        """Delete ALL sessions (and their messages) for the current user."""
        try:
            user_id = get_jwt_identity()
            # Deleting sessions cascades to chat_histories
            ChatSession.query.filter_by(user_id=int(user_id)).delete()
            db.session.commit()
            return {
                'status': 'success',
                'message': 'All chat sessions cleared successfully.'
            }, 200
        except Exception as e:
            db.session.rollback()
            return {'message': f'Internal Server Error: {str(e)}'}, 500


class ChatSessionListAPI(Resource):
    """List all sessions for current user."""

    @jwt_required()
    def get(self):
        try:
            user_id = get_jwt_identity()
            sessions = ChatSession.query.filter_by(user_id=int(user_id)).order_by(
                ChatSession.updated_at.desc()
            ).all()
            return {
                'status': 'success',
                'sessions': [s.to_dict() for s in sessions]
            }, 200
        except Exception as e:
            return {'message': f'Internal Server Error: {str(e)}'}, 500

    @jwt_required()
    def post(self):
        """Create a new blank session."""
        try:
            user_id = get_jwt_identity()
            data = request.get_json() or {}
            title = data.get('title', 'Chat Baru')
            session = ChatSession(
                user_id=int(user_id),
                title=title,
            )
            db.session.add(session)
            db.session.commit()
            return {
                'status': 'success',
                'session': session.to_dict()
            }, 201
        except Exception as e:
            db.session.rollback()
            return {'message': f'Internal Server Error: {str(e)}'}, 500


class ChatSessionDetailAPI(Resource):
    """Retrieve or delete a specific session."""

    @jwt_required()
    def get(self, session_id):
        try:
            user_id = get_jwt_identity()
            session = ChatSession.query.filter_by(
                id=int(session_id), user_id=int(user_id)
            ).first()
            if not session:
                return {'message': 'Session not found.'}, 404
            history = ChatHistory.query.filter_by(
                session_id=int(session_id)
            ).order_by(ChatHistory.timestamp.asc()).all()
            return {
                'status': 'success',
                'session': session.to_dict(),
                'history': [h.to_dict() for h in history]
            }, 200
        except Exception as e:
            return {'message': f'Internal Server Error: {str(e)}'}, 500

    @jwt_required()
    def delete(self, session_id):
        try:
            user_id = get_jwt_identity()
            session = ChatSession.query.filter_by(
                id=int(session_id), user_id=int(user_id)
            ).first()
            if not session:
                return {'message': 'Session not found.'}, 404
            db.session.delete(session)
            db.session.commit()
            return {
                'status': 'success',
                'message': 'Session deleted successfully.'
            }, 200
        except Exception as e:
            db.session.rollback()
            return {'message': f'Internal Server Error: {str(e)}'}, 500

class SymptomAnalyzeAPI(Resource):
    @jwt_required()
    def post(self):
        user_id = get_jwt_identity()
        data = request.get_json()
        symptoms = data.get('symptoms', [])
        
        if not symptoms:
            return {'message': 'Symptoms list is required'}, 400
            
        symptoms_str = ", ".join(symptoms)
        
        try:
            # Retrieve config values
            api_key = current_app.config.get('OPENROUTER_API_KEY')
            model_name = current_app.config.get('OPENROUTER_MODEL', 'google/gemini-2.5-flash')
            search_url = current_app.config.get('SEARCH_SERVICE_URL', 'http://127.0.0.1:8001')
            gemini_key = current_app.config.get('GEMINI_API_KEY') or os.environ.get('GEMINI_API_KEY')
            groq_key = current_app.config.get('GROQ_API_KEY') or os.environ.get('GROQ_API_KEY')
            groq_model = current_app.config.get('GROQ_MODEL', 'llama-3.3-70b-specdec')
            
            # 1. Start RAG service
            check_and_start_search_service(search_url)
            
            # 2. Query RAG using symptoms
            prompt = f"Gejala pasien: {symptoms_str}. Obat apa yang cocok?"
            contexts = retrieve_contexts(prompt, search_url)
            contexts = [c for c in contexts if c.get("score", 99.0) <= 22.0]
            
            contexts_str = ""
            for i, doc in enumerate(contexts):
                contexts_str += f"\n[Dokumen {i+1}] (Sumber: {doc.get('source', 'Unknown')})\n{doc.get('text', '')}\n"
            
            # 3. LLM Request System Prompt
            system_content = (
                "Anda adalah AI asisten apoteker SEHATI. Tugas Anda adalah memberikan 3 rekomendasi obat "
                "yang paling cocok berdasarkan gejala yang diinputkan pengguna dengan memanfaatkan database internal SEHATI.\n\n"
                "PENTING: Balas HANYA dengan format JSON ARRAY murni (tanpa markdown ```json ... ``` atau pembungkus lain). "
                "Setiap objek dalam array harus memiliki kunci-kunci berikut:\n"
                "- 'name': nama obat (misal: Paracetamol, Promag, dll)\n"
                "- 'type': jenis/kategori obat\n"
                "- 'desc': deskripsi singkat obat\n"
                "- 'indication': indikasi khasiat\n"
                "- 'dose': aturan pakai & dosis secara awam\n"
                "- 'side_effect': efek samping\n"
                "- 'warning': perhatian penggunaan\n"
                "- 'contra_indication': kontraindikasi\n"
                "- 'price': perkiraan harga (dalam bentuk string)\n"
                "- 'score': skor kecocokan (0.1 - 1.0)\n"
                "- 'reason': alasan pemilihan obat ini berdasarkan gejala pasien\n\n"
                "Database internal SEHATI:\n"
                f"{contexts_str}"
            )
            
            user_content = f"Berikan 3 rekomendasi obat terbaik dalam format JSON ARRAY murni untuk keluhan gejala berikut: {symptoms_str}"
            
            raw_response = None
            
            # Try Groq
            if not raw_response and groq_key:
                print("SymptomAnalyze: Trying Groq...")
                try:
                    url = "https://api.groq.com/openai/v1/chat/completions"
                    headers = {
                        "Authorization": f"Bearer {groq_key}",
                        "Content-Type": "application/json"
                    }
                    payload = {
                        "model": groq_model,
                        "messages": [
                            {"role": "system", "content": system_content},
                            {"role": "user", "content": user_content}
                        ],
                        "temperature": 0.2
                    }
                    res = requests.post(url, json=payload, headers=headers, timeout=20.0)
                    if res.status_code == 200:
                        raw_response = res.json().get("choices", [])[0].get("message", {}).get("content", "").strip()
                except Exception as e:
                    print(f"SymptomAnalyze: Groq error: {e}")
            
            # Try OpenRouter
            if not raw_response and api_key:
                print("SymptomAnalyze: Trying OpenRouter...")
                try:
                    url = "https://openrouter.ai/api/v1/chat/completions"
                    headers = {
                        "Authorization": f"Bearer {api_key}",
                        "Content-Type": "application/json",
                        "HTTP-Referer": "https://sehati-app.com",
                        "X-Title": "SEHATI Symptom Analyzer"
                    }
                    payload = {
                        "model": model_name,
                        "messages": [
                            {"role": "system", "content": system_content},
                            {"role": "user", "content": user_content}
                        ],
                        "temperature": 0.2
                    }
                    res = requests.post(url, json=payload, headers=headers, timeout=20.0)
                    if res.status_code == 200:
                        raw_response = res.json().get("choices", [])[0].get("message", {}).get("content", "").strip()
                except Exception as e:
                    print(f"SymptomAnalyze: OpenRouter error: {e}")
                    
            # Try Gemini
            if not raw_response and gemini_key:
                print("SymptomAnalyze: Trying Gemini...")
                try:
                    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={gemini_key}"
                    headers = {"Content-Type": "application/json"}
                    payload = {
                        "systemInstruction": {
                            "parts": [{"text": system_content}]
                        },
                        "contents": [
                            {"role": "user", "parts": [{"text": user_content}]}
                        ],
                        "generationConfig": {
                            "temperature": 0.2
                        }
                    }
                    res = requests.post(url, json=payload, headers=headers, timeout=20.0)
                    if res.status_code == 200:
                        raw_response = res.json().get("candidates", [])[0].get("content", {}).get("parts", [])[0].get("text", "").strip()
                except Exception as e:
                    print(f"SymptomAnalyze: Gemini error: {e}")
                    
            if not raw_response:
                raise Exception("All LLM providers failed or returned empty response.")
                
            # Log Activity
            new_activity = UserActivity(
                user_id=int(user_id),
                activity_type='symptom_check',
                description=f'Menganalisis gejala: {symptoms_str}'
            )
            db.session.add(new_activity)
            db.session.commit()
            
            # Clean JSON Response
            cleaned_response = raw_response.strip()
            if cleaned_response.startswith('```json'):
                cleaned_response = cleaned_response[7:]
            if cleaned_response.startswith('```'):
                cleaned_response = cleaned_response[3:]
            if cleaned_response.endswith('```'):
                cleaned_response = cleaned_response[:-3]
            cleaned_response = cleaned_response.strip()
                
            import json
            recommendations = json.loads(cleaned_response)
            return {
                'status': 'success',
                'symptoms': symptoms,
                'recommendations': recommendations
            }, 200
            
        except Exception as e:
            # Fallback to demo data if LLM or parsing fails
            print(f"Error in SymptomAnalyzeAPI: {str(e)}")
            return {
                'status': 'fallback',
                'symptoms': symptoms,
                'recommendations': [
                    {
                        'name': 'Paracetamol',
                        'type': 'Tablet generik',
                        'desc': 'Meredakan demam dan nyeri ringan.',
                        'indication': 'Demam, sakit kepala',
                        'dose': 'Ikuti aturan pakai pada kemasan.',
                        'side_effect': 'Mual ringan pada sebagian orang.',
                        'warning': 'Hindari penggunaan berlebihan.',
                        'score': 0.85,
                        'reason': f'Cocok untuk gejala {symptoms_str} (Mode Fallback)'
                    }
                ]
            }, 200
