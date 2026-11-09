# Sample Vue Frontend

Minimal Vue 3 + Vite SPA that consumes the Laravel sample API in `app/rest`. It is the frontend workload for the CodeBuild/CodeDeploy pipeline in `task-2/`.

This directory is a **separate Git repository** from the repository root.

## Data sources

| Backend endpoint | Usage |
|---|---|
| `GET /api/health` | Status card, service name, server timestamp |
| `GET /api/users` | Users table |

The browser calls `/api/...` on the same origin. In production, Nginx proxies those paths to the Laravel container over the private Docker network.

## Local development

Start the backend first:

```sh
cd app/rest
php artisan serve --host=127.0.0.1 --port=8000
```

Then the frontend:

```sh
cd app/frontend
npm install
npm run dev
```

Vite runs on `http://127.0.0.1:5173` and proxies `/api` and `/sanctum` to `http://127.0.0.1:8000`, so no CORS configuration is needed.

## Build

```sh
npm run build
```

Output is written to `dist/`. `VITE_API_BASE_URL` defaults to `/api`; override it only if the API lives on another origin.

```sh
VITE_API_BASE_URL=/api npm run build
```

There are no automated tests in this sample project.

## Container

```sh
npm run build
docker build -t vue-rest-sample .
docker run --rm -p 8080:80 vue-rest-sample
```

The image uses `nginx:1.27-alpine`, serves `dist/`, and proxies `/api`, `/sanctum`, and `/broadcasting` to the backend container `laravel-app:80` on the `laravel-app-net` Docker network.

## CodeBuild and CodeDeploy

Included pipeline assets:

- `buildspec.yml` — installs dependencies, builds `dist/`, builds/pushes the image, packages the CodeDeploy revision, and starts the deployment.
- `frontend-appspec.yml` — CodeDeploy hooks.
- `scripts/frontend_*.sh` — stop, pull, start, and validate the container.
- `Dockerfile` and `frontend-nginx.conf`.

The CodeBuild project provides `ECR_REPOSITORY_URI`, `ECR_REGION`, `APPSPEC_S3_BUCKET`, `CODEDEPLOY_APPLICATION_NAME`, and `CODEDEPLOY_DEPLOYMENT_GROUP_NAME`. The frontend container publishes host port 8080 and is registered with the ALB target group.
