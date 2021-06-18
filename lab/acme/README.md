
# Domino V12 CertMgr Lab Environment on Docker

## Introduction

Domino V12 introduces a new way to deploy certificates domain wide leveraging a new server task CertMgr and new domain wide replica `certstore.nsf`.

The manual certificate flow works with any type of CA by automating 

- Creating private key encrypted and securely stored in `cerstore.nsf`
- Creating a CSR
- Exporting (COPY) the CSR
- Importing the certificate, intermediate certs and trusted root (PASTE) into the `certstore.nsf`

Another key functionality is automatic certificate management leveraging Let's Encrypt and other ACME based Certificate Authorities (CA).

Testing this functionality can be challenging in lab environments without any external connection.

This Docker based setup leverages the Let's Encrypt Pebble project to allow internal testing without any inbound internet connection.  
You only need to be able to pull down the Docker images from Docker Hub.

## Components

- `docker-compose.yml`
- `pebble-config.json`
- `lab-certstore.dxl`

The components come pre-configured. However the imported `cerstore.nsf` configuration needs to be reviewed and update the address of your Pebble ACME server and your test domain.  
There are no changes needed inside the files for the default configuration with a  Local [Docker Desktop] (https://www.docker.com/products/docker-desktop) environment.

## Requirements

- Docker Desktop
- Linux: Docker 19.x or higher, Docker Compose

## Option A - Use Docker Desktop on Windows or Mac

Docker Desktop is an easy to use environment which has [docker-compose] (https://docs.docker.com/compose/) already pre-installed and integrated.  
If you have a Domino server running on your local Windows machine, Docker Desktop is a very good and straightforward environment to use.  
The next section describe the setup for a Docker server running on Linux for example in a local VM. Both environments have their use cases.  

## Option B - Prepare a local Linux Docker Environment (advanced configuration)

### Install Docker 20.10 or higher

This command takes a time and installs the current Docker version with all dependencies.  
Don't PANIC! No output is generated for a while and it takes time!


```
curl -fsSL https://get.docker.com | bash
```

### Enable and start Docker

```
systemctl enable --now docker
```

### Check Docker Version and installation

- Check version
- Run the hello-world image in your first container

```
docker version

docker run hello-world
```


### Install Docker-Compose

The following step installs Docker Compose.  
There might be a newer version available. This command installs version 1.29.1.

```
curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
```

## Step by step instructions for lab environment

Now that you installed Docker perform the following steps.

### Switch into the directory containing the docker-compose.yml

When using Docker Compose the working directory defines the prefix for all Docker containers created.  
Switch to the directory as a starting point. The directory also contains the JSON file mounted into the Pebble container.

```
cd /local/github/domino-docker/lab/acme
```

### Starting the Lab environment

You can either start the lab environment in background by adding the `-d` switch.  
Or you can run the environment in foreground to see all the log messages.  
This is the preferred way for a first test but you have to restart when you close the command with `CTRL-C`.

```
docker-compose up
```

This command brings up the lab environment.  
The first time it is started it will pull down the images.  
So you have to be able to access the internet to get those images.  

To stop the environment just use `CTRL-C` to stop the containers.

To remove the existing containers -- e.g. in case of a configuration change use

```
docker-compose down
```


## Working with the Lab environment

The project uses a Let's Encrypt Pebble test server.

This setup provides a lab working with `HTTP-01` and `DNS-01` challenges to leverage a DNS-TXT API approach confirming challenges to the management port of the challenge test server.

### Import DNS provider configuration and accounts

This lab setup contains a DXL file, which includes the DNS TXT API integration for the Pebble challenge server and also two accounts for your to customize to your environment.

Just import the DXL files and adopt them to your configuration.

Set the IP address of your Docker host and keep the existing port numbers, which are defined in your Docker lab environment.  
In case your Docker host can be resolved by your Domino server with a DNS name, you can add the hostname.

The default configuration uses the loopback IP address `127.0.0.1` predefined for a local Docker Desktop environment. In case your Docker containers run on a Linux VM, change the IP address matching your Docker host IP address.  
The ports included in the predefined configuration already match the lab environment setup.

### Get Root CA and import it as Trusted Root

You find the Root CA certificates Pebble re-creates at every start accessing the management interface.

- Copy the PEM based certificate
- Create a new Trusted Root document in CerStore
- Paste the certificate
- Submit the request

You can either download it via browser or if you have curl installed you can use the following commands which are also showing the download URLs.

```
curl -k https://127.0.0.1:15000/roots/0
```

### Work with your new configuration 

Now that you have setup all the configuration, you can start using the imported configurations either with `HTTP-01` or `DNS-01` challenges.  
Out of the box the registered domain configured is `pebble.lab`. This domain name triggers the DNS-01 challenges and can be changed as needed.  
The pebble test configuration takes care the requests are send to the local challenge test server to mock up the operations a DNS-01 challenge provider would perfom.


### Customization / Options

This lab setup can reach the Domino server via DNS if configured.  
In case your Domino server is not resolvable via DNS you can specify the IP address of your Domino server in an environment variable.  
The Pebble Challenge test server will `mock` DNS requests for `HTTPS-01` pointing all DNS requests to your Domino server.  

To configure the Pebble challenge test server to point `HTTP-01` requests to your Domino server, export the following variable before you start your Docker Pebble lab containers.  
Replace the IP with the IP your Docker environment can reach your Domino server on HTTP (port 80).

Linux/Mac:

```
export DOMINO_IP=192.168.1.12
```

Windows

```
set DOMINO_IP=192.168.1.12
```

## Additional customization

This is a standard simple to use environment. In case you have special connectivity requirements, you can change the IP addresses accordingly. If you running in a Docker desktop environment accessing a locally installed Domino server, you should not need to touch any of the IP address configuration and can use the loopback IP address `127.0.0.1`.  

There are many additional options and you can also use the Pebble Challenge Test server to change the behavior. Like fail challenges or changing DNS replies etc. This is beyond the scope we can cover in an easy to use environment.  

Check the Challenge Test Server documentation linked below for details.

## References

https://github.com/letsencrypt/pebble

https://github.com/letsencrypt/pebble/blob/master/cmd/pebble-challtestsrv/README.md

https://letsencrypt.org/docs/

https://help.hcltechsw.com/domino/12.0.0/admin/wn_automating_cert_management.html

