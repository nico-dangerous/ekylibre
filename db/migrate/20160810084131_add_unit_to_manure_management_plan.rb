class AddUnitToManureManagementPlan < ActiveRecord::Migration
  def change
    change_table :manure_management_plans do |t|
      t.string :data_unit
    end
  end
end
