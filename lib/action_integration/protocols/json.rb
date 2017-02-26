module ActionIntegration
  module Protocols
    # JSON protocol methods. Rely on Base.
    module JSON
      include Protocols::RestBase

      def get(path, options = {}, &block)
        get_base(path, options, &block)
      end

      def post(path, data, options = {}, &block)
        post_base(path, data, { 'content-type' => 'application/json' }.merge(options), &block)
      end

      def put(path, data, options = {}, &block)
        put_base(path, data, { 'content-type' => 'application/json' }.merge(options), &block)
      end

      def patch(path, data, options = {}, &block)
        patch_base(path, data, { 'content-type' => 'application/json' }.merge(options), &block)
      end

      def delete(path, options = {}, &block)
        delete_base(path, options, &block)
      end
    end
  end
end
