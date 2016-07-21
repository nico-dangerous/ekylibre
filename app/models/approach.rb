
class Approach < Ekylibre::Record::Base

  def action_zone
    #Return the insee (String) in which the Approach is used
    action_zone
  end

  def supply_nature
    # return one element (String), can be (N or P or K ...)
    supply_nature
  end

  def priority_level
    # (unsigned Integer) 0 is the highest priority, used for Approach.get_corresponding_approach
    priority_level
  end

  def self.get_relevant_approach(shape)
    #Return the most relevant model for a given location

    # Here we use multiple queries because we can't use comparison on aggregations efficiently.
    # We extract some results because otherwise we would have to compute it multiple times.
    # For exemple by finding the approach id associated with the largest intersection between an approach shape and the shape(param)

    # Return the area (numeric value) for the largest intersection of an approach and the shape
    max = ActiveRecord::Base.connection.execute("(SELECT MAX(ST_AREA(ST_Intersection(Ap.shape,#{Charta.new_geometry(shape).geom}))) FROM Approaches Ap)").values.first.first

    # Returns the approaches that intersect the most (with larger area) with the shape
    intersecting_with_largest_area = ActiveRecord::Base.connection.execute("
                                          SELECT approach.id, ST_area(approach.shape)
                                          FROM Approaches approach
                                          where approach.id in (SELECT area_tab.id
                                                                FROM (SELECT App.id, ST_AREA(ST_Intersection(App.shape,#{Charta.new_geometry(shape).geom})) AS int_area
                                                                      FROM approaches App) area_tab
                                                                WHERE #{max} = cast(int_area AS numeric))").values

    # Find the smallest intersecting area
    # because we would have to compute all area multiple time if using aggregation to find the smallest area, and then the corresponding id,
    # I choosed to use ruby

    min_couple = intersecting_with_largest_area.first
    intersecting_with_largest_area.each do |couple|
      if couple[1] < min_couple[1]
        min_couple = couple
      end
    end
    model = Approach.find_by_id(min_couple[0])

     return Object.const_get("Calculus::ManureManagementPlan::"+model.name).new(model)
   end
end