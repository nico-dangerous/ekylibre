
module Backend
  module ManureManagementPlanHelper


    def manure_management_plan_map(record)

      options = {
          controls: {
              zoom: true,
              scale: true,
              fullscreen: true,
              layer_selector: true
          },
          box: {
              :height => '100%'
          }
      }
      visualization(options) do |v|
        v.control :fullscreen
        v.control :layer_selector
        v.control :background_selector
        v.control :search
        v.simple options[:id] || :items, :main, {}
      end
    end

=begin
    def vulnerable_zone_feature_collection(properties = {})
      rgeo_coder = RGeo::GeoJSON::Coder.new({:json_parser => :json})
      features = []
      VulnerableZone.all.each_with_index  do |vulnerable_zone, index |
        geojson = Charta.new_geometry(vulnerable_zone.shape).to_geojson
        RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),index,properties)
        features << RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),index,properties)
      end
      rgeo_coder.encode(RGeo::GeoJSON::FeatureCollection.new (features))

    end
=end


    def objects_to_features(objects, properties = [])
      # Take an array of objects and an array of key used to extracts the properties to
      # put in the feature
      # properties is an array, the nth object of the objects parameter is related to the nth property from the properties param
      # you can't pass a property with the key :"shape"
      properties.delete_if {|prop| prop.to_s == "shape" }
      rgeo_coder = RGeo::GeoJSON::Coder.new({:json_parser => :json})
      features = []
      objects.each_with_index  do |object, index |
        geojson = Charta.new_geometry(object.shape).to_geojson

        features << RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),nil,properties[index])
      end
      features
    end

    def features_to_feature_collection(features)
      rgeo_coder = RGeo::GeoJSON::Coder.new({:json_parser => :json})
      rgeo_coder.encode(RGeo::GeoJSON::FeatureCollection.new (features))
    end

    def geometry_to_feature(geometry,properties={})
      # XXX find a way to buid geojson features without converting to geojson geometry and decoding to rgeo feature (it takes too much time)
      rgeo_coder = RGeo::GeoJSON::Coder.new({:json_parser => :json})
      geojson=geometry_to_geojson(geometry,properties)
      RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),nil,properties)
    end

    def geometry_to_geojson(geometry, properties = {})
      Charta.new_geometry(geometry).to_geojson
    end

    def manure_feature_collection(manure_management_plan,properties = {})
      #Returns a feature collection for cultivable zones using charta
      objects_to_feature_collection(manure_management_plan.zones, properties)
    end

    def objects_to_feature_collection(objects, properties = [])
      features_to_feature_collection(objects_to_features(objects,properties))
    end

    def regulatory_zones_feature_collection(manure_management_plan)
      #Returns a geojson feature collections for Regulatory zones using charta,and a info hash,
      # see :RegulatoryZone.build_non_spreadable_zone

      regulatory_zones_shape, info = *RegulatoryZone.build_non_spreadable_zone(manure_management_plan)
      return [features_to_feature_collection([geometry_to_feature(regulatory_zones_shape)]), info]
    end

    def manure_feature_description(manure_management_plan)
      old_logger = ActiveRecord::Base.logger

      regulatory_zones_shape, info = *regulatory_zones_feature_collection(manure_management_plan)
      cultivable_zones_properties = []

      mmpz_in_vulnerable_area = manure_management_plan.zones_in_vulnerable_area
      #mmpz_in_vulnerable_area is an array of array of one element, so we convert it into a simple array


      manure_management_plan.zones.each do |manure_zone|
        property = {}

        # extracts from info and place it in properties
        info.each_key { |key|
          value = info[key].select{ |info_id,value| info_id == manure_zone.id }
          property[ActiveSupport::Inflector.singularize(key)] = value.values.first.to_s
        }
        #Is the mmpz in a vulnerable_zone ?
        property[:vulnerable_zone] = mmpz_in_vulnerable_area.include?(manure_zone.id.to_s).to_s
        property[:name] = manure_zone.name
        property[:variety] = manure_zone.cultivation_variety_name
        property[:soil_nature] =  Nomen::SoilNature.find(manure_zone.soil_nature).human_name
        cultivable_zones_properties << property
      end

      ActiveRecord::Base.logger = old_logger
      return {:regulatory_zones => regulatory_zones_feature_collection(manure_management_plan),
              :cultivable_zones => manure_feature_collection(manure_management_plan,cultivable_zones_properties)
              }

    end
  end
end
