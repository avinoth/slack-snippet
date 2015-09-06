class AddIndex < ActiveRecord::Migration
  def change
    add_index :users, :slack_user_id
    add_index :users, :token
    add_index :snippets, :title
    add_index :snippets, :snippet
    add_index :snippets, :user_id
  end
end
