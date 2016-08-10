
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
      objects.each_with_index  do |object, index|
        geojson = Charta.new_geometry(object.shape).to_geojson
        properties[index].each do |key,value|
          if value.nil?
            properties[index][key] = object.send(:key)
          end
        end
        features << RGeo::GeoJSON::Feature.new(rgeo_coder.decode(geojson),nil,properties[index])
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
       unless regulatory_zones_shape == Charta::GeometryCollection.empty
         return [features_to_feature_collection([geometry_to_feature(regulatory_zones_shape)]),info]
       end
       return [:no_data, info]
    end

    def manure_zone_questions_properties(manure_zone)
      #Fill two hashes using the approach of the manure zone
      #approach_modal_fields contains the text and approaches_properties the answer

      approaches_properties = {}
      approach_applications = manure_zone.manure_approach_applications
      approaches_properties["group"] = {}
      approach_applications.each do |approach_app|
        approach = approach_app.approach
        if approach.nil?
          approaches_properties["group"][approach_app.supply_nature] = {"error" =>{
              "widget" => "label",
              "text" => "error".tl,
              "value" => "no_approach_found".tl
          }}
        else
          approaches_properties["group"][approach.supply_nature]={}
          approach.questions.each_key  do |label|
            if (approach.questions[label]["data-type"] == "quantity")
              unit = Nomen::Unit.find(manure_zone.plan.data_unit.to_sym).human_name
            else
              unit = ""
            end
            approaches_properties["group"][approach.supply_nature][label] = {"unit" => unit,"widget" => approach.questions[label]["widget"], "value" => approach_app.parameters[label], "text" => ManureApproachApplication.humanize_question(approach.questions[label]["text"]), "label" => label}
          end
        end
      end
      return approaches_properties
    end

    def manure_feature_description(manure_management_plan)

      regulatory_zones_shape, regulatory_zone_info = *regulatory_zones_feature_collection(manure_management_plan)
      cultivable_zones_properties = []
      georeadings_properties = []
      modal_fields = {}
      mmpz_in_vulnerable_area = manure_management_plan.zones_in_vulnerable_area

      #mmpz_in_vulnerable_area is an array of array of one element, so we convert it into a simple array

      georeadings = ManureManagementPlan.manure_georeadings

      #Build georeadings feature properties
      georeadings.each do |georeading|
        property = {}
        property[:id] = georeading.id
        property[:kind] = georeading.kind
        property[:name] = georeading.name
        georeadings_properties << property
      end

      #Build manure_management_plan feature properties
      manure_management_plan.zones.each do |manure_zone|
        property = {}

=begin
        :popup => [{type: :label, property_label: :vulnerable_zone.tl, property_value: :vulnerable_zone},
                   {type: :input, property_label: "nomenclatures.dimensions.items.surface_area".t, property_value: :area},
                   {type: :label, property_label: "attributes.cultivation_variety".t, property_value: :variety},
                   {type: :label, property_label: "attributes.soil_nature".t, property_value: :soil_nature}],
=end


        #Create fields for modal
        approach_app_prop = manure_zone_questions_properties(manure_zone)

        #add properties calculated by regulatory zone
        unless regulatory_zone_info.nil?
          # extracts from info and place it in properties
          regulatory_zone_info.each_key { |key|
            value = regulatory_zone_info[key].select{ |info_id,value| info_id == manure_zone.id }
            property[ActiveSupport::Inflector.singularize(key)] = value.values.first.to_s
          }
        end
        property_modal = {}
        #Is the mmpz in a vulnerable_zone ?
        property[:vulnerable_zone] = mmpz_in_vulnerable_area.include?(manure_zone.id.to_s).to_s
        property[:manure_zone_id] = manure_zone.id
        property[:name] = manure_zone.name
        property_modal[:variety] = {"text" => "attributes.cultivation_variety".t, "type"=> "label", "value" => manure_zone.cultivation_variety_name}
        property_modal[:soil_nature] =  {"text" => "attributes.soil_nature".t, "type"=> "label", "value" => Nomen::SoilNature.find(manure_zone.soil_nature).human_name}

        property_modal = {"modalAttributes" => property_modal}
        property_modal["modalAttributes"] = property_modal["modalAttributes"].merge(approach_app_prop)
        cultivable_zones_properties << property.merge(property_modal)
      end
      return {
              :georeadings => objects_to_feature_collection(georeadings,georeadings_properties),
              :regulatory_zones => regulatory_zones_shape,
              :cultivable_zones => manure_feature_collection(manure_management_plan,cultivable_zones_properties)
              }
    end

    def manure_zone_result_properties(manure_zone,results)
      properties = {}
      approach_applications = manure_zone.manure_approach_applications
      zone_results = results[manure_zone.id]
      unit = Nomen::Unit.find(manure_zone.plan.data_unit.to_sym).human_name

      approach_applications.each do |approach_app|
        application_results = {"modalAttributes" => {"group" => {approach_app.supply_nature => {}}}}
        zone_results[approach_app.id].each_key do |key|
          application_results["modalAttributes"]["group"][approach_app.supply_nature][key] = {"text" => ManureApproachApplication.humanize_result(key) ,"widget" => "label","value" => zone_results[approach_app.id][key], "unit" => unit}
        end
         properties.merge!(application_results)
      end
      properties
    end

    def results_features(manure_management_plan, results)

      cultivable_zones_properties=[]
      manure_management_plan.zones.each do |manure_zone|
        property = manure_zone_result_properties(manure_zone,results)
        property[:name] = manure_zone.name
        cultivable_zones_properties << property
      end
      return  {:cultivable_zones => manure_feature_collection(manure_management_plan,cultivable_zones_properties)}
    end

  end
end

