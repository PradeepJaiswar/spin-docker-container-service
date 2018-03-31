# SPIN DOCKER CONTAINER SERVICE

Ruby REST API for spining up multiple containers of any type on single server mapping each container to subdomain using nginx-proxy container.

I have used it to run my all applications on single server mapping each one to subdomain on testing environment - saving me cost.

### Prerequisites ###

You will need the following things properly installed and runningon your computer

* [ruby > 2.4.0](https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.0.tar.gz)
* [Running Docker daemon](https://docs.docker.com/engine/installation/)
* [Running nginx-proxy container on port 80](https://github.com/jwilder/nginx-proxy)

## Nginx Proxy 
* `docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy` 
* for SSL `docker run -d -p 80:80 -p 443:443 -v /path/to/certs:/etc/nginx/certs -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy` 

## Installation

* `git clone <repository-url>` this repository
* change into the new directory
* `sudo gem install bundler`
* `bundle install`

## Running / Development

You will need the following environments variables

* `export SPIN_DOCKER_CONTAINER_SERVICE_DOMAIN=localhost/yourdomain.com`
* `export SPIN_DOCKER_CONTAINER_SERVICE_ROOT_PATH=/Users/pradeepjaiswar/workspace/apps`

## Uses

* `rerun 'rackup -p 3000'` or `rerun 'rackup -p 3000'`
* `don't run on port 80 as nginx-proxy should be running on port 80`

Visit [http://localhost:3000/](http://localhost:3000/)

## Uses on Production

* `sudo -E rackup -p 9000`
* `setup nginx proxy pass to port 9000`
* `don't run on port 443 as nginx-proxy should be running on port 443`

## REST API

For spinnig up new container

```POST /containers``` with below HEADERS
```container_image_name
   github_repo_url 
   mount_to_path
   container_expose_port
   container_startup_command
   ```
* container_image_name :: Docker hub image name for source code 
* github_repo_url :: Repo url for source code. This can be url of any hosting service for version control using git. bitbucket , gitlab etc. 
* mount_to_path :: Path where source code should be mounted in container
* container_expose_port :: Container port which will be mapped to subdomain
* container_startup_command :: Command to run inside container when it's start. This can be command to start your application or application setup command


Update the source code of running containers 

```PATCH /containers``` with below HEADERS
```github_repo_url
   branch_name 
   ```
* github_repo_url :: Repo url for source code
* branch_name :: Change the branch. Default is master

Kill containers 

```DELETE /containers``` with below HEADERS
```github_repo_url
   branch_name 
   ```
* github_repo_url :: Repo url for source code

Kill long running containers 

```DELETE /containers``` with below HEADERS
```container_image_name
   hours
   days
   ```
* container_image_name :: Mame of image whos child container should be kill
* hours :: Container running more than specified hours will get killed
* days :: Container running more than specified days will get killed
