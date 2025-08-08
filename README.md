# Projects Board Tenant Server

A Rails API backend for managing users and tasks with automatic priority classification using AI.

## Features

- **User Management**: Registration, authentication, and user profiles
- **Task Management**: Create, read, update, delete tasks with status tracking
- **AI Priority Classification**: Automatic task prioritization based on the 7 Habits of Highly Effective People / Eisenhower Matrix
- **Priority Levels**: Priority 1 (Urgent & Important), Priority 2 (Not Urgent & Important), Priority 3 (Urgent & Not Important), Priority 4 (Not Urgent & Not Important)

## Ruby Version

- Ruby 3.2.x (see `.ruby-version`)

## System Dependencies

- Bundler
- PostgreSQL (Neon for production, SQLite for development/test)
- Node.js (if using frontend locally)
- OpenAI API key (optional, for AI priority classification)

## Setup

1. Clone the repository
2. Run `bundle install`
3. Set up the database: `rails db:create db:migrate db:seed`
4. (Optional) Set `OPENAI_API_KEY` environment variable for AI priority classification

## AI Priority Classification

The system automatically classifies task priorities using OpenAI's GPT API based on task title and description. The classification follows the Eisenhower Matrix:

- **Priority 1**: Urgent & Important (Q1) - Do first
- **Priority 2**: Not Urgent & Important (Q2) - Schedule  
- **Priority 3**: Urgent & Not Important (Q3) - Delegate
- **Priority 4**: Not Urgent & Not Important (Q4) - Eliminate

### Configuration

To enable AI priority classification, set the `OPENAI_API_KEY` environment variable:

```bash
export OPENAI_API_KEY=your_openai_api_key_here
```

When no API key is configured, the system gracefully falls back to assigning "Priority 2" to all new tasks.

### Manual Override

Users can always manually specify a priority when creating or updating tasks, which will override the AI classification.

## Frontend

The recommended frontend for this API is available at:  
[https://github.com/jaganraajan/projects-board](https://github.com/jaganraajan/projects-board)

## API Endpoints

POST /register — Register a new user  
POST /login — Login and receive JWT token  
GET /me — Get current user info (requires JWT token)  
GET /users — List all users (requires JWT token)  
GET /tasks — List tasks (requires JWT token)  
POST /tasks — Create a task (requires JWT token)  
PATCH /tasks/:id — Update a task (requires JWT token)  
DELETE /tasks/:id — Delete a task (requires JWT token)  

## Deployment Instructions

Deploy to Render  
Set DATABASE_URL in Render to your Neon Postgres connection string  
Render will run bundle install && rails db:migrate automatically  

## Environment Variables

- `DATABASE_URL` — Your Neon Postgres connection string (production)
- `OPENAI_API_KEY` — Your OpenAI API key for automatic task priority classification (optional)

## Testing

Run the test suite:
```bash
rails test
```

Run specific test files:
```bash
rails test test/controllers/tasks_controller_test.rb
rails test test/services/ai_priority_classifier_test.rb
```

## Notes

CORS is configured for local development and production frontend domains.  
Authentication is token-based (JWT).  
See routes.rb for all available endpoints.