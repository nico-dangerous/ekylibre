require 'lexicon'
require 'open-uri'

namespace :lexicon do
  include Lexicon

  desc "create the lexicon schema with postgis extension,
      and create the lexicon's tables"
  task create: :environment do
    ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS lexicon;'
    ActiveRecord::Base.connection.execute 'CREATE TABLE IF NOT EXISTS lexicon.regulatory_zones(id serial PRIMARY KEY, name varchar, type varchar, shape geometry(GEOMETRY,4326));'
    ActiveRecord::Base.connection.execute 'CREATE TABLE IF NOT EXISTS lexicon.administrative_areas(id serial PRIMARY KEY, name varchar, type varchar, shape geometry(MULTIPOLYGON,4326));'
    ActiveRecord::Base.connection.execute 'CREATE TABLE IF NOT EXISTS lexicon.approaches(id serial PRIMARY KEY, name varchar, supply_nature varchar, questions jsonb, shape geometry(GEOMETRY,4326));'
  end

  desc "delete lexicon schema and all its data"
  task drop: :environment do
    ActiveRecord::Base.connection.execute 'DROP SCHEMA IF EXISTS lexicon CASCADE;'
  end

  desc "call tasks drop and create"
  task reset: :environment do
    Rake::Task['lexicon:drop'].invoke
    Rake::Task['lexicon:import'].invoke
  end

  desc "Depends from lexicon create, load all yml file from db/lexicon directories, and
        create the table corresponding.
        all items must have the same attributs, and must be referenced, even if null.
        The table created is lexicon.<filename> without extension"
  task import: :create do
    path =  File.join("{db,plugins/**/db}","lexicon","**","*.yml")
    Dir.glob(path).each do |filename|
      puts filename
      Lexicon.fill_table_from_yaml(filename)
    end
  end

  desc ""
  task shapefile_to_yaml: :environment do

    input_filename = ENV['SHAPEFILE'] # File to read
    output_filename = ENV['FILENAME'] #File to write in
    srid = ENV['SRID'] || 4326  #SRID from shapefile read
    nature_column = ENV['NATURE'] # string
    name_attr = ENV['NAME_ATTR'] #the attribute from the shapefile for name column
    prefix = ENV["PREFIX"] || ''

    Lexicon.shapefile_to_yaml(input_filename,output_filename,nature_column,name_attr,prefix,srid)
  end

end
