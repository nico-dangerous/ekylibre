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
    ActiveRecord::Base.connection.execute 'CREATE TABLE IF NOT EXISTS lexicon.approaches(id serial PRIMARY KEY, classname varchar ,name varchar, supply_nature varchar, questions jsonb, shape geometry(GEOMETRY,4326));'
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
  task approach_yml: :environment do
    name = ENV["NAME"]
    supply_nature = ENV["SUPPLY_NATURE"]
    shape_file = ENV["SHAPEFILE"]
    filename = name+".approaches.yml"
    shape = nil
    RGeo::Shapefile::Reader.open(shape_file, srid: 4326) do |file|
      file.each do |record|
        shape = record.geometry.as_text
      end
    end
    finished = false
    questions = {"questions" => {}}

    index = 0
    while not finished do
      puts ("add question ? y/n")
      answer = STDIN.gets.chomp
      question = {}
      if answer == "y"

        question = {}
        puts ("text :")
        question["text"] = STDIN.gets.chomp
        puts ("label :")
        question["label"] = STDIN.gets.chomp
        puts ("type :")
        question["type"] = STDIN.gets.chomp
        questions["questions"][index.to_s] = question
        index+=1
      elsif answer == "n"
        finished = true
      end
    end
    approach = {"name" => name,
                "supply_nature" => supply_nature,
                "questions" => questions.to_s,
                "shape" => shape
                }
    File.new(filename,"w").puts(approach.to_yaml)
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
