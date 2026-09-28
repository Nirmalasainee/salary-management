require "rails_helper"

RSpec.describe SalaryRecord, type: :model do
  it "is valid with valid attributes" do
    expect(build(:salary_record)).to be_valid
  end

  it "requires effective_end_date to be after effective_start_date" do
    record = build(:salary_record,
      effective_start_date: Date.new(2024, 1, 1),
      effective_end_date: Date.new(2023, 1, 1))

    expect(record).not_to be_valid
    expect(record.errors[:effective_end_date]).to be_present
  end

  describe ".current" do
    it "returns only records with no end date" do
      employee = create(:employee)
      closed = create(:salary_record, employee: employee, effective_end_date: Date.new(2021, 12, 31))
      open = create(:salary_record, employee: employee, effective_start_date: Date.new(2022, 1, 1), effective_end_date: nil)

      expect(SalaryRecord.current).to contain_exactly(open)
      expect(SalaryRecord.current).not_to include(closed)
    end
  end
end
