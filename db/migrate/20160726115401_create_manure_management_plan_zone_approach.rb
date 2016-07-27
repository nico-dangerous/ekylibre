class CreateManureManagementPlanZoneApproach < ActiveRecord::Migration
  def change
    create_table :manure_management_plan_zone_approaches do |t|
      t.jsonb :parameters
      t.jsonb :results
      t.belongs_to :manure_management_plan_nature, index: {:name => "index_manure_plan_approach_on_manure_plan_nature"}
      t.belongs_to :manure_management_plan_zone, index: {:name => "index_manure_plan_approach_on_manure_plan_zone"}
      t.belongs_to :approach, index:{:name => "index_manure_plan_approach_on_approach"}
    end

    create_table :manure_management_plan_natures do |t|
      t.string :supply_nature
      t.belongs_to :manure_management_plan, index: {:name => "index_manure_plan_nature_on_manure_plan"}
    end
  end
end