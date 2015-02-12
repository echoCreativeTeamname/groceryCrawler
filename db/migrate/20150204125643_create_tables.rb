
class CreateTables < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.string :city
      t.string :postalcode
      t.string :street
      t.float :longitude, :precision => 10, :scale => 6
      t.float :latitude, :precision => 10, :scale => 6
      t.string :identifier
      t.timestamp :lastupdated
      t.belongs_to :storechain
    end

    create_join_table :ingredients, :recipes, table_name: :recipeingredient do |t|
      t.string :amount
    end

    create_table :openinghours do |t|
      t.belongs_to :store
      t.date :date
      t.time :openingtime
      t.time :closingtime
    end

    create_table :storechains do |t|
      t.string :name
      t.integer :priceclass
      t.integer :healthclass
      t.timestamp :lastupdated
    end
  end
end
