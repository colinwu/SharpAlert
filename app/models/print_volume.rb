class PrintVolume < ApplicationRecord
  
  validates_uniqueness_of :model
  
  has_many :devices, :primary_key => 'model', :foreign_key => 'model'
end
