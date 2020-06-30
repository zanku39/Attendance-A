class Office < ApplicationRecord
  
  validates :base, presence: true, length: { maximum: 10 }
  validates :base_number, presence: true, uniqueness: true
  validates :work, length: { maximum: 10 }
end
