require 'lexicon'

namespace :lexicon do
  include Lexicon

  desc "create the lexicon schema with postgis extension,
      and create the lexicon's tables"
  task create: :environment do
    ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS lexicon;'
    ActiveRecord::Base.connection.execute 'CREATE TABLE IF NOT EXISTS lexicon.regulary_zones(id serial, name varchar, nature varchar, shape geometry(MULTIPOLYGON,4326));'
  end

  desc "delete lexicon schema and all its data"
  task drop: :environment do
    ActiveRecord::Base.connection.execute 'DROP SCHEMA lexicon CASCADE;'
  end

  desc "call tasks drop and create"
  task reset: :environment do
    Rake::Task['lexicon:drop'].invoke
    Rake::Task['lexicon:create'].invoke
  end

  desc "Depends from lexicon create, load all yml file from db/lexicon directories, and
        create the table corresponding.
        all items must have the same attributs, and must be referenced, even if null.
        The table created is lexicon.<filename> without extension"
  task import: :create do
    path =  File.join("{db,plugins/*/db}","lexicon","*.yml")
    Dir.glob(path).each do |filename|
      Lexicon.fill_table_from_yaml(filename)
    end
  end

  desc ""
  task shapefile_to_yaml: :environment do
    path = ENV['SHAPEFILE']
    filename = ENV['FILENAME']
    srid = ENV['SRID']
    nature = ENV['NATURE']
    name_attr = ENV['NAME_ATTR']
    Lexicon.shapefile_to_yaml(path,filename,srid,nature,name_attr)
   end
end
