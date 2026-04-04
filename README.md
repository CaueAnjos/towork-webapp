# towork-webapp

Towork-Webapp is a task manager built as a portfolio project. It shows a modern
React frontend, an ASP.NET Core API, EF Core, and Nix-based development/build
tooling.

## What It Does

- Create, edit, complete, and delete tasks
- Keeps the UI responsive with optimistic updates
- Persists data in PostgreSQL through the backend API
- Runs locally with Nix so the whole stack is reproducible

## How It Works

- The frontend lives in `src/towork-ui` and is built with React, TypeScript,
  Vite, Tailwind, and React Query.
- The backend lives in `src/ToworkMVC` and exposes a REST API for task CRUD
  operations.
- EF Core handles database access, and the app stores tasks in PostgreSQL.
- The UI talks to the API through `src/towork-ui/src/ToworkApi.ts`.
- Task mutations use optimistic updates, so changes appear immediately in the UI
  before the server round trip completes.
- If a request fails, React Query rolls the cache back to the previous state.

## Portfolio Highlights

- Full-stack separation between UI, API, and data layer
- Strong TypeScript and C# typing
- Optimistic update flow with cache rollback
- Nix dev shell and Nix packages for repeatable setup
- Containerized database for local development

## Project Structure

- `flake.nix` - top-level Nix entrypoint
- `scripts/` - Nix-wrapped dev commands
- `packages/` - build outputs for the UI, backend, and Docker image
- `src/towork-ui/` - frontend app
- `src/ToworkMVC/` - backend app

## Requirements

- Nix
- Podman (provided by the Nix shell)
- Node.js and pnpm (provided by the Nix shell)
- .NET 10 SDK (provided by the Nix shell)

## Running Locally

Start the full app stack:

```bash
nix run .#dev
```

Start only the backend + database:

```bash
nix run .#dev:webapp
```

Start only the frontend:

```bash
nix run .#dev:ui
```

Start the database:

```bash
nix run .#dev:db-up
```

Stop the database:

```bash
nix run .#dev:db-down
```

## Build Commands

```bash
nix build .#ui
nix build .#mvc
nix build .#docker
```

## Frontend Commands

From `src/towork-ui`:

```bash
pnpm install
pnpm run dev
pnpm run build
pnpm run lint
```

## Backend Notes

- The backend uses ASP.NET Core controllers and EF Core services.
- `start-webapp` applies database migrations before launching the server.
- The API exposes task endpoints under `/api/Tasks`.

## Optimistic Updates

When you add, update, or delete a task, the UI updates first and then syncs with
the server. This makes the app feel fast and polished.

If the server rejects the change, React Query restores the previous cached
state.

## Development Flow

1. Open the Nix shell with `nix develop`
2. Run the full app with `nix run .#dev`
3. Edit the frontend or backend code
4. Use `nix build` commands to verify changes

## Notes

- This repo is intended for a portfolio showcase, so the README focuses on
  clarity and demo value.
- The UI and API are intentionally small and easy to understand.
