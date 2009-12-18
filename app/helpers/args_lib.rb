# These are methods to be used as an "include" library in other classes.
# The methods in this library deal with the args array.
module ArgsLib
	include ArrayLib
	include HashLib

	# name:		The name of the option to append (symbol).
	# value:	The value of the option to append.
	# args_list:	The args array to examine (Array).
	# default_args_list:	If args_list if empty, this will be used to initialize the list (Array).  It should not include the option to append.
	# hash_index:	(Optional) The index of the hash to append to.  Defaults to the last.
	protected
	def self.append_option!(args_list, name, value, default_args_list = nil, hash_index = nil)
		# Make sure the default_args_list is an array.
		default_args_list = ArrayLib.force_array(default_args_list)
		# Fill in the args_list with the default_args_list, if necessary.
		ArrayLib.fill_missing_with! args_list, default_args_list
		# Default hash_index to the last member of the args_list array.
		if (hash_index == nil) or ((hash_index < 0) and (args_list.length > 0)) then hash_index = args_list.length - 1
		elsif args_list.length <= hash_index
			# Fill to the hash_index if necessary.
			args_list.length.upto(hash_index - 1) {args_list << nil}
		end
		# If the final member of args_list is a Hash, append the name/value to the Hash
		if args_list[hash_index].is_a?(Hash) then HashLib.append_to_hash_unique(args_list[hash_index], name, value)
		# If the hash_index is not the final member of the array, simply set it.
		elsif args_list.length > hash_index then args_list[hash_index] = {name => value}
		# If the final member of args_list is not a hash, append the name/value as a new Hash
		else args_list << {name => value}
		end
	end

  # This will remove the argument with the given name from the args list if it exists.  It returns the removed value (or nil).
  def self.remove_argument!(args_list, name)
    result = nil
    unless args_list == nil
		  # If the final member of args_list is a Hash, remove the value from the Hash
		  if args_list[args_list.length - 1].is_a?(Hash): result = args_list[args_list.length - 1].delete(name) end
    end
    result
  end

end
