CONST_LIST = YAML.load_file("#{Rails.root}/config/constants.yml")

class Const
  def self.get(const_name)
    result = nil
    const_name = const_name.to_s
    subdomain = ''
    # A bit of a hack here, since this relies on Thread.current['request'] being set prior to this being called.
    subdomain = Thread.current['request'].subdomains.join('.').gsub(/\W/, '_') if Thread.current['request']
    const = CONST_LIST[Rails.env][const_name + '_' + subdomain] if CONST_LIST[Rails.env] and subdomain != ''
    const = CONST_LIST[Rails.env][const_name] if CONST_LIST[Rails.env] and const == nil
    const = CONST_LIST['default'][const_name + '_' + subdomain] unless const
    const = CONST_LIST['default'][const_name] unless const
    if const
      if const['stale'] == nil or const['stale'] === true
        if const['array'] and StringLib.cast(const['array'], :bool)
          const['value'] = const['value'].split(',')
          const['value'].each_index do | i |
            const['value'][i] = StringLib.cast(StringLib.trim(const['value'][i]), const['cast_as'])
          end
        else
          const['value'] = StringLib.cast(const['value'], const['cast_as'])
        end
        const['stale'] = false
      end
      result = const['value']
    end
    result
  end
end
