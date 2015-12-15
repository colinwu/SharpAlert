class ChangeMaintCounter < ActiveRecord::Migration
  def up
    change_table :maint_counters do |t|
      t.integer :mft_total
      t.integer :tray1
      t.integer :tray2
      t.integer :tray3
      t.integer :tray4
      t.integer :dev_life_used_b
      t.integer :dev_life_used_c
      t.integer :dev_life_used_m
      t.integer :dev_life_used_y
      t.integer :ptu_days
      t.integer :adu
      t.rename :fusing_print, :fuser_print
      t.rename :fusing_days, :fuser_days
      t.rename :drum_rotation_b, :toner_rotation_b
      t.rename :drum_rotation_c, :toner_rotation_c
      t.rename :drum_rotation_m, :toner_rotation_m
      t.rename :drum_rotation_y, :toner_rotation_y
      t.rename :dev_rotation_b, :drum_life_used_b
      t.rename :dev_rotation_c, :drum_life_used_c
      t.rename :dev_rotation_m, :drum_life_used_m
      t.rename :dev_rotation_y, :drum_life_used_y
      t.remove :fusing_web_clean
    end
  end
  
  def down
    change_table :maint_counters do |t|
      t.remove :mft_total, :ptu_days, :adu
      t.remove :tray1, :tray2, :tray3, :tray4
      t.remove :dev_life_used_b, :dev_life_used_c, :dev_life_used_m, :dev_life_used_y
      t.rename :fuser_print, :fusing_print
      t.rename :fuser_days, :fusing_days
      t.rename :toner_rotation_b, :drum_rotation_b
      t.rename :toner_rotation_c, :drum_rotation_c
      t.rename :toner_rotation_m, :drum_rotation_m
      t.rename :toner_rotation_y, :drum_rotation_y
      t.rename :drum_life_used_b, :dev_rotation_b
      t.rename :drum_life_used_c, :dev_rotation_c
      t.rename :drum_life_used_m, :dev_rotation_m
      t.rename :drum_life_used_y, :dev_rotation_y
      t.integer :fusing_web_clean
    end
  end
end
