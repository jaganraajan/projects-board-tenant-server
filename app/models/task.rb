class Task < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[todo in_progress done] }
  validates :priority, inclusion: { in: %w[Priority\ 1 Priority\ 2 Priority\ 3 Priority\ 4], allow_blank: true }
  
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
end
