class Constant < ActiveRecord::Base
  include StringLib

  protected
  # This function encapsulates the logic of inserting a constant value into the correct language hash.
  def self.load_const(const)
      hash_name = StringLib.to_const_name(const.lang)
      unless hash_name == '': hash_name += '_' end
      hash_name += 'CONST_LIST'
      unless const_defined?(hash_name): const_set(hash_name, {}) end
      hash = const_get(hash_name)
      const_name = const.name.gsub(/\W+/, '_').downcase.to_sym
      if const.array
        hash[const_name] = const.value.split(',')
        hash[const_name].each do | value |
          value = StringLib.cast(StringLib.trim(value), const.cast_as)
        end
      else
        hash[const_name] = StringLib.cast(const.value, const.cast_as)
      end
      # Create a list of whether or not a constant is stale.
      self::CONST_STALE[const_name] = false
  end

  # This method pulls all applicable (active & correct server_type) constants and loads them into
  # a cache on the object, so that the constants are loaded only once - when the object is first used.
  def self.cache_constants
    # Get the configured server type (dev, prod, or test)
		begin
		  server_type = find(:first, :conditions => { :active => true, :name => "server_type" })
		  if server_type == nil
		    server_type = ""
		  else
		    server_type = server_type.value
		  end
		  const_set("SERVER_TYPE", server_type.downcase)
		  const_set("CONST_STALE", {})
		  # Load the constants into the hashes for each language
		  find(:all, :conditions => ["(server_type = :server_type OR server_type = '') AND active AND NOT name = ''", { :server_type => self::SERVER_TYPE }]).each do | const |
		    load_const(const)
			end
		rescue
			const_set("CONST_LIST", {})
		  const_set("SERVER_TYPE", "")
		  const_set("CONST_STALE", {})
    end
  end

  # Call the method to load the constants.
  cache_constants

  # The main accessor to get a constant value.
  def self.get(const_name)
    const_name = StringLib.to_sym(const_name)
    hash = get_lang_hash
    # Make sure the loaded constant value is not stale
    if (self::CONST_STALE[const_name] == nil) or (self::CONST_STALE[const_name]): refresh!(const_name) end
    if hash[const_name] == nil
      # Load from the default list if no lang-specific value is available
      self::CONST_LIST[const_name]
    else
      # Load from the lang-specific value if available
      hash[const_name]
    end
  end

  # Meant to be used internally only.
  def self.get_lang_hash
    # In the future, look for a stored language value (session var, cookie, subdomain, etc.) here.
    lang = "eng"
    if const_defined?(lang.upcase + '_CONST_LIST')
      const_get(lang.upcase + '_CONST_LIST')
    else
      self::CONST_LIST
    end
  end

  def self.refresh!(const_name)
		begin
		  const_name = StringLib.to_sym(const_name)
		  find(:all, :conditions => ["(server_type = :server_type OR server_type = '') AND active AND name = :const_name", { :server_type => self::SERVER_TYPE, :const_name => const_name.to_s }]).each do | const |
		    load_const(const)
		  end
		  if self::CONST_STALE[const_name] == nil: self::CONST_STALE[const_name] = false end
		rescue
		end
  end
end
