
module Lexicon

  def shapefile_to_shapes(path,srid)
    shapes = []
    RGeo::Shapefile::Reader.open(path, srid: srid) do |file|

      file.each do |record|

        geometry = Charta::Geometry.new(record.geometry)
        geometry.srid=(srid)
        geometry=geometry.transform(:WGS84).to_ewkt
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
    name = File.basename(yaml_filename,".yml").split('.').last.downcase
    yaml = YAML::load(File.open(yaml_filename))
    unless yaml.empty?
      columns = yaml[yaml.keys.first].keys

      #Insert row
      yaml.each_value do |data|
        #add quotes around value to insert
        data = data.each_pair.map { |key, value| [key, ActiveRecord::Base.connection.quote(value)] }.to_h
        ActiveRecord::Base.connection.execute "INSERT INTO lexicon.#{name} (#{columns.join(', ')}) VALUES (#{data.values.join(',')});"
      end
    end
  end

  def shapefile_to_yaml(input_filename, output_filename, nature, name_attr, prefix_name='',srid = 4326)
    #path = shapefile_path
    #filename = yaml file

    shape_hash={}
    shapefile_to_shapes(input_filename,srid).each_with_index do |value, index|
      row = {}
      if name_attr.nil?
        name=''
      else
        name = value["attributes"][name_attr]
      end
      row[index.to_s] = {"name" => prefix_name + name,
                         "type" => nature,
                         "shape" => value["shape"]}
      shape_hash.merge!(row)
    end

    f=File.new("#{output_filename}","w").puts(shape_hash.to_yaml)
  end

end