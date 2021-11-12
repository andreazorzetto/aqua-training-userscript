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