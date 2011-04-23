require 'csv'

namespace :db do
	namespace :fixtures do
#		desc 'Create YAML fixtures from Constants data.'
#		task :dump_constants => :environment do
#			File.open("#{Rails.root.join('db', 'fixtures', 'constants.yml')}", 'w') do |file|
#				#constants = Constant.find(:all)
#				constants = ActiveRecord::Base.connection.select_all("SELECT * FROM constants")
#				i = "000"
#				file.write constants.inject({}) { |hash, record|
#					hash["constants_#{i.succ!}"] = record
#					hash
#				}.to_yaml 
#			end
#		end
	end
end

namespace :date do
  desc 'Create Timezone Abbreviation Mapping'
  arrMapping = YAML.load_file("#{Rails.root}/config/utc_offset_translation.yml")
  task :build_timezones do
    # Start building the hash of values, with the default list.
    areas = Hash.new
    areas['default'] = Hash.new
    # Open and process a CSV of values: abbreviation, name, area/contry, UTC offset
    CSV.foreach("#{Rails.root.join('config', 'timezones.csv')}") do |row|
      strArea = 'default'
      # If the abbreviation already exists in the list...
      if areas[strArea][row[0].downcase]
        # ...use the North America option as the default
        if row[2].downcase == 'north america'
          # Move the non-North America option into a different non-default list.
          strArea = areas['default'][row[0].downcase]['area']
          areas[strArea] = Hash.new unless areas[strArea]
          areas[strArea][row[0].downcase] = areas['default'][row[0].downcase]
          strArea = 'default'
        else
          # Create a new non-default list.
          strArea = row[2].downcase
          areas[strArea] = Hash.new unless areas[strArea]
        end
      end
      # Create a new entry.
      areas[strArea][row[0].downcase] = Hash.new
      areas[strArea][row[0].downcase]['name'] = row[1]
      areas[strArea][row[0].downcase]['area'] = row[2].downcase
      # Figure out the correct timezone identifier to map to.
      # General pattern is like this: UTC +/- X hour(s). Pull only the numeric value.
      strIdentifier = row[3].gsub(/utc/i, '').gsub(/hours?/i, '').gsub(/\s/, '')
      # Remove the plus sign.
      strIdentifier = strIdentifier.slice(1, strIdentifier.length - 1) if strIdentifier[0] == '+'
      # Convert to an int if possible
      strIdentifier = strIdentifier.to_i if strIdentifier.to_i.to_s == strIdentifier
      # For just 'UTC', the offset is 0.
      strIdentifier = 0 if strIdentifier == ''
      # Find the mapping and use it.
      strIdentifier = arrMapping[strIdentifier] if arrMapping[strIdentifier]
      areas[strArea][row[0].downcase]['identifier'] = strIdentifier
    end
		File.open("#{Rails.root.join('config', 'timezones.yml')}", 'w') do |file|
			file.write areas.to_yaml 
		end
  end
end
