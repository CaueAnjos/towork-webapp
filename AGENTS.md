# Agent Guide for `towork-webapp`

This file is for agentic coding helpers working in this repo.
It captures the repo-specific workflow, build/test commands, and
the coding conventions observed in the codebase.

## Scope

- Repo root: `/home/kawid/projects/towork-webapp`
- Frontend app: `src/towork-ui`
- Backend app: `src/ToworkMVC`
- Nix is the primary entrypoint for development, builds, and runtime tasks.
- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` files were present when this file was written.

## High-Level Layout

- `flake.nix`: defines the dev shell, apps, and packages.
- `scripts/`: Nix-wrapped dev commands (`start-webapp`, `start-ui`, DB helpers).
- `packages/`: build outputs for the UI, MVC app, and Docker image.
- `src/towork-ui/`: Vite + React + TypeScript frontend.
- `src/ToworkMVC/`: ASP.NET Core + EF Core backend.
- Do not edit generated output in `dist/`, `bin/`, or `obj/` unless explicitly required.

## Nix Workflow

- Enter the dev shell with `nix develop`.
- The shell includes .NET 10 SDK, CSharpier, Node.js 20, pnpm 9, Podman tooling, and Azure CLI.
- The shell sets `DOCKER_COMMAND=podman` and `ASPNETCORE_ENVIRONMENT=Development`.
- Use Nix commands from the repo root unless a script explicitly changes directories.

## Run Commands

- Start the full webapp stack: `nix run .#dev`
- Start the backend + database: `nix run .#dev:webapp`
- Start only the frontend: `nix run .#dev:ui`
- Start the Postgres container: `nix run .#dev:db-up`
- Stop the Postgres container: `nix run .#dev:db-down`
- Build the UI package: `nix build .#ui`
- Build the MVC package: `nix build .#mvc`
- Build the Docker image: `nix build .#docker`

## Frontend Commands

- Frontend working directory: `src/towork-ui`
- Install dependencies: `pnpm install`
- Start Vite directly: `pnpm dev`
- Build the frontend: `pnpm run build`
- Lint the frontend: `pnpm run lint`
- Preview a production build: `pnpm preview`

## Backend Commands

- Backend working directory: `src/ToworkMVC`
- The repo uses `dotnet watch run` through the Nix `start-webapp` script.
- Database migrations are applied by the webapp start script with `dotnet ef database update --project src/ToworkMVC`.
- The backend container image is produced from `packages/docker_img.nix`.

## Single-File / Single-Test Guidance

- Single frontend file lint: `pnpm exec eslint src/App.tsx`
- Single frontend type check: `pnpm exec tsc -p tsconfig.app.json --noEmit`
- Single backend test (when tests exist): `dotnet test --filter FullyQualifiedName~Namespace.ClassName.MethodName`
- Single backend project test run: `dotnet test <path-to-test-project.csproj>`
- There is no checked-in frontend test runner yet; if one is added, prefer its name filter for one test only.
- If you add a new test suite, document the exact per-test command in this file.

## Formatting and Style

- Match the existing style in the file you touch before introducing new patterns.
- Avoid repo-wide reformatting unless the user asks for it.
- Prefer small, targeted diffs.
- Keep imports grouped and sorted logically: third-party first, then local.
- Remove unused imports, parameters, and locals; TypeScript and C# both enforce this strongly here.

## TypeScript / React Conventions

- Use ES modules and file extensions in local imports, e.g. `./ToworkApi.ts`.
- Keep TypeScript strict; avoid `any` unless there is no reasonable alternative.
- Prefer explicit types for public functions, async helpers, and API payloads.
- Use `type`-only imports when importing only types.
- Use PascalCase for React components and camelCase for hooks, handlers, and variables.
- Keep component state local unless there is a clear sharing need.
- Use `React.FC` only if it fits the surrounding code; otherwise match the local pattern.
- Preserve current quote style in nearby files; the codebase currently leans on double quotes in TS/TSX.
- Keep JSX readable with small, composable components over deeply nested markup.
- Use `className` conditionals sparingly and keep long Tailwind class strings aligned for readability.

## Frontend Error Handling

- Throw `Error` objects in API helpers when responses are not OK.
- Let React Query own retries, invalidation, and loading/error state.
- Use optimistic updates only when you also provide a rollback path in `onError`.
- If a mutation changes cached data, invalidate the related query key after settlement.
- Surface user-facing failures with a concise message; avoid exposing raw server errors in the UI.

## Frontend Data Flow

- Keep server communication in `ToworkApi.ts` or a similarly focused module.
- Map backend IDs to stable client IDs when the UI needs React keys.
- Prefer immutable updates when editing cached arrays or objects.
- Keep query keys stable and centralized by feature.
- Use React Query selectors for derived data when it keeps components simpler.

## C# / ASP.NET Conventions

- Use file-scoped namespaces, as the backend already does.
- Keep types in PascalCase: controllers, services, DTOs, models, and records.
- Keep private fields prefixed with `_`.
- Preserve nullable annotations and the project’s `enable`-nullable posture.
- Follow the existing primary-constructor style in services/controllers where practical.
- Prefer `async Task` / `Task<T>` for I/O and EF operations.
- Use explicit return types on public methods.
- Keep DTOs separate from EF entities; convert between them explicitly.

## Backend Error Handling

- Return the most specific HTTP result available: `NotFound`, `BadRequest`, `NoContent`, `Created`, `Ok`.
- Validate inputs early and fail fast before touching the database.
- Keep EF changes inside the service layer when possible.
- Treat `null` lookups as expected control flow for missing records.
- Do not swallow exceptions; either handle them intentionally or let the framework surface them.

## Naming Conventions

- Components and C# types: `PascalCase`
- Functions, methods, variables, hooks: `camelCase`
- Constants: `UPPER_SNAKE_CASE` when they are true constants.
- Keep file names aligned with the primary export or top-level type when practical.
- Use descriptive names for query keys, API methods, and DTOs.

## Dependency and Package Notes

- Frontend dependencies are managed with pnpm in `src/towork-ui/pnpm-lock.yaml`.
- The backend uses .NET/NuGet through the `ToworkMVC.csproj` project file.
- Avoid introducing new package managers or lockfiles.
- If you add a dependency, document why it is needed in the change summary.

## Database / Local Dev Notes

- The dev scripts expect a local Postgres container named `towork-webapp-db`.
- DB credentials are hardcoded in `scripts/start-up-db.bash`; do not change them casually.
- Start the DB before running the backend locally.
- Use the Nix app wrappers instead of hand-assembling podman or dotnet commands when possible.

## Editing Checklist

- Read the relevant source file before editing.
- Keep changes narrowly scoped to the requested task.
- Update tests, scripts, or docs when behavior changes.
- Verify with the smallest useful command first, then run broader checks if needed.
- Do not commit generated artifacts or local build outputs.

## Practical Defaults

- If you need a fast sanity check, run `nix build .#ui` or `pnpm run lint` in `src/towork-ui`.
- If you are touching backend code, prefer `nix run .#dev:webapp` or `dotnet watch run` via the repo scripts.
- If you are changing shared behavior, inspect both the UI and MVC sides.
- When in doubt, mirror the conventions already used in the nearest file.
