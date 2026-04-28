# DebateWise 🎯

**AI-powered multi-agent debate platform** — watch Skeptic, Overexplainer, Questioner, and Arbiter agents debate any topic in real-time.

Built with **CrewAI**, **Gemini 3 Flash**, **Flutter Web**, and **Firebase Realtime Database**.

---

## Architecture

```
Flutter Web App  →  Firebase Realtime DB  →  Python CrewAI Backend
   (frontend/)           (cloud)               (backend/)
```

- **Frontend**: Flutter web app that sends user input and displays live agent messages
- **Backend**: Python listener that watches Firebase for new inputs, triggers a 4-agent CrewAI debate, and streams results back
- **Database**: Firebase Realtime Database as the real-time message bus

---

## Local Development

### Prerequisites
- Flutter SDK (3.x+)
- Python 3.11+
- Firebase project with Realtime Database enabled

### 1. Backend Setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

Create `backend/agents/.env`:
```env
GEMINI_API_KEY=your_gemini_api_key
FIREBASE_DB_URL=https://your-project-id.firebasedatabase.app
SERPER_API_KEY=your_serper_api_key
```

Place your `serviceAccountKey.json` in `backend/agents/`.

```bash
cd agents
python crew.py
```

### 2. Frontend Setup

```bash
cd frontend
flutter pub get
```

Create `frontend/.env`:
```env
FIREBASE_API_KEY=your_firebase_web_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_DATABASE_URL=https://your-project-id.firebasedatabase.app
```

```bash
flutter run -d chrome
```

---

## Deployment to GCP

### Frontend → Firebase Hosting

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Build the Flutter web app**:
   ```bash
   cd frontend
   flutter build web --release
   ```

3. **Deploy**:
   ```bash
   cd ..
   firebase deploy --only hosting
   ```

   Your app will be live at `https://solutionh2s.web.app`

### Backend → Google Cloud Run

1. **Build and push the Docker image**:
   ```bash
   cd backend
   gcloud builds submit --tag gcr.io/solutionh2s/debatewise-backend
   ```

2. **Deploy to Cloud Run**:
   ```bash
   gcloud run deploy debatewise-backend \
     --image gcr.io/solutionh2s/debatewise-backend \
     --platform managed \
     --region asia-south1 \
     --set-env-vars GEMINI_API_KEY=your_key,FIREBASE_DB_URL=your_url,SERPER_API_KEY=your_key \
     --allow-unauthenticated \
     --memory 1Gi \
     --timeout 600
   ```

   > **Note**: You also need to provide `serviceAccountKey.json` via Cloud Run secrets or mount it as a volume.

---

## Firebase Realtime Database Rules

For development/demo:
```json
{
  "rules": {
    ".read": "true",
    ".write": "true"
  }
}
```

> ⚠️ Tighten these rules before production use.

---

## Project Structure

```
DebateWise/
├── backend/
│   ├── agents/
│   │   ├── crew.py             # Main listener + CrewAI orchestration
│   │   ├── agents.py           # Agent definitions (Skeptic, etc.)
│   │   ├── tasks.py            # Task definitions for the crew
│   │   ├── firebase_config.py  # Firebase init + push helpers
│   │   ├── shadow_auditor.py   # Bias detection & rigor injection
│   │   └── tools.py            # Custom CrewAI tools
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .dockerignore
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── theme.dart
│   │   ├── firebase_options.dart
│   │   ├── screens/landing_page.dart
│   │   ├── widgets/debate_chat_widget.dart
│   │   ├── services/firebase_service.dart
│   │   └── models/message_model.dart
│   ├── web/index.html
│   ├── pubspec.yaml
│   └── .env
├── firebase.json
├── .firebaserc
├── .gitignore
└── README.md
```

---

## Team

Built by **Ctrl+Alt+Achieve** for the Google Solutions challenge.
