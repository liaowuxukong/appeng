class AddServiceFilePathToApps < ActiveRecord::Migration
  def change
    add_column :apps, :service_file_path, :string
  end
end
