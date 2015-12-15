class AddPatternToClient < ActiveRecord::Migration
  def change
    add_column :clients, :pattern, :string
  end
end
