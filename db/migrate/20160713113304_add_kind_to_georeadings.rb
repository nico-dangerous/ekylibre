class AddKindToGeoreadings < ActiveRecord::Migration
  def change
    add_column :georeadings, :kind, :string
  end
end
