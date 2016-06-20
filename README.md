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
Open http://172.17.0.2/ (or the IP the installer told you). Note: When DC/OS tells you to go to your browser it might not be ready yet, hang on!
You can add the ip to you /etc/hosts if you like.

## Test if Marathon works
http://172.17.0.2/service/marathon/ui/#/apps

# Troubleshooting

## Reinstalling DC/OS
If either the install did not succeed or got broken somehow. It's possible to clean up and reinstall:
Further information: https://github.com/dcos/dcos-docker#troubleshooting

```
#dcos-docker
sudo make clean
make all
```
    
# Assignments

## Run a test script task
While this workshop is about containers, Marathon can run all kinds of tasks.
To get used to the tool first start with running a tiny shell script.
Try the 'Hello Marathon: An Inline Shell Script' at: https://mesosphere.github.io/marathon/docs/application-basics.html

## Run a container task
Now you've ran your first task it's time to start a container task.

## Scale a task
So far you have created just one instance but if that's not enough to handle all requests it's possible to scale to multiple instance.
Try it with your own application using the UI.

*Note that Marathon is responsible for scaling tasks and DC/OS for scaling resources*

## Add a readyness check
Marathon can check if your application is fully ready.

Add a readyness check for yopur application.
https://mesosphere.github.io/marathon/docs/readiness-checks.html

## Add a health check
Marathon likes to know if your application is healthy and can check this on a regular basis.

## Build your own small containerized application
If you have grasped the basics you can now Dockerize your own application.
- Create your own repo
- Create a small project
- Create a Dockerfile according to the [Best Practices](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)

Add a HTTP/TCP/Command check to your own application 
https://mesosphere.github.io/marathon/docs/health-checks.html

## Build, test and store and image of your application in CI
You can use your favorite CI solution for this This example will use TravisCI

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

## Pass configuration as environment variables
Containers should be unaware of their environment.
Most applications however need configuration.
One solution for this is to pass config as [environment variables](https://docs.docker.com/engine/reference/run/#env-environment-variables)

Deploy your app with config pass as environment variable.

*Note: for For symfony users: it's possible to generate a `parameters.yml` file bases on the passed [environment variables](http://symfony.com/doc/current/cookbook/configuration/external_parameters.html#environment-variables).
This can be achieved by running bin/console cache:warmup as command when starting the container.

## Deploy remotely
Using the UI to create applications fine for playing around.
If you want to automate deployment you can use the
[Marathon API](https://mesosphere.github.io/marathon/docs/rest-api.html).

Alternatively you can install the [DC/OS client](https://docs.mesosphere.com/1.7/usage/cli/).

Deploy remotely, you can use copy the configuration from the marathon configuration editor in JSON mode as a start.

## Setup central logging
Each container potentially generates a lot of log information.
For obvious reasons it's good to aggregate all these logs in one place instead of scattered over numerous containers. 
In Docker it's common to send all logs to stdOut from where it can be aggreated to your favorite logging solution.

This can be done in multiple ways (ow really?) the easiest solution for now is to setup

https://github.com/gliderlabs/logspout and/ore    
?https://docs.mesosphere.com/administration/logging/elk/? (needs a lot of RAM!)

Setup your own a central logging solution using

# Bonus assignments

## Build a full fledged application
Hello World is very nice but now it's time to build a proper application.
Create an application using your favorite language/framework.

If your project consists of multiple containers you can manage them as a group.
Groups can be deployed, scaled etc. as a whole. If you are using the Marathon API make sure to use the [groups endpoint](https://mesosphere.github.io/marathon/docs/rest-api.html#groups)
https://mesosphere.github.io/marathon/docs/application-groups.html

## Make your image smaller
- ?Use busybox?
- [Squash your images](https://www.ianlewis.org/en/creating-smaller-docker-images-part2)
- [Make as few layers as possible](https://www.ianlewis.org/en/creating-smaller-docker-images) 

[Useful information](https://www.iron.io/microcontainers-tiny-portable-containers/)

## Add more post build tests to Travis
While smoke test only verifies if the application starts at all. 
You could try and add more tests using your favorite tool (e.g. [Behat](http://docs.behat.org/en/v3.0/))

## Pull an image from a private repository
While many open source images can be used, business often have there own private images.

Configure Marathon authentication for Docker Hub. 
https://mesosphere.github.io/marathon/docs/native-docker-private-registry.html

## Do a blue/green deployment
Deploy multiple versions of the same application
https://mesosphere.github.io/marathon/docs/blue-green-deploy.html

## Deploy using constraints
Deploy application only to host matching a given constraint
https://mesosphere.github.io/marathon/docs/constraints.html

## Act on events
Marathon emits events for everything that happens in. 
Think of how you could use that. For example to notify when a succesful deploy happened.
https://mesosphere.github.io/marathon/docs/event-bus.html
