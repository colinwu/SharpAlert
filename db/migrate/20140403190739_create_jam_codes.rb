class CreateJamCodes < ActiveRecord::Migration
  def change
    create_table :jam_codes do |t|
      t.string :red_code
      t.string :desc
    end
  end
end
