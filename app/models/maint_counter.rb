class MaintCounter < ActiveRecord::Base
#   attr_accessible :maint_total, :maint_color, :drum_print_b, :drum_print_c, :drum_print_m, :drum_print_y
  belongs_to :alert
end
