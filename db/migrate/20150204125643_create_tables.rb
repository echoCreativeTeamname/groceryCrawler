
class CreateTables < ActiveRecord::Migration
  def change
    # Stores/storechains
    create_table :stores do |t|
      t.string :uuid, :unique => true
      t.belongs_to :chain
      t.string :name
      t.string :city
      t.string :postalcode
      t.string :street
      t.float :longitude, :precision => 10, :scale => 6
      t.float :latitude, :precision => 10, :scale => 6
      t.string :identifier
      t.timestamp :lastupdated
    end

    create_table :openinghours do |t|
      t.belongs_to :store
      t.date :date
      t.time :openingtime
      t.time :closingtime
    end

    create_table :storechains do |t|
      t.string :uuid, :unique => true
      t.string :name
      t.integer :priceclass
      t.integer :healthclass
      t.timestamp :lastupdated
    end

    # Recipes
    create_join_table :ingredients, :recipes, table_name: :recipeingredient do |t|
      t.string :amount
    end

    # Products
    create_table :products do |t|
      t.string :uuid, :unique => true
      t.belongs_to :storechain
      t.belongs_to :ingredient
      t.string :name
      t.decimal :price, :precision => 7, :scale => 2
      t.string :amount
      t.timestamp :lastupdated
    end
  end
end
