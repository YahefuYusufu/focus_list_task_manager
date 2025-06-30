# FOCUS LIST - TASK MANAGER WITH TIME LIMITS

A complete Flutter mobile app with Python Flask backend for managing time-limited tasks.
Tasks automatically expire and move to "Missed" section when time runs out.

# 🎯 PROJECT OVERVIEW

This is a professional task management system consisting of:

- Python Flask REST API backend (COMPLETE ✅)
- Flutter mobile application (IN PROGRESS 🔄)
- SQLite database for local persistence
- Real-time countdown timers
- Automatic task expiry handling

# 📁 PROJECT STRUCTURE

focus_list_task_manager/
├── README.txt # This file - main instructions
├── backend/ # Python Flask API (COMPLETE)
│ ├── app.py # Main server (8 REST endpoints)
│ ├── application_server/
│ │ └── models.py # Task model with timer logic
│ ├── business_logic/
│ │ └── database.py # SQLite database operations
│ ├── operations/
│ │ ├── requirements.txt # Python dependencies
│ │ └── tests/ # Unit tests
│ ├── venv/ # Python virtual environment
│ └── tasks.db # SQLite database (auto-created)
└── flutter_app/ # Flutter mobile app (NEXT)
├── lib/
│ ├── main.dart # App entry point
│ ├── models/ # Dart models
│ ├── repositories/ # API communication
│ ├── cubits/ # State management (3 cubits)
│ ├── screens/ # UI screens
│ └── widgets/ # Reusable components
└── pubspec.yaml # Flutter dependencies

# 🚀 QUICK START

1. START BACKEND (Already Working!)

---

cd backend
source venv/bin/activate
python app.py

✅ Server runs on: http://localhost:5007
✅ Test with: curl http://localhost:5007/health

2. SETUP FLUTTER (Next Step)

---

flutter create flutter_app
cd flutter_app

# Add dependencies and build UI

# ✨ APP FUNCTIONALITIES

Core Features:

- ⏱️ Create tasks with custom time limits (1-60 minutes)
- 📊 Organize tasks in three sections: Active, Completed, Missed
- ⏰ Real-time countdown timers for active tasks
- ✅ Mark tasks as completed with "Mark as Done" button
- ❌ Automatic expiry - tasks move to "Missed" when time runs out
- 📱 Mobile-first design with Flutter
- 🔄 Real-time updates and state synchronization

User Experience:

- 🏠 Home screen with three clear sections
- ➕ Simple task creation with title and time picker
- 🎯 Visual countdown timers with progress indicators
- 📈 Task statistics and completion tracking
- 🎨 Professional UI with smooth animations
- 📲 Cross-platform mobile support (iOS & Android)

Technical Features:

- 🔌 RESTful API with 8 endpoints
- 💾 Local SQLite database persistence
- 🌐 CORS enabled for mobile integration
- 🔄 Automatic background task expiry checking
- ⚡ Efficient state management with Cubit pattern
- 🧪 Comprehensive error handling and validation

# 🌐 API ENDPOINTS (Complete Backend)

Base URL: http://localhost:5007

1. GET /health

   - Health check and server status
   - Returns: {"status": "healthy", "timestamp": "..."}

2. POST /tasks

   - Create new task with time limit
   - Body: {"title": "Task name", "time_limit_minutes": 30}
   - Returns: Task object with countdown info

3. GET /tasks

   - Get all tasks grouped by status
   - Returns: {"active": [...], "completed": [...], "missed": [...]}

4. GET /tasks/{id}

   - Get specific task by ID
   - Returns: Single task object with current status

5. PUT /tasks/{id}/complete

   - Mark task as completed
   - Returns: Updated task with "completed" status

6. PUT /tasks/{id}/check-expiry

   - Check if task has expired
   - Returns: Task status and expiry information

7. DELETE /tasks/{id}

   - Delete task permanently
   - Returns: Success confirmation message

8. GET /tasks/stats
   - Get task statistics and analytics
   - Returns: Total, active, completed, missed counts + completion rate

# 🧪 API TESTING

Quick test commands:

# Health check

curl http://localhost:5007/health

# Create task (30-second timer for testing)

curl -X POST http://localhost:5007/tasks \
 -H "Content-Type: application/json" \
 -d '{"title":"Quick Test","time_limit_minutes":0.5}'

# Get all tasks (watch countdown in real-time)

curl http://localhost:5007/tasks

# Mark task complete

curl -X PUT http://localhost:5007/tasks/1/complete

# Get statistics

curl http://localhost:5007/tasks/stats

# Delete task

curl -X DELETE http://localhost:5007/tasks/1

# 📱 FLUTTER REQUIREMENTS

Required packages for pubspec.yaml:

- flutter_bloc: ^8.1.3 (State management)
- equatable: ^2.0.5 (Value equality)
- http: ^1.1.0 (API calls)
- json_annotation: ^4.8.1 (JSON serialization)

Required Cubits:

- ActiveTasksCubit (manages active tasks)
- CompletedTasksCubit (manages completed tasks)
- MissedTasksCubit (manages expired tasks)

Required Screens:

- HomeScreen (3 sections display)
- AddTaskScreen (task creation form)

Required Widgets:

- TaskCard (individual task display)
- CountdownTimer (real-time timer)
- TaskSections (organized layout)

# 🎉 READY TO BUILD FLUTTER APP!

Your backend is production-ready and thoroughly tested.
Time to create an amazing Flutter UI that connects to your powerful API!

# 🔧 TROUBLESHOOTING

Backend Issues:

- Port conflict? Server auto-selects available port
- Import errors in IDE? Select correct Python interpreter
- Database issues? Delete tasks.db to recreate

Flutter Issues:

- Android emulator? Use http://10.0.2.2:5007
- iOS simulator? Use http://localhost:5007
- CORS errors? Backend already configured

# 📞 DEVELOPMENT NOTES

Backend (Production Ready):

- Professional Flask REST API
- Real-time task expiry handling
- SQLite database with proper schema
- Comprehensive error handling
- CORS optimized for mobile requests

Frontend (Ready to Build):

- Flutter project structure planned
- State management architecture designed
- API integration strategy defined
- UI/UX components mapped out
