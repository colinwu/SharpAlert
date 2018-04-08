class JamCode < ActiveRecord::Base
  
  def self.xlate(rc)
    j = self.find_by_red_code(rc)
    if (j.nil?)
      return rc
    else
      return j.desc
    end
  end
end
