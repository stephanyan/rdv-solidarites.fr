class CreateUserDiaries < ActiveRecord::Migration[6.0]
  def change
    create_table :user_diaries do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :organisation, null: false, foreign_key: true
      t.belongs_to :agent, null: false, foreign_key: true
      t.text :note
      t.timestamps
    end
  end
end
