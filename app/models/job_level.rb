class JobLevel < ApplicationRecord
    has_many :employees

    validates :name, presence: true, uniqueness: true
    validates :rank, presence: true, uniqueness: true
end
