# Focus List Backend API Documentation

## Authentication
Currently no authentication required (local development)

## Response Format
All endpoints return JSON with consistent structure:

### Success Response
```json
{
  "message": "Success message",
  "data": {...}
}
```

### Error Response
```json
{
  "error": "Error description",
  "code": 400
}
```

## Rate Limiting
Currently no rate limiting (local development)

## CORS Policy
CORS enabled for all origins (development mode)

## Detailed Endpoint Documentation

### POST /tasks
Create a new task with time limit

**Request Body:**
```json
{
  "title": "string (required, 1-255 chars)",
  "time_limit_minutes": "integer (required, 1-1440)"
}
```

**Success Response (201):**
```json
{
  "message": "Task created successfully",
  "task": {
    "id": 1,
    "title": "Complete homework",
    "time_limit_minutes": 30,
    "created_at": "2025-06-30T16:24:16.414139",
    "expires_at": "2025-06-30T16:54:16.414139",
    "status": "active",
    "remaining_seconds": 1800
  }
}
```

**Error Responses:**
- 400: Missing required fields
- 400: Invalid time_limit_minutes

### GET /tasks
Retrieve all tasks grouped by status

**Success Response (200):**
```json
{
  "active": [...tasks],
  "completed": [...tasks],
  "missed": [...tasks]
}
```

### PUT /tasks/{id}/complete
Mark a task as completed

**Success Response (200):**
```json
{
  "message": "Task completed successfully",
  "task": {...}
}
```

**Error Responses:**
- 404: Task not found
- 400: Task already completed/missed
