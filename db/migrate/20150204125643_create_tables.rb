
class CreateTables < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name

      t.string :city
      t.string :postalcode
      t.string :steet

      t.belongs_to :storechain
    end

    create_join_table :ingredients, :recipes, table_name: :recipeingredient do |t|
      t.string :amount
    end

    create_table :storechains do |t|
      t.string :name
      t.integer :priceclass
      t.integer :healthclass
      t.date :lastupdated

    end
  end
end
