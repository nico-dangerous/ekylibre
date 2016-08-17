class AddManureManagementPlanInterventions < ActiveRecord::Migration
  def change
    create_table :manure_management_plan_interventions do |t|
      t.string :name,                   null: false
      t.string :procedure_name,         null: false
      t.string :actions
      t.references :plan,               null: false, index: { name: 'index_manure_intervention_plan' }
      t.datetime :started_at,           null: false
      t.datetime :stopped_at,           null: false
      t.references :variant,            null: false, index: { name: 'index_manure_intervention_variant' }
      t.decimal :quantity,              precision: 19, scale: 4
      t.string :variant_indicator,      null: false
      t.string :variant_unit,           null: false
      t.text :description
      t.stamps
    end

    create_table :manure_management_plan_intervention_targets do |t|
      t.references :manuring_zone,                  null: false, index: { name: 'index_manure_intervention_target_zone' }
      t.references :manuring_intervention,          null: false, index: { name: 'index_manure_intervention_target_intervention' }
      t.geometry   :spreading_zone,                 srid: 4326
      t.stamps
    end

    create_table :manure_management_plan_animal_balances do |t|
      t.references :plan,                                  null: false, index: { name: 'index_manure_animal_balance_plan' }
      t.references :animal_group,                          null: false, index: { name: 'index_manure_animal_balance_animal_group' }
      t.decimal :population,                               precision: 19, scale: 4
      t.decimal :large_stock_unit_population,              precision: 19, scale: 4
      t.decimal :inside_building_attendance_percentage,    precision: 19, scale: 4
      t.decimal :quantity,              precision: 19, scale: 4
      t.string  :indicator,      null: false
      t.string  :unit,           null: false
      t.stamps
    end
  end
end
