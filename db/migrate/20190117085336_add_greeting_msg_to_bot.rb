class AddGreetingMsgToBot < ActiveRecord::Migration
  def change
    add_column :bots, :greeting_msg, :text
  end
end
