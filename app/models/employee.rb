class Employee < ApplicationRecord
    belongs_to :country
    belongs_to :department
    belongs_to :job_level
    belongs_to :manager, class_name: "Employee", optional: true
    has_many :direct_reports, class_name: "Employee", foreign_key: :manager_id
    has_many :salary_records, dependent: :destroy

    enum :status, { active: 0, terminated: 1 }

    validates :employee_number, presence: true, uniqueness: true
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :hire_date, presence: true

    def current_salary
        salary_records.find_by(effective_end_date: nil)
    end
end
