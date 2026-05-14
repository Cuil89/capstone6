from app import create_app
from app.models import User

app = create_app()
with app.app_context():
    users = User.query.all()
    print("--- USER LIST ---")
    for u in users:
        print(f"ID: {u.id} | Email: {u.email} | Role: {u.role}")
    print("-----------------")
