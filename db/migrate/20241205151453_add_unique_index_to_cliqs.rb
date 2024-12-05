class AddUniqueIndexToCliqs < ActiveRecord::Migration[7.0]
  def change
    add_index :cliqs, [:name, :parent_cliq_id], unique: true

  end
end
