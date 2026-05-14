from app.models import User, UserActivity, EmailOTP, db
from datetime import datetime

class AdminController:
    """
    Controller handling the business logic for the Admin Dashboard.
    Provides stats specifically for Smart Pharmacy features.
    """
    
    @staticmethod
    def get_dashboard_stats():
        """Fetches aggregated data for Smart Pharmacy features."""
        total_users = User.query.count()
        today = datetime.now().date()
        new_users_today = User.query.filter(db.func.date(User.created_at) == today).count()
        
        # Feature-specific stats from Activity Logs
        total_scans = UserActivity.query.filter_by(activity_type='scan').count()
        total_symptoms = UserActivity.query.filter_by(activity_type='symptom_check').count()
        total_consultations = UserActivity.query.filter_by(activity_type='chatbot').count()
        
        return {
            'total_users': total_users,
            'active_today': new_users_today,
            'total_scans': total_scans,
            'total_symptoms': total_symptoms,
            'total_consultations': total_consultations,
            'total_activities': UserActivity.query.count()
        }

    @staticmethod
    def get_recent_activities(limit=10):
        """Fetches the most recent user activities."""
        return UserActivity.query.order_by(UserActivity.timestamp.desc()).limit(limit).all()

    @staticmethod
    def get_recent_users(limit=8):
        """Fetches the newest users for quick admin actions."""
        return User.query.order_by(User.created_at.desc()).limit(limit).all()

    @staticmethod
    def delete_user(user_id, current_admin_id=None):
        """Deletes a user and their dependent records safely."""
        user = User.query.get(user_id)
        if not user:
            return False, 'User tidak ditemukan.'

        if current_admin_id and user.id == current_admin_id:
            return False, 'Anda tidak bisa menghapus akun admin yang sedang digunakan.'

        if user.role == 'admin':
            admin_count = User.query.filter_by(role='admin').count()
            if admin_count <= 1:
                return False, 'Tidak bisa menghapus admin terakhir.'

        user_email = user.email
        try:
            EmailOTP.query.filter_by(user_id=user.id).delete(synchronize_session=False)
            UserActivity.query.filter_by(user_id=user.id).delete(synchronize_session=False)
            User.query.filter_by(id=user.id).delete(synchronize_session=False)
            db.session.commit()
            return True, f'User {user_email} berhasil dihapus.'
        except Exception as exc:
            db.session.rollback()
            return False, f'Gagal menghapus user: {exc}'
