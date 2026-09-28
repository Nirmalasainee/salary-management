# Salary Management — Requirements

## Goal
Web-based software for ACME's HR Manager to manage salary data for 10,000
employees across multiple countries, replacing the current Excel-based
process, and to answer questions about how the organization pays people.

## Persona
HR Manager — single user role, no self-service or multi-tenant needs.

## In Scope
- Employee records: profile, country, department, job level, manager, status
- Versioned salary history per employee (every change preserved, not overwritten)
- Salary change workflow (new salary record with effective date + reason)
- Search / filter / paginate employees (by country, department, level, status)
- Org-wide pay analytics: headcount, total payroll cost, average/median
  salary by department, country, and job level
- Seed dataset of 10,000 employees for realistic-scale testing

## Deliberately Out of Scope (and why)
- **Live FX rates** — a static FX snapshot table is used instead; real-time
  rate integration is an external dependency unrelated to the core problem.
- **Payroll execution / tax calculation** — this is a salary *data
  management* tool, not a payment or tax engine.
- **Role-based access control / multi-tenant orgs** — the persona is a
  single HR Manager; RBAC adds complexity the brief doesn't ask for.
- **Employee self-service portal** — persona is explicitly HR-only.
- **Demographic pay-equity analytics** (e.g. gender pay gap) — no such data
  is specified in scope; adding protected-class fields without a stated
  requirement is both a scope risk and a data-sensitivity risk.
- **HRIS/payroll integrations** (Workday, ADP, etc.) — replaced by the seed
  script per the assessment brief.

## Key Questions the App Should Answer
- What is total payroll cost across the org (normalized to one currency)?
- How does average/median pay compare across departments, countries, levels?
- What is an individual employee's salary history over time?
