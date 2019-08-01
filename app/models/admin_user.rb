class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :rememberable,
         :validatable
end
