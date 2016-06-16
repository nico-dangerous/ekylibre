namespace :lexicon do

  desc "create the lexicon schema with postgis extension,
      and create the lexicon's tables"
  task create: :environment do
    ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS lexicon;'
    ActiveRecord::Base.connection.execute 'CREATE TABLE IF NOT EXISTS lexicon.vulnerable_zones(id serial,shape geometry(MULTIPOLYGON,4326));'
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


  desc "Create lexicon schema if it doesn't exist, and populate it by calling import tasks"
  task import: :create do
    ENV['SHAPEFILE']=Rails.root.join('db', 'lexicon/vulnerable-zones/ZoneVuln.shp').to_s
    ENV['SRID']="2154"
    Rake::Task['lexicon:import_vulnerable_zones'].invoke
    #Add your calls to lexicon.import tasks
  end

  desc "import the geometries from a shapefile as a postgis multipolygone in lexicon.vulnerable_zones,
         geometry coordinate system will be converted with the srid 4326 \n
        usage : rake lexicon:import_vulnerable_zones SHAPEFILE=<your-file.shp> SRID=<actual shapefile srid>"
  task import_vulnerable_zones: :environment do
    path = ENV['SHAPEFILE']
    srid = ENV['SRID']

    RGeo::Shapefile::Reader.open(path, srid: srid) do |file|
      file.each do |record|
        geometry = Charta::Geometry.new(record.geometry)
        geometry.srid=(srid)
        VulnerableZone.create(shape: geometry.transform(:WGS84).to_ewkt)
      end
      file.rewind
      record = file.next
    end
  end
end