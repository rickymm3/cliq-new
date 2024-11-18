class AddSlugToCliqs < ActiveRecord::Migration[7.0]
  def change
    add_column :cliqs, :slug, :string
    add_index :cliqs, :slug, unique: true
  end
end
