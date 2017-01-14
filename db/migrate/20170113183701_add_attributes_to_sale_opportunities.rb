class AddAttributesToSaleOpportunities < ActiveRecord::Migration
  def change

    add_reference :affairs, :nature, index: true
    add_reference :affairs, :provider, index: true

    create_table :affair_labellings do |t|
      t.references :affair, null: false, index: true
      t.references :label, null: false, index: true
      t.stamps
      t.index [:affair_id, :label_id], unique: true
    end

    create_table :affair_natures do |t|
      t.string :name, null: false, index: true
      t.text :description
      t.stamps
    end

  end
end
