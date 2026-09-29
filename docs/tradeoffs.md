
# Tradeoffs and Notable Decisions

## Scope tradeoffs (see REQUIREMENTS.md for the full list)
- Static FX snapshot table instead of a live rates API — one less external dependency/failure mode for a project whose core problem is salary *data management*, not currency trading.
- No RBAC — single HR Manager persona, as specified.
- No manager/org-chart hierarchy populated in the seed data — the schema supports `manager_id`, but no feature in scope displays reporting structure, so seeding it would have been speculative complexity.

## Engineering decisions

**Versioning via a history table, not event sourcing.** Salary changes are modeled as rows in `salary_records` with `effective_start_date`/`effective_end_date`, where "current" = open-ended. This is simpler to query and report on than a full event-sourced ledger, at the cost of not capturing *why* a change was made beyond the `change_reason` enum. Given the requirement is "salary history," not "full audit trail of every field," this was the right level of complexity.

**A unique partial index enforces the versioning invariant at the DB level** (`salary_records` has at most one row per employee with `effective_end_date IS NULL`), not just in `SalaryChangeService`. Application-level invariants that matter this much shouldn't rely solely on Ruby code being called correctly every time.

**Median computed in Ruby, not SQL.** SQLite has no `PERCENTILE_CONT`. Rather than write a fragile hand-rolled SQL median, `PayReportService` pulls the (small, per-group) set of already-`pluck`ed amounts and sorts them in Ruby. This is O(n log n) per report request on groups that are a small fraction of the 10,000 employees — acceptable for a reporting dashboard that isn't called on every page load, and far more maintainable than the SQL alternative.

**Multi-currency normalization happens once, in one service.** `PayReportService#fx_rates` builds a currency→USD-rate hash from `fx_snapshots` (a handful of rows) and reuses it across all group-by computations, rather than each report endpoint re-deriving conversion logic independently.

**Bulk `insert_all` for the 10,000-employee seed**, not `Employee.create!` in a loop. At this scale, per-record validations/callbacks/individual INSERTs would make seeding slow and wouldn't reflect how the app actually writes data at request time (single-record creates via the API, which *do* run validations). Batched in chunks of 1,000 to avoid one giant SQL statement.

**Server-side pagination in the employee list**, not client-side. With 10,000 employees, shipping the whole dataset to the browser and paginating in JS would be wasteful and slow; `@mui/x-data-grid`'s `paginationMode="server"` keeps the client holding only the current page.

## Real issues hit during the build (and why they came up)
- **`json` gem 3.0 dropped a keyword (`quirks_mode`) that Rails 8's `ActiveSupport::JSON` encoder still passes** — pinned `json` to `~> 2.9` in the Gemfile. Not a code bug; a dependency-version mismatch that surfaced immediately on the first `render json:` call.
- **A stale/incomplete `npm install` (run from the wrong directory at one point) produced an "Invalid hook call" error** that looked like a duplicate-React issue but was actually missing packages entirely — a reminder to verify `npm ls <package>` from the *actual* project directory rather than trust a successful-looking `npm install` output.
- **Vite auto-increments its dev port** (5173 → 5174) when something else holds the default port; the CORS config was changed from an exact-origin allowlist to a `localhost:<any port>` regex for local development only, to stop that from silently breaking API calls again.
- **MUI's `Stack` `mb` shorthand prop hit a TypeScript overload-resolution failure** in the installed MUI version — resolved by moving it into `sx={{ mb: 2 }}`, the one styling API that's stable across MUI versions.

## Performance considerations
- Reporting endpoints use `pluck` (raw arrays) instead of loading full `Employee`/`SalaryRecord` AR objects, keeping the 10,000-row aggregation lightweight.
- Employee list and detail queries use `includes`/`joins` to avoid N+1s on `country`/`department`/`job_level`.
- Seed timing was measured directly with `time bin/rails db:seed` rather than assumed, per the principle of not claiming a performance characteristic without measuring it.
