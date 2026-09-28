require "rails_helper"

RSpec.describe "Api::V1::Reports", type: :request do
  before do
    create(:fx_snapshot, currency_code: "USD", rate_to_usd: 1.0, as_of_date: Date.new(2024, 1, 1))
  end

  describe "GET /api/v1/reports/summary" do
    it "returns org-wide payroll stats" do
      country = create(:country, currency_code: "USD")
      employee = create(:employee, country: country)
      create(:salary_record, employee: employee, amount: 80_000, currency_code: "USD", effective_end_date: nil)

      get "/api/v1/reports/summary"

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json["headcount"]).to eq(1)
      expect(json["total_payroll_usd"]).to eq(80_000.0)
    end
  end

  describe "GET /api/v1/reports/by_department" do
    it "returns per-department stats" do
      dept = create(:department, name: "Engineering")
      country = create(:country, currency_code: "USD")
      employee = create(:employee, department: dept, country: country)
      create(:salary_record, employee: employee, amount: 95_000, currency_code: "USD", effective_end_date: nil)

      get "/api/v1/reports/by_department"

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      eng = json.find { |g| g["label"] == "Engineering" }
      expect(eng["headcount"]).to eq(1)
    end
  end
end
