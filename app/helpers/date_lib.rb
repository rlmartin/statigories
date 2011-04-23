module DateLib
  def self.is_after(dtDate1, dtDate2)
		# Returns true if dtDate1 is after dtDate2.
		return (dtDate1.to_i - dtDate2.to_i) > 0
	end
end
