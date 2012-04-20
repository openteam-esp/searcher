class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :url, :limit => 4096
    end

    add_index :pages, :url
  end
end
