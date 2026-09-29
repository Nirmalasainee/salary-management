const API_BASE_URL = "http://localhost:3000/api/v1";

export type Summary = {
  headcount: number;
  total_payroll_usd: number;
  average_salary_usd: number;
  median_salary_usd: number;
};

export async function fetchSummary(): Promise<Summary> {
  const res = await fetch(`${API_BASE_URL}/reports/summary`);
  if (!res.ok) throw new Error(`Failed to fetch summary: ${res.status}`);
  return res.json();
}

export type Employee = {
  id: number;
  employee_number: string;
  first_name: string;
  last_name: string;
  email: string;
  status: string;
  hire_date: string;
  country: string;
  department: string;
  job_level: string;
};

export type PaginatedEmployees = {
  employees: Employee[];
  meta: { current_page: number; total_pages: number; total_count: number };
};

export type ReferenceOption = { id: number; name: string };
export type ReferenceData = {
  countries: ReferenceOption[];
  departments: ReferenceOption[];
  job_levels: ReferenceOption[];
};

export type EmployeeFilters = {
  page?: number;
  per_page?: number;
  search?: string;
  country_id?: number;
  department_id?: number;
  job_level_id?: number;
};

export async function fetchEmployees(filters: EmployeeFilters): Promise<PaginatedEmployees> {
  const params = new URLSearchParams();
  Object.entries(filters).forEach(([key, value]) => {
    if (value !== undefined && value !== "") params.set(key, String(value));
  });

  const res = await fetch(`${API_BASE_URL}/employees?${params.toString()}`);
  if (!res.ok) throw new Error(`Failed to fetch employees: ${res.status}`);
  return res.json();
}

export async function fetchReferenceData(): Promise<ReferenceData> {
  const res = await fetch(`${API_BASE_URL}/reference_data`);
  if (!res.ok) throw new Error(`Failed to fetch reference data: ${res.status}`);
  return res.json();
}
