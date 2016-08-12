
module Lexicon
  def shapefile_to_shapes(path, srid)
    shapes = []
    RGeo::Shapefile::Reader.open(path, srid: srid) do |file|
      file.each do |record|
        geometry = Charta::Geometry.new(record.geometry)
        geometry.srid = srid
        geometry = geometry.transform(:WGS84).to_ewkt
        attributs = record.attributes
        shapes << { 'shape' => geometry, 'attributes' => attributs }
      end
      file.rewind
      record = file.next
    end
    shapes
  end

  def fill_table_from_yaml(yaml_filename)
    name = File.basename(yaml_filename, '.yml').split('.').last.downcase
    yaml = YAML.load(File.open(yaml_filename))
    unless yaml.empty?
      columns = yaml[yaml.keys.first].keys
      # Insert row
      yaml.each_value do |data|
        # add quotes around value to insert

        columns_list = ActiveRecord::Base.connection.columns(name).each_with_object({}.with_indifferent_access) do |column, hash|
          hash[column.name] = column
        end

        data = data.each_pair.map do |key, value|
          data_type = columns_list[key].type
          value = value.to_json if data_type == :json || data_type == :jsonb
          [key, ActiveRecord::Base.connection.quote(value)]
        end.to_h
        ActiveRecord::Base.connection.execute "INSERT INTO lexicon.#{name} (#{columns.join(', ')}) VALUES (#{data.values.join(',')});"
      end
    end
  end

  def shapefile_to_yaml(input_filename, output_filename, nature, name_attr, prefix_name = '', srid = 4326)
    # path = shapefile_path
    # filename = yaml file

    shape_hash = {}
    shapefile_to_shapes(input_filename, srid).each_with_index do |value, index|
      row = {}
      name = if name_attr.nil?
               ''
             else
               value['attributes'][name_attr]
             end
      row[index.to_s] = { 'name' => prefix_name + name,
                          'type' => nature,
                          'shape' => value['shape'] }
      shape_hash.merge!(row)
    end

    f = File.new(output_filename.to_s, 'w').puts(shape_hash.to_yaml)
  end
end
