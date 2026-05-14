from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from enum import Enum
import datetime

db = SQLAlchemy()
bcrypt = Bcrypt()

class UserRole(Enum):
    USER = 'user'
    ADMIN = 'admin'

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=True)
    
    # New Fields
    role = db.Column(db.Enum('user', 'admin'), default='user', nullable=False)
    login_provider = db.Column(db.String(50), default='email') # 'email', 'google'
    firebase_uid = db.Column(db.String(255), unique=True, nullable=True)
    is_active = db.Column(db.Boolean, default=True)
    email_verified_at = db.Column(db.DateTime, nullable=True)
    is_verified = db.Column(db.Boolean, default=False, nullable=False)
    
    created_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    def __repr__(self):
        return f'<User {self.email}>'

    def set_password(self, password):
        self.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        if not self.password_hash:
            return False
        return bcrypt.check_password_hash(self.password_hash, password)

    def mark_email_verified(self):
        self.is_verified = True
        self.email_verified_at = datetime.datetime.utcnow()


class EmailOTP(db.Model):
    __tablename__ = 'email_otps'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    email = db.Column(db.String(120), nullable=False, index=True)
    purpose = db.Column(db.String(50), default='verify_email', nullable=False, index=True)
    otp_hash = db.Column(db.String(255), nullable=False)
    attempts = db.Column(db.Integer, default=0, nullable=False)
    expires_at = db.Column(db.DateTime, nullable=False)
    is_used = db.Column(db.Boolean, default=False, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    user = db.relationship(
        'User',
        backref=db.backref('email_otps', lazy=True, cascade='all, delete-orphan'),
    )

    def set_code(self, code):
        self.otp_hash = bcrypt.generate_password_hash(code).decode('utf-8')

    def check_code(self, code):
        return bcrypt.check_password_hash(self.otp_hash, code)

    @property
    def is_expired(self):
        return datetime.datetime.utcnow() > self.expires_at

class UserActivity(db.Model):
    __tablename__ = 'user_activities'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    activity_type = db.Column(db.String(50)) # 'login', 'logout', 'scan', 'symptom_check'
    description = db.Column(db.Text)
    timestamp = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    
    user = db.relationship(
        'User',
        backref=db.backref('activities', lazy=True, cascade='all, delete-orphan'),
    )


class AlertLevel(Enum):
    LOW = 'low'
    MEDIUM = 'medium'
    HIGH = 'high'


class DiseaseNews(db.Model):
    __tablename__ = 'disease_news'
    
    id           = db.Column(db.Integer, primary_key=True)
    title        = db.Column(db.String(500), nullable=False)
    disease_name = db.Column(db.String(200), nullable=True)
    summary      = db.Column(db.Text, nullable=True)
    country      = db.Column(db.String(200), nullable=True)
    source_name  = db.Column(db.String(100), nullable=False)  # 'WHO', 'CDC', 'Kemenkes', etc.
    source_url   = db.Column(db.String(1000), nullable=True)
    image_url    = db.Column(db.String(1000), nullable=True)
    alert_level  = db.Column(db.Enum('low', 'medium', 'high'), default='low', nullable=False)
    badge        = db.Column(db.String(50), nullable=True)   # 'Trending', 'Wabah Global', 'Update Terbaru', 'Perlu Diwaspadai'
    region_scope = db.Column(db.String(30), default='international', nullable=False)  # 'indonesia' | 'international'
    trend_score  = db.Column(db.Integer, default=0)
    trend_keyword = db.Column(db.String(200), nullable=True)
    is_trending  = db.Column(db.Boolean, default=False)
    view_count   = db.Column(db.Integer, default=0)
    published_at = db.Column(db.DateTime, nullable=True)
    fetched_at   = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    updated_at   = db.Column(db.DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)
    is_active    = db.Column(db.Boolean, default=True)

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'disease_name': self.disease_name,
            'summary': self.summary,
            'country': self.country,
            'source_name': self.source_name,
            'source_url': self.source_url,
            'image_url': self.image_url,
            'alert_level': self.alert_level,
            'badge': self.badge,
            'region_scope': self.region_scope,
            'trend_score': self.trend_score,
            'trend_keyword': self.trend_keyword,
            'is_trending': self.is_trending,
            'view_count': self.view_count,
            'published_at': self.published_at.isoformat() if self.published_at else None,
            'fetched_at': self.fetched_at.isoformat() if self.fetched_at else None,
        }

    def __repr__(self):
        return f'<DiseaseNews {self.title[:50]}>'
