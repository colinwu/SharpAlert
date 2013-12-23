class PrintVolume < ActiveRecord::Base
  attr_accessible :model, :ave_bw, :max_bw, :ave_c, :max_c, :lifetime
  
  validates_uniqueness_of :model
  
  has_many :devices, :primary_key => 'model', :foreign_key => 'model'
end
