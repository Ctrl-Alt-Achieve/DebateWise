import os
import time
import json
import base64
import tempfile
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
        db_url = os.environ.get("FIREBASE_DB_URL", "https://MOCK_URL.firebaseio.com")
        
        # Priority 1: Base64-encoded credentials from env var (Render / Cloud Run)
        b64_creds = os.environ.get("FIREBASE_CREDENTIALS_BASE64", "")
        if b64_creds:
            print("[FIREBASE]: Using base64-encoded credentials from env var.")
            cred_json = json.loads(base64.b64decode(b64_creds).decode("utf-8"))
            cred = credentials.Certificate(cred_json)
        else:
            # Priority 2: Local file
            cred_path = os.environ.get("FIREBASE_CREDENTIALS", "serviceAccountKey.json")
            abs_cred_path = os.path.abspath(cred_path)
            print(f"[FIREBASE]: Checking for credentials at: {abs_cred_path}")
            
            if not os.path.exists(cred_path):
                print(f"[FIREBASE WARNING]: '{abs_cred_path}' not found. Realtime DB streaming is disabled.")
                return False
            
            cred = credentials.Certificate(cred_path)

        if "MOCK_URL" in db_url:
            print("[FIREBASE WARNING]: 'FIREBASE_DB_URL' not set. Ensure it is correct.")
            
        firebase_admin.initialize_app(cred, {
            'databaseURL': db_url
        })
        _firebase_initialized = True
        print(f"[FIREBASE]: Connected successfully to {db_url}")
        return True
    except Exception as e:
        print(f"[FIREBASE ERROR]: Failed to initialize: {e}")
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
