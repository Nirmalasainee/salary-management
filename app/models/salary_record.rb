class SalaryRecord < ApplicationRecord
    belongs_to :employee

    enum :change_reason, { hire: 0, merit: 1, promotion: 2, market_adjustment: 3 }

    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :currency_code, presence: true, length: { is: 3 }
    validates :effective_start_date, presence: true
    validate :effective_end_date_after_start_date

    scope :current, -> { where(effective_end_date: nil) }

    private

    def effective_end_date_after_start_date
        return if effective_end_date.blank?

        if effective_end_date <= effective_start_date
        errors.add(:effective_end_date, "must be after the effective start date")
        end
    end
end
