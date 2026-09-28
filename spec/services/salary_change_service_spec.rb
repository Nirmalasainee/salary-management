require "rails_helper"

RSpec.describe SalaryChangeService do
  describe "#call" do
    it "creates the first salary record when the employee has none yet" do
      employee = create(:employee)

      result = SalaryChangeService.new(
        employee: employee,
        amount: 75_000,
        currency_code: "USD",
        effective_start_date: Date.new(2024, 1, 1),
        change_reason: :hire
      ).call

      expect(result.success?).to be true
      expect(result.salary_record).to be_persisted
      expect(employee.current_salary).to eq(result.salary_record)
    end

    it "closes the current record and opens a new one on a salary change" do
      employee = create(:employee)
      original = create(:salary_record, employee: employee,
        amount: 75_000,
        effective_start_date: Date.new(2024, 1, 1),
        effective_end_date: nil)

      result = SalaryChangeService.new(
        employee: employee,
        amount: 85_000,
        currency_code: "USD",
        effective_start_date: Date.new(2025, 1, 1),
        change_reason: :merit
      ).call

      expect(result.success?).to be true
      original.reload
      expect(original.effective_end_date).to eq(Date.new(2024, 12, 31))
      expect(employee.current_salary.amount).to eq(85_000)
      expect(employee.current_salary).not_to eq(original)
    end

    it "rejects an effective_start_date that does not come after the current record's" do
      employee = create(:employee)
      original = create(:salary_record, employee: employee,
        effective_start_date: Date.new(2024, 6, 1),
        effective_end_date: nil)

      result = SalaryChangeService.new(
        employee: employee,
        amount: 90_000,
        currency_code: "USD",
        effective_start_date: Date.new(2024, 1, 1),
        change_reason: :merit
      ).call

      expect(result.success?).to be false
      expect(result.errors).to be_present
      original.reload
      expect(original.effective_end_date).to be_nil
      expect(employee.salary_records.count).to eq(1)
    end

    it "rejects an invalid amount and leaves the current record untouched" do
      employee = create(:employee)
      original = create(:salary_record, employee: employee,
        effective_start_date: Date.new(2024, 1, 1),
        effective_end_date: nil)

      result = SalaryChangeService.new(
        employee: employee,
        amount: -100,
        currency_code: "USD",
        effective_start_date: Date.new(2025, 1, 1),
        change_reason: :merit
      ).call

      expect(result.success?).to be false
      original.reload
      expect(original.effective_end_date).to be_nil
      expect(employee.salary_records.count).to eq(1)
    end
  end
end
