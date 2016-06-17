
namespace :lexicon do

  def shapefile_to_shapes(path,srid)
    shapes = []
    RGeo::Shapefile::Reader.open(path, srid: srid) do |file|
      file.each do |record|
        geometry = Charta::Geometry.new(record.geometry)
        geometry.srid=(srid)
        geometry=geometry.transform(:WGS84).to_ewkt
        #record.attributes.each_with_index { |key,value|  attributs[key] = value}
        attributs = record.attributes
        shapes << {"shape" => geometry, "attributes" => attributs}
      end
      file.rewind
      record = file.next
    end
    shapes
  end

  def create_table_from_yaml(yaml_filename)
    puts "create table #{yaml_filename}"
    name = yaml_filename.split("/").last.split('.').first.downcase!
   # ActiveRecord::Base.connection.execute "CREATE TABLE IF NOT EXISTS lexicon.#{name}(id serial,name varchar(255),nature varchar(255),shape geometry(MULTIPOLYGON,4326));"
    yaml = YAML::load(File.open(yaml_filename))
    
    # shapefile_to_shapes(path,srid).each do |geom|
   #   VulnerableZone.create(shape: geom)
   # end
  end


  desc "create the lexicon schema with postgis extension,
      and create the lexicon's tables"
  task create: :environment do
    ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS lexicon;'
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

#  desc "Create lexicon schema if it doesn't exist, and populate it by calling import tasks"
#  task import: :create do
#    ENV['SHAPEFILE']=Rails.root.join('db', 'lexicon/vulnerable-zones/ZoneVuln.shp').to_s
#    ENV['SRID']="2154"
#    Rake::Task['lexicon:import_vulnerable_zones'].invoke

    #Add your calls to lexicon.import tasks
#  end


  desc "import the geometries from a shapefile as a postgis multipolygone in lexicon.vulnerable_zones,
         geometry coordinate system will be converted with srid 4326 \n
        usage : rake lexicon:import_vulnerable_zones SHAPEFILE=<your-file.shp> SRID=<actual shapefile srid>"
  task import: :environment do
    path =  File.join("**","db","lexicon","*.yml")
    Dir.glob(path).each do |filename|
      create_table_from_yaml(filename)
    end
  end

  desc ""
  task shapefile_to_yaml: :environment do
    path = ENV['SHAPEFILE']
    name = ENV['NAME']
    srid = ENV['SRID']
    shape_hash={}

    shapefile_to_shapes(path,srid).each_with_index do |value, index|
      row = {}
      row[index.to_s] = {"name" => value["attributes"]["CodeEUZone"],
                         "nature" => "France vulnerable zone",
                         "shape" => value["shape"]}
      shape_hash.merge!(row)
    end
    f=File.new("#{name}","w").puts(shape_hash.to_yaml)
   end
end
