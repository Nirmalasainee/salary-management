# Architecture

## Overview

Two independently deployable pieces, communicating over a JSON REST API:

- **Backend**: Ruby on Rails 8 (API-only mode), SQLite
- **Frontend**: React 19 + TypeScript (Vite), MUI components, Recharts for charts

┌──────────────────────┐        HTTP (JSON)        ┌──────────────────────────┐
│  React SPA (Vite)     │ ───────────────────────▶ │  Rails API (--api mode)  │
│  localhost:5173+      │ ◀─────────────────────── │  localhost:3000          │
└──────────────────────┘                            └──────────┬───────────────┘
│
▼
┌───────────────┐
│ SQLite (dev)  │
└───────────────┘


## Backend layers

- **Controllers** (`app/controllers/api/v1/*`) — thin: parse params, call model/service, render JSON. No business logic.
- **Models** (`app/models/*`) — associations, validations, enums, small domain methods (`Employee#current_salary`, `SalaryRecord.current`).
- **Services** (`app/services/*`) — multi-step workflows that don't belong on a single model:
  - `SalaryChangeService` — atomically closes the current salary record and opens a new one (the versioning invariant).
  - `PayReportService` — aggregates headcount/payroll/avg/median across department/country/job-level, normalizing multi-currency amounts to USD.

## Data model

See `docs/data-model.md` for the table-level design. The core idea: an employee's salary is never overwritten — each change is a new `salary_records` row with an `effective_start_date`/`effective_end_date`, and "current" means `effective_end_date IS NULL`. A unique partial index enforces at most one current record per employee at the database level, not just in application code.

## Frontend

- `client/src/api.ts` — the only place `fetch` calls live; every page imports typed functions from here rather than calling `fetch` directly.
- `client/src/pages/` — one component per route (`EmployeeListPage`, `EmployeeDetailPage`, `AddEmployeePage`, `DashboardPage`).
- `client/src/components/Layout.tsx` — shared nav shell (`react-router-dom`'s `<Outlet />` pattern).
- Employee list pagination/filtering is server-side (`@mui/x-data-grid` in `paginationMode="server"`) — the client never holds more than one page (25–100 rows) of employees in memory, regardless of the 10,000-row dataset.

## Request flow: changing a salary

1. `EmployeeDetailPage` submits the salary-change form → `POST /api/v1/employees/:id/salary_records`.
2. `SalaryRecordsController#create` parses/validates the date, then calls `SalaryChangeService`.
3. The service runs inside a DB transaction: closes the old current record (`effective_end_date = new_start - 1.day`), inserts the new current record.
4. On success, the controller returns the new record; the frontend reloads the employee and the salary-history table reflects both rows.
5. On failure (bad date ordering, invalid amount), the transaction rolls back and the controller returns 422 with error messages, which the frontend surfaces inline.
