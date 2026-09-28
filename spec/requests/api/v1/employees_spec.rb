require "rails_helper"

RSpec.describe "Api::V1::Employees", type: :request do
  describe "GET /api/v1/employees" do
    it "returns paginated employees with meta" do
      create_list(:employee, 3)

      get "/api/v1/employees", params: { per_page: 2 }

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json["employees"].size).to eq(2)
      expect(json["meta"]["total_count"]).to eq(3)
      expect(json["meta"]["total_pages"]).to eq(2)
    end

    it "filters by department_id" do
      dept_a = create(:department)
      dept_b = create(:department)
      match = create(:employee, department: dept_a)
      create(:employee, department: dept_b)

      get "/api/v1/employees", params: { department_id: dept_a.id }

      json = JSON.parse(response.body)
      expect(json["employees"].map { |e| e["id"] }).to eq([match.id])
    end

    it "searches by name" do
      match = create(:employee, first_name: "Alice", last_name: "Wong")
      create(:employee, first_name: "Bob", last_name: "Smith")

      get "/api/v1/employees", params: { search: "Alice" }

      json = JSON.parse(response.body)
      expect(json["employees"].map { |e| e["id"] }).to eq([match.id])
    end
  end

  describe "GET /api/v1/employees/:id" do
    it "returns the employee with current salary and history" do
      employee = create(:employee)
      create(:salary_record, employee: employee, amount: 70_000,
        effective_start_date: Date.new(2022, 1, 1), effective_end_date: Date.new(2023, 12, 31))
      create(:salary_record, employee: employee, amount: 80_000,
        effective_start_date: Date.new(2024, 1, 1), effective_end_date: nil)

      get "/api/v1/employees/#{employee.id}"

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json["current_salary"]["amount"]).to eq("80000.0")
      expect(json["salary_history"].size).to eq(2)
    end

    it "returns 404 for a missing employee" do
      get "/api/v1/employees/999999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/employees" do
    it "creates an employee with valid params" do
      country = create(:country)
      department = create(:department)
      job_level = create(:job_level)

      post "/api/v1/employees", params: {
        employee: {
          employee_number: "EMP00001",
          first_name: "Alice",
          last_name: "Wong",
          email: "alice@acme.test",
          country_id: country.id,
          department_id: department.id,
          job_level_id: job_level.id,
          hire_date: "2024-01-01",
          status: "active"
        }
      }

      expect(response).to have_http_status(:created)
      expect(Employee.count).to eq(1)
    end

    it "returns 422 with errors for invalid params" do
      post "/api/v1/employees", params: { employee: { first_name: "Alice" } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end

  describe "PATCH /api/v1/employees/:id" do
    it "updates allowed profile fields" do
      employee = create(:employee, first_name: "Alice")

      patch "/api/v1/employees/#{employee.id}", params: { employee: { first_name: "Alicia" } }

      expect(response).to have_http_status(:ok)
      expect(employee.reload.first_name).to eq("Alicia")
    end
  end
end
