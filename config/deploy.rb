# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require 'rvm/capistrano'
#set :rvm_ruby_string, '1.9.2'
require 'bundler/capistrano'

#require 'bundler/capistrano'

set :application, "statigories.com"
# Note that this IP address may change for future deployments.
set :launch_ip, "75.101.154.86" # "statigories.com"
ssh_options[:keys] = ["/home/ryan/Documents/id-linux-keypair"]
set :repository, 
"svn+ssh://svn@statigories.com/vol/svn/statigories.com/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm_username, "svn"
set :scm_checkout, "export"

set :user, "root"
default_run_options[:pty] = true
set :use_sudo, false
set :rails_env, "migration"

role :app, "#{launch_ip}"
role :web, "#{launch_ip}"
role :db,  "#{launch_ip}", :primary => true

namespace :deploy do
#	desc "Restart the Mongrel cluster"
#	task :restart, :roles => :app do
#		stop
#		start
#	end

	# Other startup methods (memcached, backgroundrb, etc) should be added here.
	desc "Start the Mongrel cluster and Nginx"
	task :start, :roles => :app do
#		start_mongrel
		start_nginx
	end

	# Other stop methods should be added here.
	desc "Stop the Mongrel cluster and Nginx"
	task :stop, :roles => :app do
#		stop_mongrel
		stop_nginx
	end

#	desc "Start Mongrel"
#	task :start_mongrel, :roles => :app do
#		begin
#			run "/etc/init.d/mongrel_cluster start"
#		rescue RuntimeError => e
#			puts e
#			puts "Mongrel appears to be on already."
#		end
#	end

#	desc "Stop Mongrel"
#	task :stop_mongrel, :roles => :app do
#		begin
#			run "/etc/init.d/mongrel_cluster stop"
#		rescue RuntimeError => e
#			puts e
#			puts "Mongrel appears to be off already."
#		end
#	end

	desc "Start nginx"
	task :start_nginx, :roles => :app do
		begin
			run "/etc/init.d/nginx start"
		rescue RuntimeError => e
			puts e
			puts "Nginx appears to be on already."
		end
	end

	desc "Stop Nginx"
	task :stop_nginx, :roles => :app do
		begin
			run "/etc/init.d/nginx stop"
		rescue RuntimeError => e
			puts e
			puts "Nginx appears to be off already."
		end
	end
end

# Put this back in for a true (i.e. not alpha) launch
#task :before_deploy do
#  `rake sitemap:generate`
#  `svn commit public/sitemap.xml -m ""`
#  `svn commit public/sitemap/static.xml -m ""`
#end

# No fixtures and no constants in the DB, so don't need this.
#task :after_migrate do
#	run "cd #{deploy_to}/current; rake db:fixtures:load FIXTURES_PATH=db/fixtures RAILS_ENV=migration"
#	set :db_pass, Capistrano::CLI.password_prompt("MySQL Password:")
#	run 'mysql -e "UPDATE constants SET active = 0 WHERE name = \'server_type\'" -u goroam_iusr -h localhost -p -D goroam_geo' do |ch, stream, out|
#     ch.send_data "#{db_pass}\n" if out=~ /^Enter password:/
#  end
#	run 'mysql -e "UPDATE constants SET active = 1 WHERE name = \'server_type\' AND value = \'prod\'" -u goroam_iusr -h localhost -p -D goroam_geo' do |ch, stream, out|
#     ch.send_data "#{db_pass}\n" if out=~ /^Enter password:/
#  end
#end

#task :before_migrate do
#  `rake db:fixtures:dump_constants`
#  `svn commit db/fixtures/constants.yml -m ""`
#  `scp -i ~/Documents/id-linux-keypair root@#{launch_ip}:#{release_path}/db/fixtures db/fixtures/constants.yml`
#end

task :set_permissions, :roles => :app do
	run "chown -hR root:www-data #{deploy_to}"
end

after "deploy:symlink", "set_permissions"

