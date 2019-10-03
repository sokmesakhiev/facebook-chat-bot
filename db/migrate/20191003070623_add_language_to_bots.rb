class AddLanguageToBots < ActiveRecord::Migration
  def change
    add_column :bots, :language, :string, limit: 2, default: :kh
  end
end
