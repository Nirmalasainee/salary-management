import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { describe, it, expect, vi, beforeEach } from "vitest";
import EmployeeDetailPage from "./EmployeeDetailPage";
import * as api from "../api";

vi.mock("../api");
const mockedApi = vi.mocked(api);

const employee = {
  id: 1,
  employee_number: "EMP00001",
  first_name: "Alice",
  last_name: "Wong",
  email: "alice@acme.test",
  status: "active",
  hire_date: "2024-01-01",
  country: "United States",
  department: "Engineering",
  job_level: "Senior",
  manager_id: null,
  current_salary: {
    id: 10,
    amount: "90000.0",
    currency_code: "USD",
    effective_start_date: "2024-01-01",
    effective_end_date: null,
    change_reason: "hire",
  },
  salary_history: [
    {
      id: 10,
      amount: "90000.0",
      currency_code: "USD",
      effective_start_date: "2024-01-01",
      effective_end_date: null,
      change_reason: "hire",
    },
  ],
};

function renderPage() {
  return render(
    <MemoryRouter initialEntries={["/employees/1"]}>
      <Routes>
        <Route path="/employees/:id" element={<EmployeeDetailPage />} />
      </Routes>
    </MemoryRouter>
  );
}

describe("EmployeeDetailPage", () => {
  beforeEach(() => {
    mockedApi.fetchEmployee.mockResolvedValue(employee);
  });

  it("shows the employee's profile and current salary", async () => {
    renderPage();

    expect(await screen.findByText(/Alice Wong/)).toBeInTheDocument();
    expect(screen.getByText(/90000.0 USD/)).toBeInTheDocument();
  });

  it("submits a salary change with the entered values", async () => {
    mockedApi.createSalaryRecord.mockResolvedValue({
      id: 11,
      amount: "100000.0",
      currency_code: "USD",
      effective_start_date: "2025-01-01",
      effective_end_date: null,
      change_reason: "merit",
    });

    renderPage();
    await screen.findByText(/Alice Wong/);

    await userEvent.clear(screen.getByLabelText(/New amount/i));
    await userEvent.type(screen.getByLabelText(/New amount/i), "100000");
    await userEvent.clear(screen.getByLabelText(/Effective start date/i));
    await userEvent.type(screen.getByLabelText(/Effective start date/i), "2025-01-01");

    await userEvent.click(screen.getByRole("button", { name: /Save Salary Change/i }));

    await waitFor(() => {
      expect(mockedApi.createSalaryRecord).toHaveBeenCalledWith(
        "1",
        expect.objectContaining({ amount: 100000, effective_start_date: "2025-01-01" })
      );
    });
  });

  it("shows an error message when the API rejects the change", async () => {
    mockedApi.createSalaryRecord.mockRejectedValue(
      new Error("effective_start_date must be after the current salary's effective_start_date")
    );

    renderPage();
    await screen.findByText(/Alice Wong/);

    await userEvent.type(screen.getByLabelText(/New amount/i), "100000");
    await userEvent.type(screen.getByLabelText(/Effective start date/i), "2025-01-01");
    await userEvent.click(screen.getByRole("button", { name: /Save Salary Change/i }));

    expect(await screen.findByText(/effective_start_date must be after/i)).toBeInTheDocument();
  });

});
