module ActiveRecord
  class Base
    def _trim_values
      self.attributes.each_pair do |key, value|
        self[key] = value.strip if value.respond_to?('strip')
      end
    end
  end
end
