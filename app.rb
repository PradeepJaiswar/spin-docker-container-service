require "sinatra"
require "json"
require 'sinatra/cross_origin'
require 'digest/md5'

require_relative "lib/service"
require_relative "lib/env"

def success_msg(msg, code)
	response = {
		'data' => {}
	}
	response['data'] = msg;
	halt code, response.to_json
end

def error_msg(msg, code)
	response = {
		'error' => {}
	}
	response['error']['message'] = msg;
	halt code, response.to_json
end

set :bind, '0.0.0.0'

configure do
	enable :cross_origin
end

before do
	response.headers['Access-Control-Allow-Origin'] = '*'
end

options "*" do
	response.headers["Access-Control-Allow-Methods"] = "OPTIONS, POST, DELETE, PATCH"
  response.headers["Access-Control-Allow-Headers"] = "access-token, Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

delete '/containers/kill' do
	protocol = request.env['REQUEST_URI'].split(':')[0]
	request_type = protocol === 'http' ? 'HTTP' : 'HTTPS'

	container_image_name = request.env["#{request_type}_CONTAINER_IMAGE_NAME"]
	error_msg('no_container_image_specified', 400) if container_image_name.nil?

	hours = request.env["#{request_type}_HOURS"]
	error_msg('no_hours_specified', 505) if hours.nil?

	days = request.env["#{request_type}_DAYS"]
	error_msg('no_days_specified', 505) if days.nil?

	running_containers = `docker ps --filter ancestor=#{container_image_name} --format '{{.Names}}|{{.Status}}'`
	running_containers_array = running_containers.split(/\n/)
	killed = []
	if running_containers_array.length > 0
		running_containers_array.each {
			|containers|
			container = containers.split('|')
			name  = container[0]
			status = container[1].gsub("Up", "").strip!
			split_status= status.split(' ')
			if split_status.length == 2
				status_number = split_status[0].to_i
				status_string = split_status[1]
				if (status_string === 'hours' && status_number > hours.to_i)
					docker_port = `docker rm -f #{name}`
					killed.push(container)
				end
				if (status_string === 'days' && status_number > days.to_i)
					docker_port = `docker rm -f #{name}`
					killed.push(container)
				end
			end
		}
	end
	success_msg(killed, 200)
end

delete '/containers' do
	protocol = request.env['REQUEST_URI'].split(':')[0]
	request_type = protocol === 'http' ? 'HTTP' : 'HTTPS'

	spin_docker_container_service = SpinDockerContainer::Service.new

	github_repo_url = request.env["#{request_type}_GITHUB_REPO_URL"]
	error_msg('no_github_repo_url_specified', 400) if github_repo_url.nil?

	github_repo_name = github_repo_url.split('/')[-1]
	container_name = Digest::MD5.hexdigest(github_repo_url)

	# kill container
	docker_port = `docker rm -f #{container_name}`

	success_msg("container_killed", 200)
end

patch '/containers' do
	protocol = request.env['REQUEST_URI'].split(':')[0]
	request_type = protocol === 'http' ? 'HTTP' : 'HTTPS'

	spin_docker_container_service = SpinDockerContainer::Service.new

	github_repo_url = request.env["#{request_type}_GITHUB_REPO_URL"]
	error_msg('no_github_repo_url_specified', 400) if github_repo_url.nil?

	github_repo_name = github_repo_url.split('/')[-1]
	container_name = Digest::MD5.hexdigest(github_repo_url)
	branch_name = request.env["#{request_type}_BRANCH_NAME"] ? request.env["#{request_type}_BRANCH_NAME"] : 'master'
	spin_docker_container_env = SpinDockerContainer::Env.new

	root_repo_path = spin_docker_container_env.get_root_repo_path()
	error_msg('environment_variables_not_set', 500) if !root_repo_path

	git_repo_present = spin_docker_container_service.git_repo_present(root_repo_path,github_repo_name)
	if !git_repo_present
		error_msg('github_repo_not_present', 500) if !root_repo_path
	end

  #if everything is ok reset the repo with branch name
	Dir.chdir "#{root_repo_path}/#{github_repo_name}"
	git_checkout_repo = `git checkout .`
	git_pull = `git pull origin #{branch_name}`

	success_msg("repo_restore", 200)
end

post '/containers' do
	protocol = request.env['REQUEST_URI'].split(':')[0]
	request_type = protocol === 'http' ? 'HTTP' : 'HTTPS'

	spin_docker_container_service = SpinDockerContainer::Service.new

	container_image_name = request.env["#{request_type}_CONTAINER_IMAGE_NAME"]
	error_msg('no_container_image_specified', 400) if container_image_name.nil?

	container_expose_port = request.env["#{request_type}_CONTAINER_EXPOSE_PORT"]
	error_msg('no_container_expose_port_specified', 400) if container_expose_port.nil?

	mount_to_path = request.env["#{request_type}_MOUNT_TO_PATH"]
	error_msg('no_mount_to_path_specified', 400) if mount_to_path.nil?

	github_repo_url = request.env["#{request_type}_GITHUB_REPO_URL"]
	error_msg('no_github_repo_url_specified', 400) if github_repo_url.nil?

	valid_github_url = spin_docker_container_service.valid_url?(github_repo_url)
	error_msg('invalid_github_repo_url', 400) if !valid_github_url

	container_startup_command = request.env["#{request_type}_CONTAINER_STARTUP_COMMAND"] ? request.env["#{request_type}_CONTAINER_STARTUP_COMMAND"] : ''
	github_repo_name = github_repo_url.split('/')[-1]
	container_name = Digest::MD5.hexdigest(github_repo_url)

	spin_docker_container_env = SpinDockerContainer::Env.new

	root_repo_path = spin_docker_container_env.get_root_repo_path()
	error_msg('environment_variables_not_set', 500) if !root_repo_path

	root_repo_preset = spin_docker_container_service.root_repo_preset(root_repo_path)
	if !root_repo_preset
		create_root_repo = spin_docker_container_service.create_root_repo(root_repo_path)
		error_msg('create_root_repo_failed', 500) if !create_root_repo
	end

	git_repo_present = spin_docker_container_service.git_repo_present(root_repo_path,github_repo_name)
	if !git_repo_present
			git_clone_repo = `git clone #{github_repo_url}.git #{root_repo_path}/#{github_repo_name}`
	end

	# double check if repo is cloned
	git_repo_present = spin_docker_container_service.git_repo_present(root_repo_path,github_repo_name)
	if !git_repo_present
		error_msg('clone_repo_failed', 500)
	end

	# Kill any previous container for same assignment
	# Don't delete this
	docker_kill = `docker rm -f #{container_name}`

	domain_name = spin_docker_container_env.get_domain()
	error_msg('environment_variables_not_set', 500) if !domain_name

	# magic :: make sure https://github.com/jwilder/nginx-proxy is always running
	start_docker = `docker run -e VIRTUAL_HOST=#{container_name}.#{domain_name} -v #{root_repo_path}/#{github_repo_name}:#{mount_to_path} --name=#{container_name} -d --expose #{container_expose_port} #{container_image_name} /bin/bash -c "#{container_startup_command}"`

	subdomain_url = "#{protocol}://#{container_name}.#{domain_name}"

	success_msg(subdomain_url, 200)
end
