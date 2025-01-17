class RecreateCliqs < ActiveRecord::Migration[7.0]
  def change
    create_table :cliqs do |t|
      t.string :name, null: false
      t.text :description
      t.bigint :parent_cliq_id
      t.string :slug
      t.timestamps
    end

    add_index :cliqs, [:name, :parent_cliq_id], unique: true, name: "index_cliqs_on_name_and_parent_cliq_id"
    add_index :cliqs, :parent_cliq_id, name: "index_cliqs_on_parent_cliq_id"
    add_index :cliqs, :slug, unique: true, name: "index_cliqs_on_slug"
  end
end
