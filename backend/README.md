# Seletta Backend

Node/Fastify API for the Seletta app, backed by local PostgreSQL and Prisma.

## Local setup

1. Create the local databases:

```sql
CREATE USER admin_local WITH PASSWORD 'your_password';
CREATE DATABASE seletta_local OWNER admin_local;
CREATE DATABASE seletta_shadow OWNER admin_local;
```

2. Copy `.env.example` to `.env` and set your real password in `DATABASE_URL` and `SHADOW_DATABASE_URL`.

3. Install dependencies and run migrations:

```powershell
npm.cmd install
npm.cmd run prisma:generate
npm.cmd run prisma:migrate -- --name init
npm.cmd run prisma:seed
npm.cmd run dev
```

## First endpoints

- `GET http://localhost:3333/api/v1/health`
- `GET http://localhost:3333/api/v1/home/brand-content`
- `GET http://localhost:3333/api/v1/home/featured-properties`
- `GET http://localhost:3333/api/v1/properties/search`
- `GET http://localhost:3333/api/v1/properties/:id`

## Notes

- Use `npm.cmd` in PowerShell if `npm.ps1` is blocked by Execution Policy.
- `.env` is local-only and must not be committed.
- Firebase Auth integration starts in the next backend slice with `/api/v1/me` and admin users.
