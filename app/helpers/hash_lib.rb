# These are methods to be used as an "include" library in other classes.
# The methods in this library deal with Hashes.
module HashLib
	protected
	def self.append_to_hash_unique(hash, key, value)
		if hash[key]
			if value.is_a?(Array)
				if hash[key].is_a?(Array)
					hash[key] = (hash[key] | value)
				else
					hash[key] = ([hash[key]] | value)
				end
			elsif value.is_a?(String)
				arr1 = value.split(',')
				if hash[key].is_a?(Array)
					arr2 = hash[key]
				else
					arr2 = hash[key].split(',')
				end
				hash[key] = (arr2 | arr1).join(',')
			else
				hash[key] += value
			end
		else
			hash.merge!({key => value})
		end
	end
end
