FactoryBot.define do
  factory :fx_snapshot do
    currency_code { "USD" }
    rate_to_usd { 1.0 }
    as_of_date { Date.today }
  end
end
