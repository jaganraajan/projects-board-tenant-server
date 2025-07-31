# Task Management API Endpoints

This API provides complete task management functionality for the project board application.

## Authentication

All task endpoints require authentication. You can authenticate using either:
- **Email parameter**: `?email=user@example.com`
- **Header**: `X-User-Email: user@example.com`

## Task Status Values

Tasks can have one of three status values:
- `todo` - Task is in the "To Do" column
- `in_progress` - Task is in the "In Progress" column  
- `done` - Task is in the "Done" column

## Endpoints

### GET /tasks
List all tasks for the authenticated user.

**Example Request:**
```bash
curl -X GET "http://localhost:3000/tasks?email=user@example.com"
```

**Example Response:**
```json
[
  {
    "id": 1,
    "title": "Fix login bug",
    "description": "The login form is not working properly",
    "status": "todo",
    "user_id": 1,
    "created_at": "2025-07-31T21:17:51.155Z",
    "updated_at": "2025-07-31T21:17:51.155Z"
  }
]
```

### GET /tasks/:id
Show a specific task (owner only).

**Example Request:**
```bash
curl -X GET "http://localhost:3000/tasks/1?email=user@example.com"
```

### POST /tasks
Create a new task.

**Required fields:** `title`, `status`
**Optional fields:** `description`

**Example Request:**
```bash
curl -X POST "http://localhost:3000/tasks?email=user@example.com" \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "title": "New Task",
      "description": "Task description",
      "status": "todo"
    }
  }'
```

### PATCH /tasks/:id
Update a task (perfect for dragging between columns).

**Example Request - Moving task to different column:**
```bash
curl -X PATCH "http://localhost:3000/tasks/1?email=user@example.com" \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "status": "in_progress"
    }
  }'
```

### DELETE /tasks/:id
Delete a task (owner only).

**Example Request:**
```bash
curl -X DELETE "http://localhost:3000/tasks/1?email=user@example.com"
```

**Example Response:**
```json
{
  "message": "Task deleted successfully"
}
```

## Error Responses

### Authentication Required (401)
```json
{
  "error": "Authentication required. Provide email parameter or X-User-Email header."
}
```

### Forbidden Access (403)
```json
{
  "error": "You can only access your own tasks."
}
```

### Task Not Found (404)
```json
{
  "error": "Task not found"
}
```

### Validation Errors (422)
```json
{
  "errors": ["Title can't be blank", "Status is not included in the list"]
}
```

## CORS Support

The API is configured for CORS to work with Next.js frontends running on:
- `http://localhost:3000`
- `https://projects-board-zeta.vercel.app`

All endpoints support the following HTTP methods: GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD