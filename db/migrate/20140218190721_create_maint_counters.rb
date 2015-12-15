class CreateMaintCounters < ActiveRecord::Migration
  def self.up
    create_table :maint_counters do |t|
      t.integer :maint_total
      t.integer :maint_color
      t.integer :drum_print_b
      t.integer :drum_print_c
      t.integer :drum_print_m
      t.integer :drum_print_y
      t.integer :dev_print_b
      t.integer :dev_print_c
      t.integer :dev_print_m
      t.integer :dev_print_y
      t.integer :drum_dist_b
      t.integer :drum_dist_c
      t.integer :drum_dist_m
      t.integer :drum_dist_y
      t.integer :dev_dist_b
      t.integer :dev_dist_c
      t.integer :dev_dist_m
      t.integer :dev_dist_y
      t.integer :scan
      t.integer :spf_count
      t.integer :ptu_print
      t.integer :ptu_dist
      t.integer :stu_print
      t.integer :stu_dist
      t.integer :stu_days
      t.integer :fusing_print
      t.integer :fusing_days
      t.integer :fusing_web_clean
      t.integer :toner_motor_b
      t.integer :toner_motor_c
      t.integer :toner_motor_m
      t.integer :toner_motor_y
      t.integer :drum_rotation_b
      t.integer :drum_rotation_c
      t.integer :drum_rotation_m
      t.integer :drum_rotation_y
      t.integer :dev_rotation_b
      t.integer :dev_rotation_c
      t.integer :dev_rotation_m
      t.integer :dev_rotation_y
      t.integer :alert_id
      t.timestamps
    end
  end

  def self.down
    drop_table :maint_counters
  end
end
