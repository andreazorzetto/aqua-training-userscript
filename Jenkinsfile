pipeline {
  agent {
    kubernetes {
      label 'example-kaniko-volumes'
      yaml """
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: docker-client
    image: docker:19.03.1
    command: ['sleep', '99d']
    env:
      - name: DOCKER_HOST
        value: tcp://localhost:2375
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /root/.docker
  - name: docker-daemon
    image: docker:19.03.1-dind
    env:
      - name: DOCKER_TLS_CERTDIR
        value: ""
    securityContext:
      privileged: true
    volumeMounts:
      - name: cache
        mountPath: /var/lib/docker
      - name: jenkins-docker-cfg
        mountPath: /root/.docker
  - name: jnlp
    workingDir: /home/jenkins
  - name: kaniko
    workingDir: /home/jenkins
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  volumes:
  - name: cache
    hostPath:
      path: /tmp
      type: Directory
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: dockercred
          items:
            - key: .dockerconfigjson
              path: config.json
"""
    }
  }
  stages {
    stage('Build with Kaniko') {
      environment {
        PATH = "/busybox:/kaniko:$PATH"
      }
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          writeFile file: "Dockerfile", text: """
            FROM openliberty/open-liberty:21.0.0.5-kernel-slim-java11-openj9-ubi
            MAINTAINER Aqua 
            RUN mkdir /tmp/success
          """
            
          sh '''#!/busybox/sh
            /kaniko/executor --context `pwd` --verbosity debug --destination morgantatkins/open-liberty:21.0.0.5-kernel-slim-java11-openj9-ubi
          '''
        }
      }
    }
    stage('Scan alpine image'){
        steps {
            container(name: 'docker-client', shell: 'sh') {
                // aqua locationType: 'hosted', registry: 'Docker Hub', policies: 'Default', register: 'false', hostedImage: 'openliberty/open-liberty:21.0.0.5-kernel-slim-java11-openj9-ubi',  notCompliesCmd: '', onDisallowed: 'ignore', hideBase: false, showNegligible: false
                aqua locationType: 'hosted', policies: '', hostedImage: 'openliberty/open-liberty:21.0.0.5-kernel-slim-java11-openj9-ubi', customFlags: '', registry: 'Docker Hub', localImage: 'morgantatkins/jenkins2:agent', hideBase: false, notCompliesCmd: '', onDisallowed: 'ignore', showNegligible: false, register: 'false'
            }
        }
    }
  }
}