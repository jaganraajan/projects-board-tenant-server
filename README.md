# Projects Board Tenant Server

A Rails API backend for managing users and tasks.

## Ruby Version

- Ruby 3.2.x (see `.ruby-version`)

## System Dependencies

- Bundler
- PostgreSQL (Neon for production, local or Neon for development)
- Node.js (if using frontend locally)

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

DATABASE_URL — Your Neon Postgres connection string

## Notes

CORS is configured for local development and production frontend domains.  
Authentication is token-based (JWT).  
See routes.rb for all available endpoints.