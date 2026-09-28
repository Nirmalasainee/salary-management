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
