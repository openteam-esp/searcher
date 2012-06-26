class AddLevelToPages < ActiveRecord::Migration
  def change
    add_column :pages, :level, :integer
  end
end
