class JamCode < ActiveRecord::Base
  attr_accessible :desc, :red_code
  
  def self.xlate(rc)
    j = self.find_by_red_code(rc)
    if (j.nil?)
      return rc
    else
      return j.desc
    end
  end
end
