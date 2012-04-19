class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :route, :limit => 2048
      t.text :title
      t.text :url
      t.text :text

      t.timestamps
    end

    add_index :pages, :route
  end
end
