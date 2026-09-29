# Salary Management

HR salary management system for ACME (10,000 employees, multi-country), built as a take-home assessment.

See:
- [REQUIREMENTS.md](./REQUIREMENTS.md) — goal, scope, and what was deliberately left out
- [docs/data-model.md](./docs/data-model.md) — table design and the versioning rule
- [docs/architecture.md](./docs/architecture.md) — system overview and request flow
- [docs/tradeoffs.md](./docs/tradeoffs.md) — engineering decisions and performance notes
- [docs/ai-prompts.md](./docs/ai-prompts.md) — how AI tooling was used to build this

## Stack

- Backend: Ruby 3.2 / Rails 8 (API-only), SQLite
- Frontend: React 19 + TypeScript (Vite), MUI, Recharts

## Setup

Every terminal needs this gemset fix before running any `rails`/`bundle` command:

```bash
export GEM_HOME=/home/bacancy/.rvm/gems/ruby-3.2.0
export GEM_PATH=/home/bacancy/.rvm/gems/ruby-3.2.0:/home/bacancy/.rvm/gems/ruby-3.2.0@global
export PATH=/home/bacancy/.rvm/gems/ruby-3.2.0/bin:/home/bacancy/.rvm/gems/ruby-3.2.0@global/bin:/home/bacancy/.rvm/rubies/ruby-3.2.0/bin:$PATH
```

### Backend

```bash
bundle install
bin/rails db:migrate
bin/rails db:seed   # seeds reference data + 10,000 employees with salary history
bin/rails s         # http://localhost:3000
```

### Frontend

```bash
cd client
npm install
npm run dev         # http://localhost:5173
```

## Tests

Backend:

```bash
bundle exec rspec
```

Frontend:

```bash
cd client
npm run test
```

## Project structure

```
app/                  Rails backend (controllers, models, services)
config/               Routes, CORS, initializers
db/                   Migrations, seeds
spec/                 RSpec (model/service/request specs)
client/               React frontend (Vite + TypeScript)
  src/api.ts           All fetch calls to the backend
  src/pages/           One component per route
  src/components/      Shared layout/nav
docs/                 Architecture, tradeoffs, AI-usage notes
```
