class User < ApplicationRecord
  has_secure_password
  has_many :tasks, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :company_name, presence: true
end
