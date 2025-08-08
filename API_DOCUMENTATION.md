# Task Management API Endpoints

This API provides complete task management functionality for the project board application with automatic priority classification based on the 7 Habits of Highly Effective People.

## Authentication

All task endpoints require authentication. You can authenticate using either:
- **Email parameter**: `?email=user@example.com`
- **Header**: `X-User-Email: user@example.com`

## Task Status Values

Tasks can have one of three status values:
- `todo` - Task is in the "To Do" column
- `in_progress` - Task is in the "In Progress" column  
- `done` - Task is in the "Done" column

## Task Priority Values

Tasks are automatically assigned priorities based on the Eisenhower Matrix (7 Habits of Highly Effective People):
- `Priority 1` - Urgent & Important (Q1)
- `Priority 2` - Not Urgent & Important (Q2) 
- `Priority 3` - Urgent & Not Important (Q3)
- `Priority 4` - Not Urgent & Not Important (Q4)

Priority is automatically classified when creating tasks using AI analysis of the title and description. You can also manually override the priority by providing it in the request.

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
    "priority": "Priority 1",
    "due_date": null,
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
Create a new task with automatic priority classification.

**Required fields:** `title`, `status`
**Optional fields:** `description`, `priority`, `due_date`

**Note:** If no `priority` is provided, the system will automatically classify the priority based on the task title and description using AI analysis following the Eisenhower Matrix principles.

**Example Request:**
```bash
curl -X POST "http://localhost:3000/tasks?email=user@example.com" \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "title": "Fix critical production bug",
      "description": "Database connection failure affecting all users",
      "status": "todo"
    }
  }'
```

**Example Response:**
```json
{
  "id": 2,
  "title": "Fix critical production bug",
  "description": "Database connection failure affecting all users",
  "status": "todo",
  "priority": "Priority 1",
  "due_date": null,
  "user_id": 1,
  "created_at": "2025-08-08T05:15:30.000Z",
  "updated_at": "2025-08-08T05:15:30.000Z"
}
```

**Manual Priority Override:**
```bash
curl -X POST "http://localhost:3000/tasks?email=user@example.com" \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "title": "Plan next quarter goals",
      "description": "Strategic planning session",
      "status": "todo",
      "priority": "Priority 2"
    }
  }'
```

### PATCH /tasks/:id
Update a task (perfect for dragging between columns or changing priority).

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

**Example Request - Updating priority:**
```bash
curl -X PATCH "http://localhost:3000/tasks/1?email=user@example.com" \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "priority": "Priority 3"
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