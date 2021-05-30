class CreateSpeciesLocations < ActiveRecord::Migration
  def change
    create_table :species_locations do |t|
      t.references :species
      t.decimal :lat, {:precision=>10, :scale=>6}
      t.decimal :lon, {:precision=>10, :scale=>6}
      t.timestamps default: DateTime.now, null: false
    end
  end
end
