class DeleteNotesFromRdv < ActiveRecord::Migration[6.0]
  def change
    remove_column :rdvs, :notes
  end
end
