import os
import time
import firebase_admin
from firebase_admin import credentials, db

# We will let the app run without breaking if keys aren't present yet,
# but print a loud warning. This is for local dev friendliness.
_firebase_initialized = False

def init_firebase():
    global _firebase_initialized
    if _firebase_initialized:
        return True
        
    try:
        # Load credentials from serviceAccountKey.json if present
        cred_path = os.environ.get("FIREBASE_CREDENTIALS", "serviceAccountKey.json")
        db_url = os.environ.get("FIREBASE_DB_URL", "https://MOCK_URL.firebaseio.com")
        
        abs_cred_path = os.path.abspath(cred_path)
        print(f"[FIREBASE DEBUG]: Checking for credentials at: {abs_cred_path}")
        print(f"[FIREBASE DEBUG]: Database URL: {db_url}")
        
        if not os.path.exists(cred_path):
            print(f"[FIREBASE WARNING]: '{abs_cred_path}' not found. Realtime DB streaming is disabled.")
            return False

        if "MOCK_URL" in db_url:
            print("[FIREBASE WARNING]: 'FIREBASE_DB_URL' not set globally. Ensure it is correct.")
            
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred, {
            'databaseURL': db_url
        })
        _firebase_initialized = True
        print("[FIREBASE REALTME DB]: Connected successfully.")
        return True
    except Exception as e:
        print(f"[FIREBASE ERROR]: Failed to initialize config: {e}")
        return False

def push_agent_message(session_id, agent_name, text):
    if not _firebase_initialized:
        return
    try:
        ref = db.reference(f'sessions/{session_id}/messages')
        ref.push({
            'agent': agent_name,
            'text': text,
            'timestamp': int(time.time() * 1000)
        })
    except Exception as e:
        print(f"[FIREBASE STREAM ERROR]: {e}")
