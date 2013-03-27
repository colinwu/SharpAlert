class NewNotifyControlEmails < ActiveRecord::Migration
  def up
    rename_column :notify_controls, :who, :tech
    add_column :notify_controls, :local_admin, :string
  end

  def down
    remove_column :notify_controls, :local_admin
    rename_column :notify_controls, :tech, :who
  end
end
