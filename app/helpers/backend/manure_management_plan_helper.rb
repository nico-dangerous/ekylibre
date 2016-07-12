
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
      # you can't pass a property with the key :"shape"
      properties.delete_if {|prop| prop.to_s == "shape" }
      rgeo_coder = RGeo::GeoJSON::Coder.new({:json_parser => :json})
      features = []
      objects.each_with_index  do |object, index |
        geojson = Charta.new_geometry(object.shape).to_geojson

        properties_values = {}
        properties_values = properties.map {|prop| properties_values["prop"] =[prop, object.attributes[prop]] }.to_h

        features << RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),index,properties_values)
      end
      features
    end

    def features_to_feature_collection(features)
      rgeo_coder = RGeo::GeoJSON::Coder.new({:json_parser => :json})
      rgeo_coder.encode(RGeo::GeoJSON::FeatureCollection.new (features))
    end

    def geometry_to_feature(geometry,properties={})
      rgeo_coder = RGeo::GeoJSON::Coder.new({:json_parser => :json})
      geojson=geometry_to_geojson(geometry,properties)
      RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),0,properties)
    end

    def geometry_to_geojson(geometry, properties = {})
      Charta.new_geometry(geometry).to_geojson
    end

    def manure_feature_collection(mmp)
      objects_to_feature_collection(mmp.zones)
    end

    def objects_to_feature_collection(objects, properties = [])
      features_to_feature_collection(objects_to_features(objects,properties))
    end

    def regulatory_zones_feature_collection(manure_management_plan)
      geom = RegulatoryZone.build_non_spreadable_zone(manure_management_plan)
      return nil if geom.nil?
      features_to_feature_collection  [geometry_to_feature(geom)]
    end

=begin
    def manure_management_plan_feature_collection(campaign, properties = [])

      #used for coloring
      cultivable_zone_level=0

      manure_management_plan_zones = ManureManagementPlan.of_campaign(campaign).first.zones

      #geoms = (ActiveRecord::Base.connection.execute sql).values.first

      #create an object to encode/decode geojson from/to RGeo geometry
      rgeo_coder = RGeo::GeoJSON::Coder.new({:json_parser => :json})
      features = []
      manure_management_plan_zones.each_with_index  do |manure_management_plan_zone, index |
        #encode postgis geometry to geojson
        geojson = Charta.new_geometry(manure_management_plan_zone.support_shape).to_geojson
        #store properties attached to geometry

        #decode geojson to RGeo feature
        properties_values = {}
        properties_values = properties.map {|prop| properties_values["prop"] =[prop, manure_management_plan_zone.attributes[prop]] }.to_h

        features << RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),index,properties_values)
      end

      #Create a feature collection from an enumerable of RGeo Feature
      rgeo_coder.encode(RGeo::GeoJSON::FeatureCollection.new (features))
    end
=end
  end
end
