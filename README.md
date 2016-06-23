[![Build Status](https://travis-ci.org/lucasvanlierop/containerization-workshop.svg?branch=master)](https://travis-ci.org/lucasvanlierop/containerization-workshop)

Instructions and assignments for the containerization workshop.

# Requirements:

- 4GB free RAM (for DC/OS)
- Git
- A Github account
- A docker hub account
- Docker Engine >= 1.10 (see https://docs.docker.com/engine/installation/ for more information)
Note: If you're on OSX/Windows, you can sign up for the new and improved Docker Beta:
https://beta.docker.com/

# Useful resources:
- Marathon
    - [Port mapping](https://mesosphere.github.io/marathon/docs/ports.html) (Use Bridge mode with `portMappings` until you understand more about ports)
    - [Persistance and volumes](https://mesosphere.github.io/marathon/docs/persistent-volumes.html)
    - [Recipes](https://mesosphere.github.io/marathon/docs/recipes.html)
- DC/OS
    - [Architectural overview](https://docs.mesosphere.com/1.7/overview/architecture/)
    - [Concepts](https://docs.mesosphere.com/1.7/overview/concepts/)
    - [Roadmap](https://docs.mesosphere.com/1.7/overview/roadmap/)

# Setup
## Install DC/OS
```
git clone https://github.com/dcos/dcos-docker
cd dcos-docker
make installer
make all
```    

## Test if DC/OS works
- Open http://172.17.0.2/ (or the IP the installer told you). Note: When DC/OS tells you to go to your browser it might not be ready yet, hang on!

You can add the ip to you /etc/hosts if you like.

## Test if Marathon works
- Open http://172.17.0.2/service/marathon/ui/#/apps

# Troubleshooting

## Reinstalling DC/OS
If either the install did not succeed or got broken somehow. It's possible to clean up and reinstall:
The most reliable way I found so far was:

```
#dcos-docker

# remove master (should be stopped or killed first)
docker kill dcos-docker-master1
docker rm dcos-docker-master1

# restart docker, just to be sure nothing is running (dcos uses docker in docker...)
sudo service docker restart

# Build and install docker again
sudo make clean
make all
```

Further information: https://github.com/dcos/dcos-docker#troubleshooting

# Assignments

## Run a test script task
While this workshop is about containers, Marathon can run all kinds of tasks.
To get used to the tool first start with running a tiny shell script.

- Try the 'Hello Marathon: An Inline Shell Script' at: https://mesosphere.github.io/marathon/docs/application-basics.html

## Run a container task
Now you've ran your first task it's time to start a container task. 

- Start by running an creating a task in the Marathon UI with id `nginx-test` and docker image `nginx`.
After a while you see the nginx container has been started. 

- Check the configuration, you'll see something like:

```json
{
  "id": "/nginx-test",
  "cmd": null,
  "cpus": 1,
  "mem": 128,
  "disk": 0,
  "instances": 1,
  "container": {
    "type": "DOCKER",
    "volumes": [],
    "docker": {
      "image": "nginx",
      "network": "HOST",
      "privileged": false,
      "parameters": [],
      "forcePullImage": false
    }
  },
  "portDefinitions": [
    {
      "port": 10000,
      "protocol": "tcp",
      "labels": {}
    }
  ]
}
```

Now it's time to check if it works: 
- Go to the instances tab and check the id and port. 
You'll a like to the application, something like: `172.17.0.3:10000`. 

When you try to open this link you'll notice it doesn't work.

Why doesn't it work?, well Nginx is running on port 80 while the container has been given a random port, `10000` in this case.

This can be fixed by mapping the port on the host to the port in the container with a `portMapping`.
Note the network mode has to be changed from `HOST` to `BRIDGE` too.

- Go to the configuration editor in JSON mode and change the config to the following [nginx-with-ports-configured.json](nginx-with-ports-configured.json)

- Now click the link in the instances tab again and you should see the default Nginx page

## Scale a task
So far you have created just one instance but if that's not enough to handle all requests it's possible to scale to multiple instance.

- Try it with your own application using the UI.

*Note that Marathon is responsible for scaling tasks while DC/OS is responsible for scaling resources*

## Add a readyness check
Marathon can check if your application is fully ready.

- Add a readyness check for yopur application.
https://mesosphere.github.io/marathon/docs/readiness-checks.html

## Add a health check
Marathon likes to know if your application is healthy and can check this on a regular basis.

- Add a HTTP/TCP/Command check to your own application 
https://mesosphere.github.io/marathon/docs/health-checks.html

## Build your own small containerized application
If you have grasped the basics you can now Dockerize your own application.
- Create your own repo
- Create a small project
- Make sure it's require's at least one configuration value
- Create a Dockerfile according to the [Best Practices](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/) 

## Build, test and store and image of your application in CI
You can use your favorite CI solution for this This example will use TravisCI.
Also this example uses plan `make` but feel free to use your favorite task runner, build tools etc.

what needs to be done is:
- Build the application
    - Enable Docker in CI
    - Build an image of your application using Docker build in CI

- Test build
    - Start the image
    - Run a quick smoke test on the containerized application

- Push the image to Docker hub
    - Create a repository in Docker Hub
    - Login to Docker Hub in CI
    - Push Image to Docker Hub 

See [`.travis.yml`](travis.yml) for a basic setup

Note you have to configure all the `$DOCKER_*` credentials in your Travis repo under: *More options -> Settings -> Environment Variables*. 

## Pass configuration as environment variables
Containers should be unaware of their environment.
Most applications however need configuration.
One solution for this is to pass config as [environment variables](https://docs.docker.com/engine/reference/run/#env-environment-variables)

- Deploy your app with config pass as environment variable.

*Note: for For symfony users: it's possible to generate config cache based on the passed [environment variables](http://symfony.com/doc/current/cookbook/configuration/external_parameters.html#environment-variables).
These variables replace the `parameters.yml` file you might be used to.
This can be achieved by running bin/console cache:warmup as commands when starting the container.*

## Deploy remotely
While the UI is nice for playing around. The real work can be done using the [DC/OS client](https://docs.mesosphere.com/1.7/usage/cli/).
Follow the instructions in the [CLI client shipped with this project](bin/dcos).

The DC/OS client also provides access to Marathon, to see which commands are possible, type: `./bin/dcos marathon`.

Example add Nginx:
`./bin/dcos marathon app add examples/nginx-with-ports-configured.json`

- Now deploy remotely using the CLI. you can use the app configuration from the app marathon configuration editor in JSON mode as a start. 

# Bonus assignments

## Setup central logging
Each container potentially generates a lot of log information.
For obvious reasons it's good to aggregate all these logs in one place instead of scattered over numerous containers. 
In Docker it's common to send all logs to stdOut from where it can be aggreated to your favorite logging solution.

This can be done in multiple ways (ow really?) the easiest solution for now is to setup

https://github.com/gliderlabs/logspou    
https://docs.mesosphere.com/administration/logging/elk/? (needs a lot of RAM!)

- Setup your own a central logging solution

## Build a full fledged application
Hello World is very nice but now it's time to build a proper application.
Create an application using your favorite language/framework like Symfony.

If your project consists of multiple containers you can manage them as a group.
Groups can be deployed, scaled etc. as a whole.  Marathon has a [groups endpoint](https://mesosphere.github.io/marathon/docs/rest-api.html#groups)
https://mesosphere.github.io/marathon/docs/application-groups.html which can also be used via the DC/OS cli.

## Make your image smaller
- Use [Alpine linux](https://hub.docker.com/_/alpine/) as base instead of Debian 
- [Make as few layers as possible](https://www.ianlewis.org/en/creating-smaller-docker-images) 
- [Squash your images](https://www.ianlewis.org/en/creating-smaller-docker-images-part2)

[Useful information](https://www.iron.io/microcontainers-tiny-portable-containers/)

## Add more pre build tests to Travis
You're probably experienced with unit testing, code inspections etc. 
All these kind of tests need the same runtime the code itself does. 
So why install that on your CI server when it's already in the container?

- Start the development container on the CI: `make start_dev_container`
- Run a command like: `./bin/run-in-container ls`

## Add more post build tests to Travis
While smoke test just verifies does anything at all, normally want to run more tests.

- Add some more tests using your favorite tool (e.g. [Behat](http://docs.behat.org/en/v3.0/))

## Pull an image from a private repository
While many open source images can be used, business often have there own private images.

- Configure Marathon authentication for Docker Hub. 
https://mesosphere.github.io/marathon/docs/native-docker-private-registry.html

## Do a blue/green deployment
- Deploy multiple versions of the same application
https://mesosphere.github.io/marathon/docs/blue-green-deploy.html

## Act on events
Marathon emits events for everything that happens in. 
Think of how you could use that. For example to notify when a succesful deploy happened.
https://mesosphere.github.io/marathon/docs/event-bus.html

## Super bonus assignments

## Setup service discovery
Service discovery on a local installation is just plain hard, I'll see if we can get it working today. 
It involves adding a public node to 

- Build another application and let them talk to each other.

https://dcos.io/docs/1.7/administration/installing/custom/create-public-agent/
https://mesosphere.github.io/marathon/docs/service-discovery-load-balancing.html

## Deploy using constraints
- Deploy application only to host matching a given constraint
https://mesosphere.github.io/marathon/docs/constraints.html
