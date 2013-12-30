class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :path
      t.string :name
      t.integer :instance
      t.string :memory_limit
      t.string :domain

      t.timestamps
    end
  end
end
