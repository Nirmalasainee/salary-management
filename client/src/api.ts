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
