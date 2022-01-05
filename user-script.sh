#!/bin/bash

while getopts u:p: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        p) password=${OPTARG};;
    esac
done

##---------------- SSH User -----------------------##
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
useradd -m -p $(perl -e "print crypt('$password', "salt")") -G sudo $username


##---------------- Requirements -----------------------##
curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs build-essential docker.io


##---------------- Wetty -----------------------##
npm install -g yarn
yarn global add wetty

cat <<END > /etc/systemd/system/wetty.service
[Unit]
Description=Wetty terminal on Web
After=network.target

[Service]
Type=simple
User=$username
WorkingDirectory=/home/$username/
ExecStart=/usr/local/bin/wetty -p 8080 --sshuser $username
Restart=always

[Install]
WantedBy=multi-user.target
END

systemctl enable wetty.service
systemctl start wetty.service


##---------------- k3sup -----------------------##
curl -sLS https://get.k3sup.dev | sh
mkdir /root/.kube
k3sup install --local --local-path /root/.kube/config --k3s-extra-args '--disable-cloud-controller --disable traefik --disable servicelb --docker'


##---------------- env vars, bashrc and aliases -----------------------##
export KUBECONFIG=/root/.kube/config
export HOME=/root

cat <<END >>/root/.bashrc
export KUBECONFIG=/root/.kube/config
alias k=kubectl
alias kns=kubens
alias ktx=kubectx
alias h=helm
END


##---------------- kubectx and kubens -----------------------##
wget https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens -O /usr/local/bin/kubens
wget https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx -O /usr/local/bin/kubectx
chmod +x /usr/local/bin/kube*


##---------------- Helm -----------------------##
snap install helm --classic


##---------------- Jenkins -----------------------##
helm repo add jenkins https://charts.jenkins.io
until kubectl get nodes; do sleep 1; done #Wait for the cluster to be ready
##TO DO: rename branch
helm upgrade --install jenkins jenkins/jenkins --version 3.8.3 -n jenkins --create-namespace -f https://raw.githubusercontent.com/andreazorzetto/aqua-training-userscript/0.2/jenkins_3.8.3_values.yaml --set controller.adminUser=$username,controller.adminPassword=$password
