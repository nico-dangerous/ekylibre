
module Backend
  module ManureManagementPlanHelper
    def manure_management_plan_map(_record)
      options = {
        controls: {
          zoom: true,
          scale: true,
          fullscreen: true,
          layer_selector: true
        },
        box: {
          height: '100%'
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

    #     def vulnerable_zone_feature_collection(properties = {})
    #       rgeo_coder = RGeo::GeoJSON::Coder.new({:json_parser => :json})
    #       features = []
    #       VulnerableZone.all.each_with_index  do |vulnerable_zone, index |
    #         geojson = Charta.new_geometry(vulnerable_zone.shape).to_geojson
    #         RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),index,properties)
    #         features << RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),index,properties)
    #       end
    #       rgeo_coder.encode(RGeo::GeoJSON::FeatureCollection.new (features))
    #
    #     end

    def objects_to_features(objects, properties = [])
      # Take an array of objects and an array of key used to extracts the properties to
      # put in the feature
      # properties is an array, the nth object of the objects parameter is related to the nth property from the properties param
      # you can't pass a property with the key :"shape"
      properties.delete_if { |prop| prop.to_s == 'shape' }
      rgeo_coder = RGeo::GeoJSON::Coder.new(json_parser: :json)
      features = []
      objects.each_with_index do |object, index|
        geojson = Charta.new_geometry(object.shape).to_geojson
        properties[index].each do |key, value|
          properties[index][key] = object.send(:key) if value.nil?
        end
        features << RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson), nil, properties[index])
      end
      features
    end

    def features_to_feature_collection(features)
      rgeo_coder = RGeo::GeoJSON::Coder.new(json_parser: :json)
      rgeo_coder.encode(RGeo::GeoJSON::FeatureCollection.new(features))
    end

    def geometry_to_feature(geometry, properties = {})
      rgeo_coder = RGeo::GeoJSON::Coder.new(json_parser: :json)
      geojson = geometry_to_geojson(geometry, properties)
      RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson), nil, properties)
    end

    def geometry_to_geojson(geometry, _properties = {})
      Charta.new_geometry(geometry).to_geojson
    end

    def manure_feature_collection(manure_management_plan, properties = {})
      # Returns a feature collection for cultivable zones using charta
      objects_to_feature_collection(manure_management_plan.zones, properties)
    end

    def objects_to_feature_collection(objects, properties = [])
      features_to_feature_collection(objects_to_features(objects, properties))
    end

    def regulatory_zones_feature_collection(manure_management_plan)
      # Returns a geojson feature collections for Regulatory zones using charta,and a info hash,
      # see :RegulatoryZone.build_non_spreadable_zone

      regulatory_zones_shape, info = *RegulatoryZone.build_non_spreadable_zone(manure_management_plan)
      unless regulatory_zones_shape == Charta::GeometryCollection.empty
        return [features_to_feature_collection([geometry_to_feature(regulatory_zones_shape)]), info]
      end
      [:no_data, info]
    end

    def manure_zone_questions_properties(manure_zone)
      approaches_questions_properties = []
      approach_applications = manure_zone.manure_approach_applications
      approach_applications.each do |approach_app|
        approach = approach_app.approach
        if approach.nil?
          approaches_properties << {
            :type => :label,
            :property_label => approach.supply_nature,
            :property_value => 'no_approach_found'.tl
          }
        else
          approach_popup_group_item = {
              :type => :group,
              :property_value => [],
              :property_label => approach.supply_nature
          }
          approach.questions.each_key do |label|
            unit = if approach.questions[label]['data-type'] == 'quantity'
                     Nomen::Unit.find(manure_zone.plan.data_unit.to_sym).human_name
                   else
                     ''
                   end
            approach_popup_group_item[:property_value] << { :unit => unit,
                                                             :type => approach.questions[label]['widget'],
                                                             :property_value => approach_app.parameters[label],
                                                             :text => Calculus::ManureManagementPlan::Approach.humanize_question(approach.questions[label]["text"]),
                                                             :property_label => label}
          end
          approaches_questions_properties << approach_popup_group_item
        end
      end
      approaches_questions_properties
    end

    def manure_popup(manure_zone_popup_properties,properties)
      render "backend/manure_management_plans/zone_popup", properties: manure_zone_popup_properties , popup_properties: properties
    end

    def manure_feature_description(manure_management_plan)
      regulatory_zones_shape, regulatory_zone_info = *regulatory_zones_feature_collection(manure_management_plan)
      cultivable_zones_properties = []
      georeadings_properties = []
      mmpz_in_vulnerable_area = manure_management_plan.zones_in_vulnerable_area

      # mmpz_in_vulnerable_area is an array of array of one element, so we convert it into a simple array

      georeadings = ManureManagementPlan.manure_georeadings

      # Build georeadings feature properties
      georeadings.each do |georeading|
        property = {}
        property[:id] = georeading.id
        property[:kind] = georeading.kind
        property[:name] = georeading.name
        georeadings_properties << property
      end

      # Build manure_management_plan feature properties
      manure_management_plan.zones.each do |manure_zone|
        property = {}

        # Create fields for popup

        # add properties calculated by regulatory zone
        unless regulatory_zone_info.nil?
          # extracts from info and place it in properties
          regulatory_zone_info.each_key do |key|
            value = regulatory_zone_info[key].select { |info_id, _value| info_id == manure_zone.id }
            property[ActiveSupport::Inflector.singularize(key)] = value.values.first.to_s
          end
        end
        # Is the mmpz in a vulnerable_zone ?
        property[:manure_zone_id] = manure_zone.id
        property[:name] = manure_zone.name
        property_popup = []
=begin
        property_popup << { :property_label => :is_in_vulnerable_zone,
                            :text => Calculus::ManureManagementPlan::Approach.humanize_question(:is_in_vulnerable_zone),
                            :type => :label,
                            :property_value =>  mmpz_in_vulnerable_area.include?(manure_zone.id.to_s).l}
=end
        property_popup << { :property_label => :cultivation_variety,
                            :type => :label,
                            :text => 'attributes.cultivation_variety'.t,
                            :property_value => manure_zone.cultivation_variety_name}
        property_popup << { :property_label => :soil_nature,
                            :text => 'attributes.soil_nature'.t,
                            :type => :label,
                            :property_value => Nomen::SoilNature.find(manure_zone.soil_nature).human_name}

        approach_app_prop = manure_zone_questions_properties(manure_zone)
        property_popup += approach_app_prop
        popup_content = manure_popup(property,property_popup)

        property["popup_content"] = popup_content
        cultivable_zones_properties << property
      end
      {
        georeadings: objects_to_feature_collection(georeadings, georeadings_properties),
        regulatory_zones: regulatory_zones_shape,
        cultivable_zones: manure_feature_collection(manure_management_plan, cultivable_zones_properties)
      }
    end

    def results_features(manure_management_plan, results)
      properties = []
      manure_management_plan.zones.each do |manure_zone|
        zone_properties = {}
        zone_properties[:name] = manure_zone.name
        zone_properties[:unit] = Nomen::Unit.find(manure_zone.plan.data_unit.to_sym).human_name
        zone_properties[:cultivation_variety] = manure_zone.cultivation_variety_name
        zone_properties[:soil_nature] =  Nomen::SoilNature.find(manure_zone.soil_nature).human_name
        manure_zone.manure_approach_applications.each do |approach_app|
          zone_properties[:results] = {approach_app.supply_nature => approach_app.results}
        end

        properties << zone_properties
      end

      { cultivable_zones: manure_feature_collection(manure_management_plan, properties) }
    end
  end
end
