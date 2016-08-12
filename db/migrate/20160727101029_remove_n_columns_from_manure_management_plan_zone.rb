class RemoveNColumnsFromManureManagementPlanZone < ActiveRecord::Migration
  def change
    remove_column :manure_management_plan_zones, :maximum_nitrogen_input, :decimal
    remove_column :manure_management_plan_zones, :meadow_humus_mineralization, :decimal
    remove_column :manure_management_plan_zones, :mineral_nitrogen_at_opening, :decimal
    remove_column :manure_management_plan_zones, :nitrogen_at_closing, :decimal
    remove_column :manure_management_plan_zones, :nitrogen_input, :decimal
    remove_column :manure_management_plan_zones, :nitrogen_need, :decimal
    remove_column :manure_management_plan_zones, :organic_fertilizer_mineral_fraction, :decimal
    remove_column :manure_management_plan_zones, :previous_cultivation_residue_mineralization, :decimal
    remove_column :manure_management_plan_zones, :humus_mineralization, :decimal
    remove_column :manure_management_plan_zones, :absorbed_nitrogen_at_opening, :decimal
    remove_column :manure_management_plan_zones, :intermediate_cultivation_residue_mineralization, :decimal
    remove_column :manure_management_plan_zones, :irrigation_water_nitrogen, :decimal
    remove_column :manure_management_plan_zones, :soil_production, :decimal
    remove_column :manure_management_plans, :default_computation_method, :string
    remove_column :manure_management_plans, :selected, :string
    remove_column :manure_management_plan_zones, :computation_method, :string
  end
end
