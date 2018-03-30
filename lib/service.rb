module SpinDockerContainer
	class Service
		def git_repo_present(root_repo_path,repo_name)
			return Dir.exist?("#{root_repo_path}/#{repo_name}")
		end

		def root_repo_preset(root_repo_path)
			return Dir.exist?("#{root_repo_path}")
		end

		def valid_url?(url)
  		url_regexp = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  		url =~ url_regexp ? true : false
		end

		def create_root_repo(root_repo_path)
			repo_repo = FileUtils.mkdir(root_repo_path)
			if repo_repo
				return repo_repo
			else
				return false
			end
		end
	end
end
