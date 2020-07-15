class RenameNoteIntoTexte < ActiveRecord::Migration[6.0]
  def change
    rename_column :user_diaries, :note, :text
  end
end
