namespace :db do
	namespace :fixtures do
		desc 'Create YAML fixtures from Constants data.'
		task :dump_constants => :environment do
			File.open("#{RAILS_ROOT}/db/fixtures/constants.yml", 'w') do |file|
				#constants = Constant.find(:all)
				constants = ActiveRecord::Base.connection.select_all("SELECT * FROM constants")
				i = "000"
				file.write constants.inject({}) { |hash, record|
					hash["constants_#{i.succ!}"] = record
					hash
				}.to_yaml 
			end
		end
	end
end

