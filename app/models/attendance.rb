class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :business_process_content, length: { maximum: 50}
  
  validate :finished_at_is_invalid_without_a_started_at
  validate :started_at_than_finished_at_fast_in_invalid
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_in_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  
  def self.search(search)
    return Attendance.all unless search
    # 開発環境
    if Rails.env.development? || Rails.env.test?
      Attendance.where(['worked_on LIKE ?', "%#{search}%"])
    else Rails.env.production?
      # 本番環境
      Attendance.where(['worked_on::text LIKE ?', "%#{search}%"])
    end
  end
  
  
  
  
  
  
end
