FOCUS LIST - TASK MANAGER WITH TIME LIMITS
==========================================

A Flutter mobile application with Python backend for managing tasks with time limits.
Tasks automatically move to different states based on completion status and time expiration.

PROJECT STRUCTURE
------------------
- backend/          Python Flask API server
- taskmanager/      Flutter mobile application
- readme.txt        
- readme.md        

PREREQUISITES
-------------
1. Python 3.8 or higher
2. Flutter SDK 3.0 or higher
3. Dart SDK (comes with Flutter)
4. Android Studio or VS Code
5. Android emulator or physical device

SETUP INSTRUCTIONS
==================

STEP 1: BACKEND SETUP (Python)
-------------------------------
1. Open terminal and navigate to the backend folder:
   cd backend

2. Create a virtual environment (recommended):
   python -m venv venv
   
3. Activate the virtual environment:
   # On macOS/Linux:
   source venv/bin/activate
   # On Windows:
   venv\Scripts\activate

4. Install required Python packages:
   pip install -r operations/requirements.txt

5. Make setup script executable and run it:
   chmod +x setup.sh
   ./setup.sh

6. Start the backend server:
   chmod +x start_server.sh
   ./start_server.sh or 
   python app.py

   The server will start on http://localhost:5007

STEP 2: FLUTTER FRONTEND SETUP
-------------------------------
1. Open a new terminal window and navigate to the Flutter app:
   cd taskmanager

2. Get Flutter dependencies:
   flutter pub get

3. Check if Flutter is properly configured:
   flutter doctor

4. Update the API configuration (if needed):
   Open: lib/config/api_config.dart
   Ensure baseUrl points to: http://localhost:5007

5. Start an Android emulator or connect a physical device

6. Run the Flutter application:
   flutter run

RUNNING THE APPLICATION
=======================

1. Ensure the Python backend is running (Step 1, item 6)
2. Ensure the Flutter app is running (Step 2, item 6)
3. The app should automatically connect to the backend API

TESTING THE APPLICATION
=======================

Flutter Tests:
--------------
1. Navigate to taskmanager folder:
   cd taskmanager

2. Run Flutter tests:
   flutter test

   Backend Tests:
--------------
1. Navigate to backend folder:
   cd backend

2. Run Python tests:
   python -m pytest operations/tests/ -v

FEATURES IMPLEMENTED
====================

Core Features:
- Home screen with Active, Completed, and Missed task sections
- Add new tasks with title and time limit (5-60 minutes)
- Real-time countdown timers for active tasks
- Manual task completion with "Mark as Done" button
- Automatic task expiration and movement to Missed section
- Backend API integration for all operations

State Management:
- ActiveTasksCubit for managing running tasks
- CompletedTasksCubit for completed tasks
- MissedTasksCubit for expired tasks

Bonus Features:
- Statistics screen showing task analytics
- Dark mode support
- Animated countdown timers
- Error handling and user feedback

API ENDPOINTS
=============
The backend provides the following REST API endpoints:

GET    /api/tasks                 Get all tasks
POST   /api/tasks                 Create a new task
PUT    /api/tasks/{id}/complete   Mark task as completed
PUT    /api/tasks/{id}/miss       Mark task as missed
DELETE /api/tasks/{id}            Delete a task
GET    /api/tasks/stats           Get task statistics

TROUBLESHOOTING
===============

Backend Issues:
- If port 5000 is in use, modify app.py to use a different port
- Ensure all dependencies are installed via requirements.txt
- Check Python version compatibility (3.8+)

Flutter Issues:
- Run 'flutter clean' then 'flutter pub get' if build fails
- Ensure Android emulator is running or device is connected
- Update API base URL in lib/config/api_config.dart if backend port changes
- Run 'flutter doctor' to check for missing dependencies

Connection Issues:
- Verify backend server is running on http://localhost:5007
- Check firewall settings
- Ensure both applications are running on the same network

DATABASE
========
The backend uses a simple local database that is automatically created when the server starts.
No additional database setup is required.

ARCHITECTURE
============
- Frontend: Flutter with Clean Architecture (Domain, Data, Presentation layers)
- State Management: Cubit (flutter_bloc)
- Backend: Python Flask with RESTful API design
- Data Storage: Local file-based storage
- Communication: HTTP REST API calls

ADDITIONAL NOTES
================
- The application automatically handles timer state management
- Tasks persist between app restarts via backend storage
- All time limits are in minutes (1-60 minute range)
- The app includes comprehensive error handling and user feedback
- Both frontend and backend include extensive testing coverage

For any issues or questions, please refer to the code comments or contact the developer.