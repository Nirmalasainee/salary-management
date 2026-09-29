import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { describe, it, expect, vi, beforeEach } from "vitest";
import EmployeeListPage from "./EmployeeListPage";
import * as api from "../api";

vi.mock("../api");
const mockedApi = vi.mocked(api);

const sampleEmployee = {
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
};

describe("EmployeeListPage", () => {
  beforeEach(() => {
    mockedApi.fetchReferenceData.mockResolvedValue({
      countries: [{ id: 1, name: "United States", currency_code: "USD" }],
      departments: [{ id: 1, name: "Engineering" }],
      job_levels: [{ id: 1, name: "Senior" }],
    });

    mockedApi.fetchEmployees.mockResolvedValue({
      employees: [sampleEmployee],
      meta: { current_page: 1, total_pages: 1, total_count: 1 },
    });
  });

  it("renders fetched employees in the table", async () => {
    render(
      <MemoryRouter>
        <EmployeeListPage />
      </MemoryRouter>
    );

    expect(await screen.findByText("Alice")).toBeInTheDocument();
    expect(screen.getByText("Engineering")).toBeInTheDocument();
  });

  it("re-fetches with the search term when the user types", async () => {
    render(
      <MemoryRouter>
        <EmployeeListPage />
      </MemoryRouter>
    );

    await screen.findByText("Alice");

    const searchBox = screen.getByLabelText(/Search name, email, employee #/i);
    await userEvent.type(searchBox, "Bob");

    await waitFor(() => {
      expect(mockedApi.fetchEmployees).toHaveBeenLastCalledWith(
        expect.objectContaining({ search: "Bob" })
      );
    });
  });
});
