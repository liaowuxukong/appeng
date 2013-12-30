class AddIndexToAppsDomain < ActiveRecord::Migration
  def change
    add_index :apps, :domain, unique: true
  end
end
