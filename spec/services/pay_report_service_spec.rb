require "rails_helper"

RSpec.describe PayReportService do
  before do
    create(:fx_snapshot, currency_code: "USD", rate_to_usd: 1.0, as_of_date: Date.new(2024, 1, 1))
    create(:fx_snapshot, currency_code: "EUR", rate_to_usd: 1.1, as_of_date: Date.new(2024, 1, 1))
  end

  describe "#summary" do
    it "computes headcount, total, average, and median across currencies" do
      dept = create(:department)
      level = create(:job_level)
      country_us = create(:country, currency_code: "USD")
      country_eu = create(:country, currency_code: "EUR")

      e1 = create(:employee, department: dept, country: country_us, job_level: level)
      create(:salary_record, employee: e1, amount: 100_000, currency_code: "USD", effective_end_date: nil)

      e2 = create(:employee, department: dept, country: country_eu, job_level: level)
      create(:salary_record, employee: e2, amount: 100_000, currency_code: "EUR", effective_end_date: nil)

      summary = PayReportService.new.summary

      expect(summary[:headcount]).to eq(2)
      expect(summary[:total_payroll_usd]).to eq(210_000.0)
      expect(summary[:average_salary_usd]).to eq(105_000.0)
      expect(summary[:median_salary_usd]).to eq(105_000.0)
    end

    it "excludes employees without a current salary record" do
      create(:employee)

      summary = PayReportService.new.summary

      expect(summary[:headcount]).to eq(0)
    end
  end

  describe "#by_department" do
    it "groups totals by department" do
      dept_a = create(:department, name: "Engineering")
      dept_b = create(:department, name: "Sales")
      country = create(:country, currency_code: "USD")
      level = create(:job_level)

      e1 = create(:employee, department: dept_a, country: country, job_level: level)
      create(:salary_record, employee: e1, amount: 90_000, currency_code: "USD", effective_end_date: nil)

      e2 = create(:employee, department: dept_b, country: country, job_level: level)
      create(:salary_record, employee: e2, amount: 70_000, currency_code: "USD", effective_end_date: nil)

      groups = PayReportService.new.by_department
      eng = groups.find { |g| g.label == "Engineering" }

      expect(eng.headcount).to eq(1)
      expect(eng.total_usd).to eq(90_000.0)
    end
  end
end
