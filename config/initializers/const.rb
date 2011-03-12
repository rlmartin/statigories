CONST_LIST = YAML.load_file("#{Rails.root}/config/constants.yml")

class Const
  def self.get(const_name)
    result = nil
    const_name = const_name.to_s
    const = CONST_LIST[Rails.env][const_name] if CONST_LIST[Rails.env]
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
