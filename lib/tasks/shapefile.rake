namespace :shapefile do
  desc "Store a shape in the database using a shapefile. The geometry object is converted
        from the parametered srid to EPSG4326."
  task :import, [:path,:name,:srid] => :environment do |t,args|

  raise "arguments cannot be empty" if args.any?{|k,e| e.nil?}
    RGeo::Shapefile::Reader.open(args.path, srid: args.srid) do |file|
      file.each do |record|
        geometry = Charta::Geometry.new(record.geometry).srid=(args.srid)
        geometry4326 = geometry.transform(4326)

      end
      file.rewind
      record = file.next
    end
  end
end


