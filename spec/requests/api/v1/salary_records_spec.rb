require "rails_helper"

RSpec.describe "Api::V1::SalaryRecords", type: :request do
  describe "POST /api/v1/employees/:employee_id/salary_records" do
    it "creates the first salary record for a newly hired employee" do
      employee = create(:employee)

      post "/api/v1/employees/#{employee.id}/salary_records", params: {
        salary_record: {
          amount: 75_000,
          currency_code: "USD",
          effective_start_date: "2024-01-01",
          change_reason: "hire"
        }
      }

      expect(response).to have_http_status(:created)
      expect(employee.reload.current_salary.amount).to eq(75_000)
    end

    it "closes the old record and opens a new one on a raise" do
      employee = create(:employee)
      original = create(:salary_record, employee: employee,
        amount: 75_000,
        effective_start_date: Date.new(2024, 1, 1),
        effective_end_date: nil)

      post "/api/v1/employees/#{employee.id}/salary_records", params: {
        salary_record: {
          amount: 85_000,
          currency_code: "USD",
          effective_start_date: "2025-01-01",
          change_reason: "merit"
        }
      }

      expect(response).to have_http_status(:created)
      original.reload
      expect(original.effective_end_date).to eq(Date.new(2024, 12, 31))
      expect(employee.reload.current_salary.amount).to eq(85_000)
    end

    it "rejects an effective_start_date that doesn't come after the current record's" do
      employee = create(:employee)
      create(:salary_record, employee: employee, effective_start_date: Date.new(2024, 6, 1), effective_end_date: nil)

      post "/api/v1/employees/#{employee.id}/salary_records", params: {
        salary_record: {
          amount: 90_000,
          currency_code: "USD",
          effective_start_date: "2024-01-01",
          change_reason: "merit"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end

    it "rejects a malformed date without a 500" do
      employee = create(:employee)

      post "/api/v1/employees/#{employee.id}/salary_records", params: {
        salary_record: {
          amount: 75_000,
          currency_code: "USD",
          effective_start_date: "not-a-date",
          change_reason: "hire"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for a missing employee" do
      post "/api/v1/employees/999999/salary_records", params: {
        salary_record: { amount: 75_000, currency_code: "USD", effective_start_date: "2024-01-01", change_reason: "hire" }
      }

      expect(response).to have_http_status(:not_found)
    end
  end
end
