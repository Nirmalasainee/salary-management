FactoryBot.define do
  factory :salary_record do
    employee
    amount { 80_000 }
    currency_code { "USD" }
    effective_start_date { Date.new(2020, 1, 1) }
    effective_end_date { nil }
    change_reason { :hire }
  end
end
