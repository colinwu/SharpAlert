# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160201142833) do

  create_table "alerts", :force => true do |t|
    t.datetime "alert_date"
    t.string   "alert_msg"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "device_id"
  end

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "pattern"
  end

  create_table "counters", :force => true do |t|
    t.datetime "status_date"
    t.integer  "copybw"
    t.integer  "copy2c"
    t.integer  "copy1c"
    t.integer  "copyfc"
    t.integer  "printbw"
    t.integer  "printfc"
    t.integer  "totalprintbw"
    t.integer  "totalprint2c"
    t.integer  "totalprint1c"
    t.integer  "totalprintc"
    t.integer  "scanbw"
    t.integer  "scan2c"
    t.integer  "scan1c"
    t.integer  "scanfc"
    t.integer  "fileprintbw"
    t.integer  "fileprint2c"
    t.integer  "fileprint1c"
    t.integer  "fileprintfc"
    t.integer  "faxin"
    t.integer  "faxinline1"
    t.integer  "faxinline2"
    t.integer  "faxinline3"
    t.integer  "otherprintbw"
    t.integer  "otherprintc"
    t.integer  "faxout"
    t.integer  "faxoutline1"
    t.integer  "faxoutline2"
    t.integer  "faxoutline3"
    t.integer  "hddscanbw"
    t.integer  "hddscan2c"
    t.integer  "hddscan1c"
    t.integer  "hddscanfc"
    t.integer  "tonerbkin"
    t.integer  "tonercin"
    t.integer  "tonermin"
    t.integer  "toneryin"
    t.integer  "tonernnendbk"
    t.integer  "tonernnendc"
    t.integer  "tonernnendm"
    t.integer  "tonernnendy"
    t.integer  "tonerendbk"
    t.integer  "tonerendc"
    t.integer  "tonerendm"
    t.integer  "tonerendy"
    t.integer  "tonerleftbk"
    t.integer  "tonerleftc"
    t.integer  "tonerleftm"
    t.integer  "tonerlefty"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "device_id"
  end

  create_table "devices", :force => true do |t|
    t.string   "name"
    t.string   "model"
    t.string   "serial"
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "client_id"
    t.string   "ip"
  end

  create_table "jam_codes", :force => true do |t|
    t.string "red_code"
    t.string "desc"
  end

  create_table "jam_stats", :force => true do |t|
    t.string   "jam_code"
    t.string   "paper_type"
    t.string   "paper_code"
    t.string   "jam_type"
    t.integer  "alert_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "maint_codes", :force => true do |t|
    t.string  "code"
    t.integer "alert_id"
  end

  create_table "maint_counters", :force => true do |t|
    t.integer  "maint_total"
    t.integer  "maint_color"
    t.integer  "drum_print_b"
    t.integer  "drum_print_c"
    t.integer  "drum_print_m"
    t.integer  "drum_print_y"
    t.integer  "dev_print_b"
    t.integer  "dev_print_c"
    t.integer  "dev_print_m"
    t.integer  "dev_print_y"
    t.integer  "drum_dist_b"
    t.integer  "drum_dist_c"
    t.integer  "drum_dist_m"
    t.integer  "drum_dist_y"
    t.integer  "dev_dist_b"
    t.integer  "dev_dist_c"
    t.integer  "dev_dist_m"
    t.integer  "dev_dist_y"
    t.integer  "scan"
    t.integer  "spf_count"
    t.integer  "ptu_print"
    t.integer  "ptu_dist"
    t.integer  "stu_print"
    t.integer  "stu_dist"
    t.integer  "stu_days"
    t.integer  "fuser_print"
    t.integer  "fuser_days"
    t.integer  "toner_motor_b"
    t.integer  "toner_motor_c"
    t.integer  "toner_motor_m"
    t.integer  "toner_motor_y"
    t.integer  "toner_rotation_b"
    t.integer  "toner_rotation_c"
    t.integer  "toner_rotation_m"
    t.integer  "toner_rotation_y"
    t.integer  "drum_life_used_b"
    t.integer  "drum_life_used_c"
    t.integer  "drum_life_used_m"
    t.integer  "drum_life_used_y"
    t.integer  "alert_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "mft_total"
    t.integer  "tray1"
    t.integer  "tray2"
    t.integer  "tray3"
    t.integer  "tray4"
    t.integer  "dev_life_used_b"
    t.integer  "dev_life_used_c"
    t.integer  "dev_life_used_m"
    t.integer  "dev_life_used_y"
    t.integer  "ptu_days"
    t.integer  "adu"
  end

  create_table "notify_controls", :force => true do |t|
    t.string   "tech"
    t.integer  "jam"
    t.integer  "toner_low"
    t.integer  "toner_empty"
    t.integer  "paper"
    t.integer  "service"
    t.integer  "pm"
    t.integer  "waste_almost_full"
    t.integer  "waste_full"
    t.integer  "job_log_full"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.datetime "jam_sent"
    t.datetime "toner_low_sent"
    t.datetime "toner_empty_sent"
    t.datetime "paper_sent"
    t.datetime "service_sent"
    t.datetime "pm_sent"
    t.datetime "waste_almost_full_sent"
    t.datetime "waste_full_sent"
    t.datetime "job_log_full_sent"
    t.string   "local_admin"
    t.integer  "device_id"
  end

  create_table "print_volumes", :force => true do |t|
    t.string   "model"
    t.integer  "ave_bw"
    t.integer  "max_bw"
    t.integer  "ave_c"
    t.integer  "max_c"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "lifetime"
  end

  create_table "service_codes", :force => true do |t|
    t.string  "code"
    t.integer "alert_id"
  end

  create_table "sheet_counts", :force => true do |t|
    t.integer  "bw"
    t.integer  "color"
    t.integer  "alert_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "toner_codes", :force => true do |t|
    t.string  "colour"
    t.integer "alert_id"
  end

end
