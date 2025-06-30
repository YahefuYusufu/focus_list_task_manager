# Focus List Backend API Documentation

## Base URL

```
http://localhost:5007
```

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
	"error": "Error description"
}
```

## Rate Limiting

Currently no rate limiting (local development)

## CORS Policy

CORS enabled for all origins (development mode)

## Detailed Endpoint Documentation

### 1. GET /health

Health check and server status

**Request:**

- Method: GET
- Headers: None required
- Body: None

**Success Response (200):**

```json
{
	"status": "healthy",
	"timestamp": "2025-06-30T17:30:15.123456"
}
```

**Example:**

```bash
curl http://localhost:5007/health
```

---

### 2. POST /tasks

Create a new task with time limit

**Request:**

- Method: POST
- Headers: `Content-Type: application/json`

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

- 400: Missing title or time_limit_minutes
- 400: Title cannot be empty
- 400: Time limit must be positive
- 400: Invalid time_limit_minutes format

**Example:**

```bash
curl -X POST http://localhost:5007/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Complete homework","time_limit_minutes":30}'
```

---

### 3. GET /tasks

Retrieve all tasks grouped by status

**Request:**

- Method: GET
- Headers: None required
- Body: None

**Success Response (200):**

```json
{
	"active": [
		{
			"id": 1,
			"title": "Complete homework",
			"time_limit_minutes": 30,
			"created_at": "2025-06-30T16:24:16.414139",
			"expires_at": "2025-06-30T16:54:16.414139",
			"status": "active",
			"remaining_seconds": 1750
		}
	],
	"completed": [
		{
			"id": 2,
			"title": "Read book",
			"time_limit_minutes": 45,
			"created_at": "2025-06-30T15:00:00.123456",
			"expires_at": "2025-06-30T15:45:00.123456",
			"status": "completed",
			"remaining_seconds": 0
		}
	],
	"missed": [
		{
			"id": 3,
			"title": "Exercise",
			"time_limit_minutes": 60,
			"created_at": "2025-06-30T14:00:00.123456",
			"expires_at": "2025-06-30T15:00:00.123456",
			"status": "missed",
			"remaining_seconds": 0
		}
	]
}
```

**Example:**

```bash
curl http://localhost:5007/tasks
```

---

### 4. GET /tasks/{id}

Get a specific task by ID

**Request:**

- Method: GET
- URL Parameters: `id` (integer, required)
- Headers: None required
- Body: None

**Success Response (200):**

```json
{
	"task": {
		"id": 1,
		"title": "Complete homework",
		"time_limit_minutes": 30,
		"created_at": "2025-06-30T16:24:16.414139",
		"expires_at": "2025-06-30T16:54:16.414139",
		"status": "active",
		"remaining_seconds": 1750
	}
}
```

**Error Responses:**

- 404: Task not found

**Example:**

```bash
curl http://localhost:5007/tasks/1
```

---

### 5. PUT /tasks/{id}/complete

Mark a task as completed

**Request:**

- Method: PUT
- URL Parameters: `id` (integer, required)
- Headers: None required
- Body: None

**Success Response (200):**

```json
{
	"message": "Task completed successfully",
	"task": {
		"id": 1,
		"title": "Complete homework",
		"time_limit_minutes": 30,
		"created_at": "2025-06-30T16:24:16.414139",
		"expires_at": "2025-06-30T16:54:16.414139",
		"status": "completed",
		"remaining_seconds": 0
	}
}
```

**Alternative Response (200) - If task was already expired:**

```json
{
	"message": "Task was expired and marked as missed",
	"task": {
		"id": 1,
		"title": "Complete homework",
		"time_limit_minutes": 30,
		"created_at": "2025-06-30T16:24:16.414139",
		"expires_at": "2025-06-30T16:54:16.414139",
		"status": "missed",
		"remaining_seconds": 0
	}
}
```

**Error Responses:**

- 404: Task not found
- 400: Task is already completed/missed

**Example:**

```bash
curl -X PUT http://localhost:5007/tasks/1/complete
```

---

### 6. PUT /tasks/{id}/check-expiry

Check and update task expiry status

**Request:**

- Method: PUT
- URL Parameters: `id` (integer, required)
- Headers: None required
- Body: None

**Success Response (200) - Task expired:**

```json
{
	"message": "Task expired and marked as missed",
	"task": {
		"id": 1,
		"title": "Complete homework",
		"time_limit_minutes": 30,
		"created_at": "2025-06-30T16:24:16.414139",
		"expires_at": "2025-06-30T16:54:16.414139",
		"status": "missed",
		"remaining_seconds": 0
	},
	"status_changed": true
}
```

**Success Response (200) - Task not expired:**

```json
{
	"message": "Task status unchanged",
	"task": {
		"id": 1,
		"title": "Complete homework",
		"time_limit_minutes": 30,
		"created_at": "2025-06-30T16:24:16.414139",
		"expires_at": "2025-06-30T16:54:16.414139",
		"status": "active",
		"remaining_seconds": 1750
	},
	"status_changed": false
}
```

**Error Responses:**

- 404: Task not found

**Example:**

```bash
curl -X PUT http://localhost:5007/tasks/1/check-expiry
```

---

### 7. DELETE /tasks/{id}

Delete a task permanently

**Request:**

- Method: DELETE
- URL Parameters: `id` (integer, required)
- Headers: None required
- Body: None

**Success Response (200):**

```json
{
	"message": "Task deleted successfully"
}
```

**Error Responses:**

- 404: Task not found

**Example:**

```bash
curl -X DELETE http://localhost:5007/tasks/1
```

---

### 8. GET /tasks/stats

Get task statistics and analytics

**Request:**

- Method: GET
- Headers: None required
- Body: None

**Success Response (200):**

```json
{
	"total_tasks": 5,
	"active_tasks": 2,
	"completed_tasks": 2,
	"missed_tasks": 1,
	"completion_rate": 40.0
}
```

**Example:**

```bash
curl http://localhost:5007/tasks/stats
```

---

## Task Object Schema

All task objects returned by the API follow this structure:

```json
{
	"id": "integer - Unique task identifier",
	"title": "string - Task title/description",
	"time_limit_minutes": "integer - Original time limit in minutes",
	"created_at": "string - ISO timestamp when task was created",
	"expires_at": "string - ISO timestamp when task expires",
	"status": "string - Current status: 'active', 'completed', or 'missed'",
	"remaining_seconds": "integer - Seconds remaining (0 if not active)"
}
```

## Status Transitions

```
[CREATE] → active
active → completed (via /complete endpoint)
active → missed (automatically when expired)
```

## Error Handling

All errors return appropriate HTTP status codes:

- **400 Bad Request**: Invalid input data
- **404 Not Found**: Resource doesn't exist
- **500 Internal Server Error**: Server-side errors

## Development Notes

- **Automatic Expiry**: Tasks are automatically checked for expiry on every API call
- **Real-time Countdown**: The `remaining_seconds` field provides real-time countdown data
- **CORS Enabled**: Ready for Flutter mobile app integration
- **No Authentication**: Simplified for local development
- **SQLite Database**: Data persists between server restarts
