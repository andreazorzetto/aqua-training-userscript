# How to get creds to Jenkins
```
docker login
docker login registry.aquasec.com
```

## Example json Object

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

kubectl create secret generic dockercred --from-file=.dockerconfigjson=$HOME/.docker/config.json -n jenkins
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