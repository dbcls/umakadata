class Inquiry
  include ActiveModel::Model
  include ActiveModel::Validations
  
  attr_accessor :name, :email, :message
end
