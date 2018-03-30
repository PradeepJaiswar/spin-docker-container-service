module SpinDockerContainer
	class Env
		def get_domain()
			return ENV["SPIN_DOCKER_CONTAINER_SERVICE_DOMAIN"]
		end

		def get_root_repo_path()
			return ENV["SPIN_DOCKER_CONTAINER_SERVICE_ROOT_PATH"]
		end
	end
end
