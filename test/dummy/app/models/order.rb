class Order < ActiveRecord::Base
  validates :customer_name, presence: true
  validates :date, presence: true
end
