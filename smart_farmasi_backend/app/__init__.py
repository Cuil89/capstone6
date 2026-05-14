from flask import Flask
from app.models import db, bcrypt
from app.admin.views import init_admin
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_migrate import Migrate

def create_app():
    app = Flask(__name__)
    app.config.from_object('app.config')
    
    db.init_app(app)
    bcrypt.init_app(app)
    JWTManager(app)
    CORS(app)
    Migrate(app, db)
    
    from app.admin.auth import admin_auth
    app.register_blueprint(admin_auth)
    
    init_admin(app)
    
    from app.api.auth import (
        ConfirmEmailChangeAPI,
        ConfirmPasswordChangeAPI,
        ForgotPasswordAPI,
        LoginAPI,
        LoginGoogleAPI,
        ProfileAPI,
        RegisterAPI,
        RequestEmailChangeAPI,
        RequestAppPasswordAPI,
        RequestPasswordChangeAPI,
        ResendOTPAPI,
        ResetPasswordAPI,
        SetAppPasswordAPI,
        VerifyAppPasswordOTPAPI,
        VerifyOTPAPI,
    )
    from app.api.users import SaveActivityAPI
    from app.api.disease_news import (
        DiseaseNewsImageProxyAPI,
        DiseaseNewsTrendingAPI,
        DiseaseNewsListAPI,
        DiseaseNewsRefreshAPI,
    )
    
    from flask_restful import Api
    api = Api(app)
    api.add_resource(RegisterAPI, '/api/register', '/register')
    api.add_resource(VerifyOTPAPI, '/api/verify-otp', '/verify-otp')
    api.add_resource(ResendOTPAPI, '/api/resend-otp', '/resend-otp')
    api.add_resource(ForgotPasswordAPI, '/api/forgot-password')
    api.add_resource(ResetPasswordAPI, '/api/reset-password')
    api.add_resource(RequestAppPasswordAPI, '/api/request-app-password')
    api.add_resource(VerifyAppPasswordOTPAPI, '/api/verify-app-password-otp')
    api.add_resource(SetAppPasswordAPI, '/api/set-app-password')
    api.add_resource(RequestEmailChangeAPI, '/api/account/request-email-change')
    api.add_resource(ConfirmEmailChangeAPI, '/api/account/confirm-email-change')
    api.add_resource(RequestPasswordChangeAPI, '/api/account/request-password-change')
    api.add_resource(ConfirmPasswordChangeAPI, '/api/account/confirm-password-change')
    api.add_resource(LoginAPI, '/api/login')
    api.add_resource(LoginGoogleAPI, '/api/login/google')
    api.add_resource(ProfileAPI, '/api/profile')
    api.add_resource(SaveActivityAPI, '/api/activity')
    
    # Disease News endpoints
    api.add_resource(DiseaseNewsTrendingAPI, '/api/disease-news/trending')
    api.add_resource(DiseaseNewsListAPI,     '/api/disease-news')
    api.add_resource(DiseaseNewsRefreshAPI,  '/api/disease-news/refresh')
    api.add_resource(DiseaseNewsImageProxyAPI, '/api/disease-news/image')
    
    @app.route('/')
    def index():
        return """
        <html>
            <head>
                <title>Smart Farmasi API</title>
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #f0f2f5; }
                    .container { text-align: center; padding: 2rem; background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
                    h1 { color: #2c3e50; }
                    p { color: #7f8c8d; }
                    a { color: #3498db; text-decoration: none; font-weight: bold; }
                    a:hover { text-decoration: underline; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>💊 Smart Farmasi Backend</h1>
                    <p>API is running successfully.</p>
                    <p>Go to <a href="/admin">Admin Panel</a></p>
                </div>
            </body>
        </html>
        """
    
    # Start background scheduler for disease news auto-refresh and cleanup
    from app.scheduler import start_scheduler
    import os
    # Only run scheduler in main process (not Flask reloader subprocess)
    if os.environ.get('WERKZEUG_RUN_MAIN') != 'false':
        start_scheduler(app)
    
    return app
