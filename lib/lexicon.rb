
module Lexicon

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

  def fill_table_from_yaml(yaml_filename)
    #the table name is the filename without extension
    name = File.basename(yaml_filename,".yml").downcase
    yaml = YAML::load(File.open(yaml_filename))
    unless yaml.empty?
      columns = yaml[yaml.keys.first].keys

      #Insert row
      yaml.each_value do |data|
        #add quote around value to insert
        data = data.each_pair.map { |key, value| [key, "'#{value}'"] }.to_h

        ActiveRecord::Base.connection.execute "INSERT INTO lexicon.#{name} (#{columns.join(', ')}) VALUES (#{data.values.join(',')});"
      end
    end
  end

  def shapefile_to_yaml(path , filename , srid , nature , name_attr)
    shape_hash={}
    shapefile_to_shapes(path,srid).each_with_index do |value, index|
      row = {}
      byebug
      row[index.to_s] = {"name" => value["attributes"][name_attr],
                         "nature" => nature,
                         "shape" => value["shape"]}
      shape_hash.merge!(row)
    end
    f=File.new("#{filename}","w").puts(shape_hash.to_yaml)
  end

end