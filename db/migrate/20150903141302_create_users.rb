class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, required: true
      t.string :slack_user_id, required: true
      t.string :token, required: true

      t.timestamps null: false
    end
  end
end
