namespace :lexicon do

  desc "create the lexicon schema with postgis extension,
      and create the lexicon's tables"
  task create: :environment do
    ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS lexicon;'
    ActiveRecord::Base.connection.execute 'CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA lexicon;'
    ActiveRecord::Base.connection.execute 'CREATE TABLE lexicon.vulnerable_areas(id serial,geom geometry(MULTIPOLYGON,4326));'
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

  desc "import the geometries from a shapefile as a postgis multipolygone in lexicon.vulnerable_areas,
         geometry srid will be converted to 4326 \n
        usage : rake lexicon:import_vulnerable_area PATH=... SRID=..."
  task import_vulnerable_area: :environment do
    path = ENV['SHAPEFILE']
    srid = ENV['SRID']

    RGeo::Shapefile::Reader.open(path, srid: srid) do |file|
      file.each do |record|
        geometry = Charta::Geometry.new(record.geometry)
        geometry.srid=(srid)
        geometry4326 = geometry.transform(:WGS84)
        vulnerable_area = VulnerableArea.create(name: "toto", geom: geometry4326.to_rgeo)
      end
      file.rewind
      record = file.next
    end
  end
end