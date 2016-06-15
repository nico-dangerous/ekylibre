class CreateLexicon < ActiveRecord::Migration

  def up
    execute 'CREATE SCHEMA IF NOT EXISTS lexicon;'
    create_table 'lexicon.vulnerable_areas' do |t|
      t.geometry :geom
      t.string   :name
    end
  end

  def down
    drop_table 'lexicon.vulnerable_areas'
    execute 'DROP SCHEMA lexicon CASCADE'
  end

end
