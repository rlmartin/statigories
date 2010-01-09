module ActiveRecord
  class Base
    @@_req = nil

    def _trim_values
      self.attributes.each_pair do |key, value|
        self[key] = value.strip if value.respond_to?('strip')
      end
    end

    def self._set_request(request)
      # Kind of a hack, but provides a centralized method to pass the HTTP request object into the model.
      # This should be automatically called at the controller level (in the Base class or something).
      @@_req = request
    end
  end
end
