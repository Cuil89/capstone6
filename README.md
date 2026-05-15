# 💊 Smart Farmasi (Cureva)
> **Your Intelligent Health & Pharmacy Companion**

Smart Farmasi (Cureva) is a state-of-the-art HealthTech application designed to revolutionize how users interact with medical information, manage their health profiles, and stay informed about global health trends. Built with a premium aesthetic and powered by modern AI, it bridges the gap between technology and personal healthcare.

---

## ✨ Key Features

### 📱 Mobile Application (Flutter)
- **🤖 AI Health Assistant**: Real-time chatbot for medical inquiries and health guidance.
- **📰 Disease Insights**: A comprehensive feed of trending disease news, complete with severity alerts and regional filtering.
- **🔐 Advanced Authentication**: Secure login system featuring:
  - Google Sign-In integration.
  - Multi-Factor Authentication (OTP) via Email.
  - Secure App Passwords for enhanced security.
- **👤 Smart Profile Management**:
  - Custom profile pictures with secure cloud-ready storage.
  - Account deactivation with a 30-day safety "cool-down" period.
- **🎨 Premium UI/UX**: Designed with a mint-teal aesthetic, featuring smooth animations, glassmorphism, and responsive layouts.

### ⚙️ Backend Services (Python Flask)
- **🛠️ Robust API**: Scalable RESTful API architecture.
- **🛡️ Secure Foundation**: Environment-based configuration (No hardcoded secrets!).
- **📧 Automated Notifications**: Integrated SMTP services for OTP and account alerts.
- **📊 Admin Dashboard**: Full-featured administrative panel for managing users, news, and system settings.

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: [Flutter](https://flutter.dev/) (3.x+)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **Networking**: GetConnect
- **Design**: Vanilla CSS & Custom Widgets

### Backend
- **Framework**: [Flask](https://flask.palletsprojects.com/)
- **Database**: MySQL with SQLAlchemy ORM
- **Authentication**: JWT (JSON Web Tokens)
- **Migrations**: Flask-Migrate (Alembic)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Python 3.9+
- MySQL Server

### 1. Backend Setup
```bash
cd smart_farmasi_backend
python -m venv venv
source venv/bin/activate  # venv\Scripts\activate on Windows
pip install -r requirements.txt
```

**Configure Environment:**
Create a `.env` file in the `smart_farmasi_backend` folder based on `.env.example`:
```env
SECRET_KEY=your_secret_key
DATABASE_URL=mysql+pymysql://user:pass@localhost/db_name
MAIL_USERNAME=your_email
MAIL_PASSWORD=your_app_password
```

**Run Backend:**
```bash
python run.py
```

### 2. Frontend Setup
```bash
flutter pub get
flutter run
```

---

## 📁 Project Structure
```text
smart_farmasi1/
├── lib/                     # Flutter Mobile App source
│   ├── core/                # Themes, Routes, Configs
│   ├── data/                # Models & API Services
│   └── features/            # Modules (Auth, Home, Chatbot, etc.)
├── smart_farmasi_backend/   # Flask Backend source
│   ├── app/                 # Main Application logic
│   ├── migrations/          # DB Migration files
│   └── .env                 # Environment secrets (IGNORED)
└── assets/                  # Images & Illustrations
```

---

## 🛡️ Security
This project follows modern security best practices:
- **Zero Secrets Policy**: No sensitive keys are stored in the source code.
- **Input Validation**: Strict schema validation for all API endpoints.
- **Rate Limiting**: Protection against brute-force attacks on OTP and Login.

---

## 👥 Contributors
- **Capstone Team 6** - *Smart Farmasi Project*

---
*Developed for the Semester 6 Capstone Project.*
