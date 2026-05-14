import os

try:
    from dotenv import load_dotenv
    load_dotenv(os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env'))
except ImportError:
    pass

SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root@127.0.0.1/smart_farmasi_db'
SQLALCHEMY_TRACK_MODIFICATIONS = False
JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-key-change-in-production'
NEWS_API_KEY = os.environ.get('NEWS_API_KEY') or ''

MAIL_USERNAME = os.environ.get('MAIL_USERNAME') or ''
MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD') or ''
MAIL_HOST = os.environ.get('MAIL_HOST') or 'smtp.gmail.com'
MAIL_PORT = int(os.environ.get('MAIL_PORT') or 587)
MAIL_USE_TLS = (os.environ.get('MAIL_USE_TLS') or 'true').lower() in ('true', '1', 'yes', 'on')
MAIL_USE_SSL = (os.environ.get('MAIL_USE_SSL') or 'false').lower() in ('true', '1', 'yes', 'on')
MAIL_DEFAULT_SENDER = os.environ.get('MAIL_DEFAULT_SENDER') or MAIL_USERNAME

OTP_EXPIRES_SECONDS = int(os.environ.get('OTP_EXPIRES_SECONDS') or 180)
OTP_RESEND_COOLDOWN_SECONDS = int(os.environ.get('OTP_RESEND_COOLDOWN_SECONDS') or 180)
OTP_MAX_ATTEMPTS = int(os.environ.get('OTP_MAX_ATTEMPTS') or 5)
ADMIN_OTP_REQUIRED = (os.environ.get('ADMIN_OTP_REQUIRED') or 'true').lower() in ('true', '1', 'yes', 'on')
OTP_BYPASS_EMAILS = {
    email.strip().lower()
    for email in (os.environ.get('OTP_BYPASS_EMAILS') or 'admin1@gmail.com').split(',')
    if email.strip()
}
