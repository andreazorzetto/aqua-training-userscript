# How to get creds to Jenkins
```
docker login
docker login registry.aquasec.com
```

## Example json Object
Run the following command in your instance:

```
docker login registry.aquasec.com
```

This command will write a json file with credentials `/root/.docker/config.json`:
```
$ docker login registry.aquasec.com
Username: andrea.zorzetto@aquasec.com
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

The config.json file will look like this, and you can use the following command to create a kubernetes secret with it:
```
{
    "auths": {
        "registry.hub.docker.com": {
            "auth": "chbadlrbgasldJHVBLAIDFBVh8ah =="
        },
        "registry.aquasec.com": {
            "auth": "kGVTFKDVlyvCvyDLycvLYUlcLYbLuyuy=="
        }
    }
}

kubectl create secret generic dockercred --from-file=.dockerconfigjson=/root/.docker/config.json -n jenkins
```

# Install the Jenkins Aqua Plugin

Manage Jenkins > Manage Plugins > Available (aqua security scanner)

Manage Jenkins > Configure System > Aqua Security

```
Version: 3.x
Image: registry.aquasec.com/scanner:6.2
Aqua URL: https://uybasiybksjdfbvujbsdvkubsdvkub.us-east-2.elb.amazonaws.com:8080
User: administrator
Password: password
```

# Boostrap script
The user-script.sh provided will prepare the instance for the Aqua Training environment. The script can be called independently from the IaC or used to provision a local Vagrant develoment machine with the provided Vagrantfile

The script accepts the following arguments:
* `-h` | this help
* `-u` | [default: aquatapuser] username for ssh and jenkins 
* `-p` | [default: aquatapuser] user password
* `-l` | use local development helm and manifests to be used together with the provided Vagrantfile
* `-r` | [default: true] user remote helm and manifests from the repo options -l and -r can't be specified at the same time
* `-j` | [optional] specify a custom jenkins helm chart version;

Examples:

Standard boostrap with values from github repo with custom creds
```
./user-script.sh -u aquatapuser -p aquatapuser
```

Local vagrant deployment with default creds
```
./user-script.sh -l
```
# Test with Vagrant
Test the user script used as the ec2 instance bootstrap in Vagrant

Create Vagrant machine
```
vagrant up
```

SSH into the Vagrant machine
```
vagrant ssh
```

Clean up
```
vagrant halt
vagrant destroy
```

Credentials are by default set to be test/test
