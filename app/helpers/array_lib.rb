# These are methods to be used as an "include" library in other classes.
# The methods in this library deal with Arrays.
module ArrayLib
	# This method ensures that the given value is an Array.
	# Usage: arr1 = ArrayLib.force_array(arr1)
	# The assignment is necessary because the value can't be passed by reference.
	protected
	def self.force_array(value)
		unless value.is_a?(Array)
			if value == nil then value = []
			else value = [value]
			end
		else value = value
		end
	end

	# This method fills all members of the arr1 Array that are nil or missing with the
	# corresponding value from the arr2 Array.  No assignment is necessary.
	# Usage: ArrayLib.fill_missing_with(arr1, arr2)
	# arr1 will be altered.
	protected
	def self.fill_missing_with!(arr1, arr2)
		arr2.each_index do |i|
			if (arr1.length > i) and (arr1[i] == nil) then arr1[i] = arr2[i]
			elsif arr1.length <= i then arr1 << arr2[i]
			end
		end
	end
end
