# FOCUS LIST - TASK MANAGER

A Flutter mobile app with Flask backend for managing time-limited tasks.

## 🎯 Overview

Complete task management system with automatic expiry:
- **Backend**: Flask REST API with SQLite3 database ✅ 
- **Frontend**: Flutter mobile app ✅
- **Database**: SQLite3 for persistence
- **Features**: Real-time timers, automatic task expiry

## 📁 Project Structure

```
focus_list_task_manager/
├── backend/                 # Flask API with SQLite3
│   ├── app.py              # Flask server (8 endpoints)
│   ├── application_server/ # Models
│   ├── business_logic/     # SQLite3 database operations
│   ├── operations/
│   │   └── tests/         # Backend test suite
│   │       ├── test_runner.py
│   │       ├── test_database.py
│   │       ├── test_models.py
│   │       └── test_app.py
│   └── tasks.db           # SQLite3 database
└── taskmanager/           # Flutter mobile app
    ├── lib/
    │   ├── config/        # App configuration
    │   ├── core/          # Core utilities & constants
    │   ├── data/          # Data layer & repositories
    │   ├── domain/        # Business logic & use cases
    │   ├── models/        # Data models
    │   ├── presentation/  # UI & state management
    │   ├── services/      # External services
    │   ├── theme/         # App theming
    │   ├── utils/         # Helper utilities
    │   └── main.dart
    └── test/              # Comprehensive Flutter tests
        ├── usecases/
        └── repositories/
        └── cubits/
```

## 🚀 Quick Start

### 1. Start Backend
```bash
cd backend
source venv/bin/activate
python app.py
# Server runs on: http://localhost:5007
```

### 2. Run Flutter App
```bash
cd taskmanager
flutter pub get
flutter run
```

### 3. Run Backend Tests
```bash
cd backend
python operations/tests/test_runner.py

# Or run individual test files
python operations/tests/test_database.py
python operations/tests/test_models.py
python operations/tests/test_app.py
```

### 4. Run Flutter Tests
```bash
cd taskmanager
flutter test

# Run specific test suites
flutter test test/domain/usecases/
flutter test test/presentation/cubits/
flutter test test/domain/repositories/
```

## ✨ Features

**Core Functionality:**
- ⏱️ Create tasks with time limits (1-120 minutes)
- 📊 Three sections: Active, Completed, Missed
- ⏰ Real-time countdown timers
- ✅ Mark tasks complete
- ❌ Auto-expiry to "Missed" section
- 🔔 Push notifications

**Technical:**
- 🏗️ Clean Architecture (Domain/Presentation layers)
- 🔄 State management with Cubit/Bloc
- 🧪 Comprehensive test coverage
- 🔌 Flask REST API integration
- 💾 SQLite3 database persistence

## 🌐 API Endpoints

**Base URL:** `http://localhost:5007`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/tasks` | Create task |
| GET | `/tasks` | Get all tasks |
| GET | `/tasks/{id}` | Get specific task |
| PUT | `/tasks/{id}/complete` | Mark complete |
| PUT | `/tasks/{id}/check-expiry` | Check expiry |
| DELETE | `/tasks/{id}` | Delete task |
| GET | `/tasks/stats` | Get statistics |

## 🧪 Testing

### Backend Tests (Flask + SQLite3)
```bash
cd backend

# Run all backend tests
python operations/tests/test_runner.py

# Run specific test modules
python operations/tests/test_database.py  # SQLite3 database tests
python operations/tests/test_models.py    # Task model tests
python operations/tests/test_app.py       # Flask API tests

# Run with verbose output
python -m unittest operations.tests.test_database -v
```

**Backend Test Coverage:**
- ✅ SQLite3 database operations (CRUD, validation)
- ✅ Task model logic (expiry, status transitions)
- ✅ Flask API endpoints (all 8 endpoints + error handling)
- ✅ Input validation and edge cases

### Flutter Tests
```bash
cd taskmanager

# Run all Flutter tests
flutter test

# Run specific test suites
flutter test test/domain/usecases/       # Business logic tests
flutter test test/presentation/cubits/  # State management tests
flutter test test/domain/repositories/  # Repository tests

# Run with coverage
flutter test --coverage
```

**Flutter Test Coverage:**
- ✅ Use cases (task operations, notifications)
- ✅ Cubits (state management for all screens)
- ✅ Repositories (data layer contracts)
- ✅ Integration between layers

## 📱 App Architecture

- **Domain Layer**: Use cases, repositories, entities
- **Presentation Layer**: Cubits, screens, widgets
- **Models**: Task, notification, response models
- **Tests**: Unit tests for all layers

Built with Flutter 3.x and Flask + SQLite3 following clean architecture principles.
