# openwebui

This is a cost-effective, elegant AI interface for Chatgpt and other LLMs.


## Usage

I'm hosting this on a dirt-cheap VPS on [OVH](https://ovhcloud.com/). It's a
simple Ubuntu VPS with 1 vCPU and 2 GB RAM. Since it's not very beefy, I'm
mainly using it with an OpenAI token for ChatGPT.

## Pre-requisites

- I installed `nginx` and ran `certbot` for Lets Encrypt's certs
- docker (you may need to run some `docker swarm` initalization commands as well
- Some specific websocket headers are needed: see `chat_arunsrin.nginx.conf`

## Run

Copy the docker-swarm.yaml and execute like this:

```
sudo docker stack deploy -c docker-swarm.yaml -d chat_arunsrin
```
