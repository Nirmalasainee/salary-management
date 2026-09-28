class Country < ApplicationRecord
    has_many :employees

    validates :name, presence: true, uniqueness: true
    validates :currency_code, presence: true, length: { is: 3 }
end
