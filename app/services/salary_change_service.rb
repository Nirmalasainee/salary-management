class SalaryChangeService
  Result = Struct.new(:success?, :salary_record, :errors, keyword_init: true)

  def initialize(employee:, amount:, currency_code:, effective_start_date:, change_reason:)
    @employee = employee
    @amount = amount
    @currency_code = currency_code
    @effective_start_date = effective_start_date
    @change_reason = change_reason
  end

  def call
    current = @employee.current_salary

    if current && @effective_start_date <= current.effective_start_date
      return failure(
        "effective_start_date must be after the current salary's " \
        "effective_start_date (#{current.effective_start_date})"
      )
    end

    new_record = nil

    ActiveRecord::Base.transaction do
      current&.update!(effective_end_date: @effective_start_date - 1.day)

      new_record = @employee.salary_records.create!(
        amount: @amount,
        currency_code: @currency_code,
        effective_start_date: @effective_start_date,
        effective_end_date: nil,
        change_reason: @change_reason
      )
    end

    Result.new(success?: true, salary_record: new_record, errors: [])
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, salary_record: nil, errors: e.record.errors.full_messages)
  end

  private

  def failure(message)
    Result.new(success?: false, salary_record: nil, errors: [message])
  end
end
