# If you've built something cool during the workshop make a PR and a link to the repo.

- https://github.com/lucasvanlierop/containerization-workshop

- https://github.com/mhausenblas/m-shop (more info at: https://mesosphere.com/blog/2015/06/21/web-application-analytics-using-docker-and-marathon/)
- 

----
Docker 1.12 exploration:

clone https://github.com/carnage/vagrant-docker-cluster
edit hosts to give the number of hosts you want
run vagrant up
wait 

vagrant ssh host1
sudo docker swarm init --listen-addr host1:2377
exit

vagrant ssh host2
sudo docker swarm join host1:2377

you now have a working swarm.
Follow this guide to get used to working with a swarm https://docs.docker.com/engine/swarm/swarm-tutorial/deploy-service/

Logging:
vagrant ssh host1
sudo docker network create -d overlay logging
sudo docker service create -p 8000:80 --network logging --mode global --name logging --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,writable=true gliderlabs/logspout

curl http://localhost:8000/logs 
open a new terminal
vagrant ssh host1
sudo docker run --rm alpine /bin/echo 'hi'

Service discovery:
sudo docker service create --network logging --name observer --mode global alpine /bin/sleep 3000000000
sudo docker ps
copy container name for alpine container
sudo docker exec -ti <container name> /bin/sh
nslookup logging
