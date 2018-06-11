class AddRestartMessageToBots < ActiveRecord::Migration
  def change
    add_column :bots, :restart_msg, :string
  end
end
