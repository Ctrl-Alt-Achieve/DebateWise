import firebase_admin
from firebase_admin import credentials, db
import os
import json

def check_db():
    cred_path = r"C:\Users\ritvi\.gemini\antigravity\scratch\DebateWise\backend\agents\serviceAccountKey.json"
    if not os.path.exists(cred_path):
        print(f"Credentials not found at {cred_path}")
        return

    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://solutionh2s-default-rtdb.asia-southeast1.firebasedatabase.app/'
    })

    ref = db.reference('sessions/default_session/inputs')
    data = ref.get()
    print("Database Snapshot (sessions/default_session/inputs):")
    print(json.dumps(data, indent=2))

if __name__ == "__main__":
    check_db()
