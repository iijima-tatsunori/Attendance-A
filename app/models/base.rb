class Base < ApplicationRecord
  validates :base_number, presence: true, length: { maximum: 10 },
                          uniqueness: true
                    
  validates :base_name, presence: true, length: { maximum: 10 }
  validates :attendance_type, presence: true
                    
                    
                    
end
