# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

COUNTRIES = [
  { name: "United States", currency_code: "USD" },
  { name: "United Kingdom", currency_code: "GBP" },
  { name: "Germany", currency_code: "EUR" },
  { name: "India", currency_code: "INR" },
  { name: "Canada", currency_code: "CAD" },
  { name: "Australia", currency_code: "AUD" }
].freeze

FX_RATES_TO_USD = {
  "USD" => 1.0, "GBP" => 1.27, "EUR" => 1.09,
  "INR" => 0.012, "CAD" => 0.74, "AUD" => 0.66
}.freeze

DEPARTMENTS = [
  "Engineering", "Sales", "Marketing", "Finance", "Human Resources",
  "Customer Support", "Product", "Legal", "Operations", "IT"
].freeze

JOB_LEVELS = [
  { name: "Associate", rank: 1, band: 45_000..60_000 },
  { name: "Analyst",   rank: 2, band: 60_000..80_000 },
  { name: "Senior",    rank: 3, band: 80_000..110_000 },
  { name: "Lead",      rank: 4, band: 110_000..140_000 },
  { name: "Manager",   rank: 5, band: 140_000..180_000 },
  { name: "Director",  rank: 6, band: 180_000..250_000 }
].freeze

puts "Seeding reference data..."

countries = COUNTRIES.map do |c|
  Country.find_or_create_by!(name: c[:name]) { |r| r.currency_code = c[:currency_code] }
end

departments = DEPARTMENTS.map { |d| Department.find_or_create_by!(name: d) }

job_levels = JOB_LEVELS.map do |l|
  JobLevel.find_or_create_by!(name: l[:name]) { |r| r.rank = l[:rank] }
end

FX_RATES_TO_USD.each do |currency_code, rate|
  FxSnapshot.find_or_create_by!(currency_code: currency_code, as_of_date: Date.current) do |snap|
    snap.rate_to_usd = rate
  end
end

puts "Reference data ready: #{countries.size} countries, #{departments.size} departments, #{job_levels.size} job levels."


if Employee.exists?
  puts "Employees already seeded (#{Employee.count} present) — skipping."
else
  puts "Seeding 10,000 employees..."

  EMPLOYEE_COUNT = 10_000
  BATCH_SIZE = 1_000
  now = Time.current

  (1..EMPLOYEE_COUNT).each_slice(BATCH_SIZE) do |batch_numbers|
    rows = batch_numbers.map do |n|
      country = countries.sample
      department = departments.sample
      job_level = job_levels.sample
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      hire_date = Faker::Date.between(from: 8.years.ago, to: 1.month.ago)

      {
        employee_number: "EMP#{n.to_s.rjust(5, '0')}",
        first_name: first_name,
        last_name: last_name,
        email: "#{first_name.downcase}.#{last_name.downcase}.#{n}@acme-demo.test",
        country_id: country.id,
        department_id: department.id,
        job_level_id: job_level.id,
        manager_id: nil,
        hire_date: hire_date,
        status: Employee.statuses[:active],
        created_at: now,
        updated_at: now
      }
    end

    Employee.insert_all!(rows)
    print "."
  end
  puts " employees done."

  puts "Seeding salary history..."

  job_level_bands = JOB_LEVELS.each_with_object({}) { |l, h| h[l[:name]] = l[:band] }
  job_levels_by_id = job_levels.index_by(&:id)
  countries_by_id = countries.index_by(&:id)

  salary_rows = []

  Employee.pluck(:id, :country_id, :job_level_id, :hire_date).each do |id, country_id, job_level_id, hire_date|
    country = countries_by_id[country_id]
    job_level = job_levels_by_id[job_level_id]
    band = job_level_bands[job_level.name]
    fx_rate = FX_RATES_TO_USD.fetch(country.currency_code)

    hire_usd = rand(band)
    hire_local = (hire_usd / fx_rate).round(2)

    hire_record = {
      employee_id: id,
      amount: hire_local,
      currency_code: country.currency_code,
      effective_start_date: hire_date,
      effective_end_date: nil,
      change_reason: SalaryRecord.change_reasons[:hire],
      created_at: now,
      updated_at: now
    }
    salary_rows << hire_record

    next unless hire_date < 1.year.ago && rand < 0.4

    raise_date = hire_date + rand(1..3).years
    next if raise_date >= Date.current

    raise_usd = (hire_usd * (1 + rand(5..20) / 100.0)).round
    raise_local = (raise_usd / fx_rate).round(2)

    hire_record[:effective_end_date] = raise_date - 1.day

    salary_rows << {
      employee_id: id,
      amount: raise_local,
      currency_code: country.currency_code,
      effective_start_date: raise_date,
      effective_end_date: nil,
      change_reason: SalaryRecord.change_reasons[:merit],
      created_at: now,
      updated_at: now
    }
  end

  salary_rows.each_slice(BATCH_SIZE) { |batch| SalaryRecord.insert_all!(batch) && print(".") }
  puts " salary records done."

  puts "Seeded #{Employee.count} employees with #{SalaryRecord.count} salary records."
end
