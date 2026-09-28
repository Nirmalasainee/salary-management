FactoryBot.define do
  factory :employee do
    sequence(:employee_number) { |n| "EMP#{n.to_s.rjust(5, '0')}" }
    first_name { "Jane" }
    last_name { "Doe" }
    sequence(:email) { |n| "employee#{n}@acme.test" }
    hire_date { Date.new(2020, 1, 1) }
    status { :active }
    country
    department
    job_level
  end
end
