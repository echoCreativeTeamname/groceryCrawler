class CreateTables < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.text :description

      
    end

    create_table :storechains do |t|
      t.string :name

    end
  end
end
