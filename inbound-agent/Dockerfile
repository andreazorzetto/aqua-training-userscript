FROM jenkins/inbound-agent:4.11.2-4

USER root
RUN apt update && apt install -y docker.io

USER jenkins

## Built and pushed to andreazorzetto/jenkins-inbound-agent:4.11.2-4-docker