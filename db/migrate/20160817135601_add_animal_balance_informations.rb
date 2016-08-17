class AddAnimalBalanceInformations < ActiveRecord::Migration
  def change
   add_column :manure_management_plans, :milk_annual_production_in_liter, :integer
   add_column :manure_management_plans, :external_building_attendance_in_month, :decimal, precision: 19, scale: 4
  end
end
