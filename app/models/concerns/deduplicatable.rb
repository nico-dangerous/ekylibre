module Deduplicatable
  extend ActiveSupport::Concern

  module ClassMethods
    def deduplicate
      group_columns = columns_hash.keys - %w(id name number created_at updated_at creator_id updater_id lock_version)
      ids = connection.select_values("SELECT min(id) FROM #{table_name} GROUP BY #{group_columns.join(', ')}")
      join_condition = group_columns.map { |c| "((s.#{c} IS NULL AND d.#{c} IS NULL) OR (s.#{c} = d.#{c}))" }.join(' AND ')
      ids.each do |id|
        # puts id.to_s.yellow
        # Find duplicates
        query = "SELECT d.id FROM #{table_name} AS s LEFT JOIN #{table_name} AS d ON (#{join_condition}) WHERE s.id = #{id} AND d.id != #{id}"
        # puts query.magenta
        duplicate_ids = connection.select_values(query)
        next if duplicate_ids.empty?
        # puts duplicate_ids.size.to_s.yellow
        # Updates dependencies
        reflect_on_all_associations(:has_many).each do |r|
          # puts r.name.to_s.red # + ' ' + r.inspect
          next if r.options[:through]
          query = "UPDATE #{r.klass.table_name} SET #{r.foreign_key} = #{id} WHERE #{r.foreign_key} IN (#{duplicate_ids.join(', ')})"
          # puts query.yellow
          connection.execute(query)
        end
        connection.execute("DELETE FROM #{table_name} WHERE id IN (#{duplicate_ids.join(', ')})")
      end
    end
  end
end
