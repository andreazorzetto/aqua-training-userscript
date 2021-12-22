#!/bin/bash

## Parsing arguments for username and password
while getopts u:p:b: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        p) password=${OPTARG};;
        b) bootstrapversion=${OPTARG};;
    esac
done

##---------------- Software Requirements -----------------------##
apt update && apt install -y docker.io
snap install helm --classic # Install Helm


##---------------- SSH User -----------------------##
# Allow SSH password authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# Create user
useradd -m -s /bin/bash -p $(perl -e "print crypt('$password', "salt")") -G sudo $username

# Add user to docker group
usermod -a -G docker $username


##---------------- k3sup -----------------------##
curl -sLS https://get.k3sup.dev | sh
k3sup install --local --k3s-extra-args "--disable-cloud-controller --disable traefik --disable servicelb --docker -o /home/$username/.kube/config"
export KUBECONFIG=/root/kubeconfig

# Give user r/w permission to kubeconfig
chown $username: /home/$username/.kube/config

##---------------- kubectx and kubens -----------------------##
wget https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens -O /usr/local/bin/kubens
wget https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx -O /usr/local/bin/kubectx
chmod +x /usr/local/bin/kube*


##---------------- env vars, bashrc and aliases -----------------------##
cat <<END >>/home/$username/.bashrc
export KUBECONFIG=.kube/config
alias k=kubectl
alias kns=kubens
alias ktx=kubectx
alias h=helm
END


##---------------- Jenkins -----------------------##
helm repo add jenkins https://charts.jenkins.io

# Make sure the k3s cluster is ready
until kubectl get nodes; do sleep 1; done

# Install Jenkins
helm upgrade --install jenkins jenkins/jenkins --version 3.9.4 -n jenkins --create-namespace -f https://raw.githubusercontent.com/andreazorzetto/aqua-training-userscript/$bootstrapversion/jenkins_3.9.4_values.yaml --set controller.adminUser=$username,controller.adminPassword=$password
