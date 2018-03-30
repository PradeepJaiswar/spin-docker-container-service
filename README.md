# SPIN DOCKER CONTAINER SERVICE

### Prerequisites ###

You will need the following things properly installed on your computer.

* [ruby > 2.4.0](https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.0.tar.gz)
* [Running Docker daemon](https://docs.docker.com/engine/installation/) (with NPM)
* [Running nginx-proxy container](https://github.com/jwilder/nginx-proxy)

## Installation

* `git clone <repository-url>` this repository
* change into the new directory
* `sudo gem install bundler`
* `bundle install`

## Running / Development

You will need the following environments variables

* `export SPIN_DOCKER_CONTAINER_SERVICE_DOMAIN=localhost`
* `export SPIN_DOCKER_CONTAINER_SERVICE_DOMAIN_PATH=/Users/pradeepjaiswar/workspace/notebook`

On local make sure nginx-proxy is proxy is always running

* `docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy`

## Uses

* `rerun 'rackup -p 3000'` or `rerun 'rackup -p 3000'`

## Uses on Production

* `sudo -E rackup -p 9000`
* `setup nginx proxy pass to port 9000`


Visit [http://localhost:3000/](http://localhost:3000/)
