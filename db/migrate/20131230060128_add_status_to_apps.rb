class AddStatusToApps < ActiveRecord::Migration
  def change
    add_column :apps, :status, :string
  end
end
