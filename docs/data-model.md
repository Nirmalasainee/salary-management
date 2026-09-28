# Data Model

## Tables
- `countries` — id, name, currency_code
- `departments` — id, name
- `job_levels` — id, name, rank
- `employees` — id, employee_number, first_name, last_name, email,
  country_id, department_id, job_level_id, manager_id, hire_date, status
- `salary_records` — id, employee_id, amount, currency_code,
  effective_start_date, effective_end_date (NULL = current), change_reason
- `fx_snapshots` — id, currency_code, rate_to_usd, as_of_date

## Versioning rule
An employee's *current* salary is the `salary_records` row for that
employee with `effective_end_date IS NULL`. Changing salary means closing
the current row (`effective_end_date = new effective_start_date - 1.day`)
and inserting a new open-ended row — never mutating the old row's amount.
