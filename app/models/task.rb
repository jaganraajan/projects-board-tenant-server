class Task < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[todo in_progress done] }
  
  scope :by_status, ->(status) { where(status: status) }
end
