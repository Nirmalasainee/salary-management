require 'rails_helper'

RSpec.describe Employee, type: :model do
  it "is valid with valid attributes" do
    expect(build(:employee)).to be_valid
  end

  it "requires a unique employee_number" do
    existing = create(:employee)
    duplicate = build(:employee, employee_number: existing.employee_number)

    expect(duplicate).not_to be_valid
  end

  describe "#current_salary" do
    it "returns the salary record with no end date" do
      employee = create(:employee)
      old_salary = create(:salary_record, employee: employee,
        effective_start_date: Date.new(2020, 1, 1),
        effective_end_date: Date.new(2021, 12, 31))
      current_salary = create(:salary_record, employee: employee,
        effective_start_date: Date.new(2022, 1, 1),
        effective_end_date: nil)

      expect(employee.current_salary).to eq(current_salary)
      expect(employee.current_salary).not_to eq(old_salary)
    end

    it "returns nil when no salary record exists" do
      employee = create(:employee)

      expect(employee.current_salary).to be_nil
    end
  end
end

