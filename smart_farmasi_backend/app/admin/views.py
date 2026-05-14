from flask import session, redirect, url_for, request, flash
from flask_admin import Admin, expose, AdminIndexView
from flask_admin.contrib.sqla import ModelView
from flask_admin.theme import Bootstrap4Theme
from app.models import User, UserActivity, db
from .controllers import AdminController
from .components import AdminUIComponents

class MyHomeView(AdminIndexView):
    def is_accessible(self):
        return session.get('is_admin') == True

    def inaccessible_callback(self, name, **kwargs):
        flash('Please login to access the dashboard.', 'warning')
        return redirect(url_for('admin_auth.login', next=request.url))

    @expose('/')
    def index(self):
        stats = AdminController.get_dashboard_stats()
        recent_activities = AdminController.get_recent_activities()
        recent_users = AdminController.get_recent_users()
        
        return self.render('admin/index.html', 
                         total_users=stats.get('total_users', 0),
                         active_today=stats.get('active_today', 0),
                         total_scans=stats.get('total_scans', 0),
                         total_symptoms=stats.get('total_symptoms', 0),
                         total_consultations=stats.get('total_consultations', 0),
                         total_activities=stats.get('total_activities', 0),
                         recent_activities=recent_activities,
                         recent_users=recent_users)

    @expose('/users/<int:user_id>/delete', methods=['POST'])
    def delete_user(self, user_id):
        current_admin_id = session.get('user_id')
        success, message = AdminController.delete_user(user_id, current_admin_id)
        flash(message, 'success' if success else 'danger')
        return redirect(request.referrer or url_for('admin.index'))

class SecureModelView(ModelView):
    def is_accessible(self):
        return session.get('is_admin') == True

    def inaccessible_callback(self, name, **kwargs):
        flash('Unauthorized access.', 'danger')
        return redirect(url_for('admin_auth.login'))

class UserAdmin(SecureModelView):
    """View for managing users."""
    column_list = ['id', 'name', 'email', 'role', 'login_provider', 'created_at']
    column_searchable_list = ['name', 'email']
    form_columns = ['name', 'email', 'role', 'is_active', 'login_provider']
    
    column_formatters = {
        'created_at': AdminUIComponents.date_formatter,
        'role': lambda v, c, m, p: m.role.upper() if m.role else 'USER',
    }

    def delete_model(self, model):
        current_admin_id = session.get('user_id')
        success, message = AdminController.delete_user(model.id, current_admin_id)
        if not success:
            flash(message, 'danger')
        else:
            flash(message, 'success')
        return success

class ActivityAdmin(SecureModelView):
    """View for monitoring user activities."""
    column_list = ['id', 'user', 'activity_type', 'timestamp']
    column_filters = ['activity_type', 'user.email']
    
    column_formatters = {
        'activity_type': AdminUIComponents.status_badge_formatter,
        'timestamp': AdminUIComponents.date_formatter
    }

# Initialize the Admin instance with our custom Home View
admin = Admin(
    name='Smart Pharmacy', 
    index_view=MyHomeView(name='Dashboard', menu_icon_type='fa', menu_icon_value='fa-th-large'),
    theme=Bootstrap4Theme()
)

def init_admin(app):
    """Initializes the admin panel for the Flask app."""
    admin.init_app(app)
    
    # Add other views
    admin.add_view(UserAdmin(User, db.session, name='Users', menu_icon_type='fa', menu_icon_value='fa-users'))
    admin.add_view(ActivityAdmin(UserActivity, db.session, name='Activities', menu_icon_type='fa', menu_icon_value='fa-history'))
