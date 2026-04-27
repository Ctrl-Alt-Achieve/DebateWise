**VIEW IN CODE MODE**

debatewise/
│
├── frontend/                     # Flutter Web App
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── debate_screen.dart
│   │   │   └── result_screen.dart
│   │   │
│   │   ├── widgets/
│   │   │   ├── chat_bubble.dart
│   │   │   ├── agent_card.dart
│   │   │   └── input_box.dart
│   │   │
│   │   ├── services/
│   │   │   ├── firebase_service.dart   # read/write to DB (message bus)
│   │   │   └── state_manager.dart
│   │   │
│   │   └── main.dart
│   │
│   ├── web/                      # Flutter web entry
│   │   └── index.html
│   │
│   ├── build/web/                # Generated after build
│   │
│   ├── pubspec.yaml
│   └── .env                      # frontend configs (optional)
│
├── backend/                      # CrewAI Backend (Python)
│   ├── app/
│   │   ├── main.py               # entry point (listener loop)
│   │   ├── config.py             # env + constants
│   │   │
│   │   ├── firebase/
│   │   │   ├── firebase_client.py   # connect to Firebase
│   │   │   └── listener.py          # listens to new messages
│   │   │
│   │   ├── agents/
│   │   │   ├── moderator.py
│   │   │   ├── debater_pro.py
│   │   │   ├── debater_con.py
│   │   │   └── summarizer.py
│   │   │
│   │   ├── crew/
│   │   │   └── crew_setup.py     # CrewAI orchestration
│   │   │
│   │   ├── services/
│   │   │   ├── debate_engine.py  # core logic
│   │   │   └── response_writer.py
│   │   │
│   │   └── utils/
│   │       └── helpers.py
│   │
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── .env                      # API keys (local only)
│   └── serviceAccountKey.json    # Firebase (DO NOT COMMIT)
│
├── firebase/                     # Firebase Config
│   ├── firebase.json
│   ├── .firebaserc
│   └── firestore.rules / db.rules.json
│
├── infra/                        # Deployment configs (optional but clean)
│   ├── cloudrun.yaml
│   ├── secrets.env
│   └── docker-compose.yml        # for local testing
│
├── scripts/                      # Dev & deployment helpers
│   ├── build_frontend.sh
│   ├── deploy_backend.sh
│   └── deploy_frontend.sh
│
├── .gitignore
├── README.md
└── LICENSE
