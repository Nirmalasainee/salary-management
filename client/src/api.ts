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

export type SalaryRecord = {
  id: number;
  amount: string;
  currency_code: string;
  effective_start_date: string;
  effective_end_date: string | null;
  change_reason: string;
};

export type EmployeeDetail = Employee & {
  manager_id: number | null;
  current_salary: SalaryRecord | null;
  salary_history: SalaryRecord[];
};

export async function fetchEmployee(id: number | string): Promise<EmployeeDetail> {
  const res = await fetch(`${API_BASE_URL}/employees/${id}`);
  if (!res.ok) throw new Error(`Failed to fetch employee: ${res.status}`);
  return res.json();
}

export type SalaryChangePayload = {
  amount: number;
  currency_code: string;
  effective_start_date: string;
  change_reason: string;
};

export async function createSalaryRecord(
  employeeId: number | string,
  payload: SalaryChangePayload
): Promise<SalaryRecord> {
  const res = await fetch(`${API_BASE_URL}/employees/${employeeId}/salary_records`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ salary_record: payload }),
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.errors?.join(", ") || `Failed to record salary change: ${res.status}`);
  }

  return res.json();
}

export type ReportGroup = {
  id: number;
  label: string;
  headcount: number;
  total_payroll_usd: number;
  average_salary_usd: number;
  median_salary_usd: number;
};

export async function fetchReportByDepartment(): Promise<ReportGroup[]> {
  const res = await fetch(`${API_BASE_URL}/reports/by_department`);
  if (!res.ok) throw new Error(`Failed to fetch department report: ${res.status}`);
  return res.json();
}

export async function fetchReportByCountry(): Promise<ReportGroup[]> {
  const res = await fetch(`${API_BASE_URL}/reports/by_country`);
  if (!res.ok) throw new Error(`Failed to fetch country report: ${res.status}`);
  return res.json();
}

export async function fetchReportByJobLevel(): Promise<ReportGroup[]> {
  const res = await fetch(`${API_BASE_URL}/reports/by_job_level`);
  if (!res.ok) throw new Error(`Failed to fetch job level report: ${res.status}`);
  return res.json();
}
