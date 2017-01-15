class AddGeocoderAttributes < ActiveRecord::Migration
  def change

    add_column :entity_addresses, :latitude, :float
    add_column :entity_addresses, :longitude, :float

  end
end
