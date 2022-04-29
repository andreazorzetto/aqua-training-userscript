#!/bin/bash

## default user creds
username=aquatapuser
password=aquatapuser
user_home="/home/$username"

## installation type
remote_resources=true

## jenkins
jenkins_helm_chart_version=3.12.0
local_jenkins_values_path="/vagrant_data/jenkins_${jenkins_helm_chart_version}_values.yaml"

## deployments
deployment_resources_path="$user_home/deployments"

## cloudcmd
cloudcmd_namespace="cloudcmd"
local_cloudcmd_path="/vagrant_data/cloudcmd.yaml"

##---------------- Software Requirements -----------------------##
show_help(){
echo "Userscript for tap instance bootrap.

Options available:
    -h              this help
    -u              [default: aquatapuser] username for ssh and jenkins 
    -p              [default: aquatapuser] user password
    -l              use local development helm and manifests
                    to be used together with the provided Vagrantfile
    -r              [default: true] user remote helm and manifests from the repo
                    options -l and -r can't be specified at the same time
    -j              specify a custom jenkins helm chart version; defaults to $jenkins_helm_chart_version

Examples:

## Standard boostrap with values from github repo with custom creds and Jenkins version##
./user-script.sh -u aquatapuser -p aquatapuser -j 3.12.0

## Local vagrant deployment with default creds ##
./user-script.sh -l"
}

## Parsing arguments for username and password
while getopts h?u:p:j:lr flag
do
    case "${flag}" in
        h|\?)
            show_help
            exit 0
            ;;
        u) 
            username=$OPTARG
            ;;
        p) 
            password=$OPTARG
            ;;
        l) 
            local_resources=true
            remote_resources=false
            ;;
        j)
            jenkins_helm_chart_version=$OPTARG
            ;;
    esac
done


##---------------- Software Requirements -----------------------##
software_requirements(){
    apt update && apt install -y docker.io
    snap install helm --classic # Install Helm
}

##---------------- SSH User -----------------------##
setup_ssh(){
    # Allow SSH password authentication
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    systemctl restart sshd
}

setup_user(){
    # Create user
    useradd -m -s /bin/bash -p $(perl -e "print crypt('$password', "salt")") -G sudo $username

    # Add user to docker group
    usermod -a -G docker $username
}

setup_k3s(){
    ##---------------- k3sup -----------------------##
    curl -sLS https://get.k3sup.dev | sh
    k3sup install --local --local-path=/root/kubeconfig --k3s-extra-args "--disable-cloud-controller --disable traefik --disable servicelb --docker -o /home/$username/.kube/config"
    export KUBECONFIG=/root/kubeconfig

    # Give user r/w permission to kubeconfig
    chown $username: -R /home/$username/.kube
}

install_utilities(){
    ##---------------- kubectx, kubens and k9s -----------------------##
    wget https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens -O /usr/local/bin/kubens
    wget https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx -O /usr/local/bin/kubectx
    chmod +x /usr/local/bin/kube*

    snap install k9s
    mkdir /home/$username/.k9s
    chown -R $username: /home/$username/.k9s
}

setup_userenv(){

##---------------- env vars, bashrc and aliases -----------------------##
cat <<END >>/home/$username/.bashrc
export KUBECONFIG=/home/$username/.kube/config
alias k=kubectl
alias kns=kubens
alias ktx=kubectx
alias h=helm
END
}

##---------------- Jenkins -----------------------##
deploy_jenkins(){
    export KUBECONFIG=/root/kubeconfig

    helm repo add jenkins https://charts.jenkins.io

    # Wait until k3s is ready
    until kubectl get nodes; do sleep 1; done

    # Install Jenkins
    if [ $remote_resources == true ]; then
        helm upgrade --install jenkins jenkins/jenkins --version $jenkins_helm_chart_version -n jenkins --create-namespace -f https://raw.githubusercontent.com/aqua-ps/aqua-training-userscript/master/jenkins_${jenkins_helm_chart_version}_values.yaml --set controller.adminUser=$username,controller.adminPassword=$password
    else
        helm upgrade --install jenkins jenkins/jenkins --version $jenkins_helm_chart_version -n jenkins --create-namespace -f $local_jenkins_values_path --set controller.adminUser=$username,controller.adminPassword=$password
    fi
}

deploy_cloudcmd(){
    export KUBECONFIG=/root/kubeconfig

    if [ $remote_resources == true ]; then
        wget https://raw.githubusercontent.com/aqua-ps/aqua-training-userscript/master/cloudcmd.yaml -O /tmp/cloudcmd.yaml
        
        sed -i "s/CCMDNAMESPACE/$cloudcmd_namespace/g"
        sed -i "s/DEPLOYMENTRESOURCES/$deployment_resources_path/g"

        kubectl apply -f /tmp/cloudcmd.yaml
    else
        cp $local_cloudcmd_path /tmp/cloudcmd.yaml

        sed -i "s@CCMDNAMESPACE@$cloudcmd_namespace@g" /tmp/cloudcmd.yaml
        sed -i "s@DEPLOYMENTRESOURCES@$deployment_resources_path@g" /tmp/cloudcmd.yaml
        sed -i "s@CMDUSER@$username@g" /tmp/cloudcmd.yaml
        sed -i "s@CMDPASSWD@$password@g" /tmp/cloudcmd.yaml
        sed -i "s@CMDROOT@$user_home@g" /tmp/cloudcmd.yaml
        
        # need to mount cm and test
        kubectl apply -f /tmp/cloudcmd.yaml
    fi

    # rm /tmp/cloudcmd.yaml
}

download_deployment_resources(){
    cd $user_home
    rm -Rf deployments
    git clone https://github.com/aquasecurity/deployments.git
    chown $username: -R $deployment_resources_path
}


software_requirements
setup_ssh
setup_user
setup_k3s
install_utilities
setup_userenv
deploy_jenkins
deploy_cloudcmd
download_deployment_resources