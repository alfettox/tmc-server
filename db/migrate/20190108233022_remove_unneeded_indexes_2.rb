class RemoveUnneededIndexes2 < ActiveRecord::Migration[4.2]
  def change
    remove_index :user_app_data, name: "index_user_app_data_on_user_id"
  end
end
