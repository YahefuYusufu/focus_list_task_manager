# FOCUS LIST - TASK MANAGER

A Flutter mobile app with Python Flask backend for managing time-limited tasks.

## 🎯 Overview

Complete task management system with automatic expiry:
- **Backend**: Python Flask REST API ✅ 
- **Frontend**: Flutter mobile app ✅
- **Database**: SQLite for persistence
- **Features**: Real-time timers, automatic task expiry

## 📁 Project Structure

```
focus_list_task_manager/
├── backend/                 # Python Flask API
│   ├── app.py              # Main server (8 endpoints)
│   ├── application_server/ # Models
│   ├── business_logic/     # Database operations
│   ├── operations/
│   │   └── tests/         # Backend test suite
│   │       ├── test_runner.py
│   │       ├── test_database.py
│   │       ├── test_models.py
│   │       └── test_app.py
│   └── tasks.db           # SQLite database
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
        ├── domain/
        │   ├── usecases/
        │   └── repositories/
        └── presentation/
            └── cubits/
```
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
- 🔌 RESTful API integration
- 💾 Local data persistence

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

```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/domain/usecases/
flutter test test/presentation/cubits/
flutter test test/domain/repositories/
```

## 📱 App Architecture

- **Domain Layer**: Use cases, repositories, entities
- **Presentation Layer**: Cubits, screens, widgets
- **Models**: Task, notification, response models
- **Tests**: Unit tests for all layers

Built with Flutter 3.x and following clean architecture principles.
