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

ActiveRecord::Schema.define(:version => 20130610195400) do

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

end
