class FxSnapshot < ApplicationRecord
    validates :currency_code, presence: true, length: { is: 3 }
    validates :rate_to_usd, presence: true, numericality: { greater_than: 0 }
    validates :as_of_date, presence: true

    def self.latest_for(currency_code)
        where(currency_code: currency_code).order(as_of_date: :desc).first
    end
end
