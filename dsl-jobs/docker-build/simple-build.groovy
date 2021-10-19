def PROJECT_NAME = "simple-webserver"
def GIT_URL = "https://github.com/ecsdigital/devopsplayground-27-k8s-jenkins-pipeline.git"
def GIT_BRANCH = "master"

freeStyleJob(PROJECT_NAME) {
    scm {
        git {
            remote {
                url(GIT_URL)
            }
            branch(GIT_BRANCH)
        }
    }

    steps {
        shell('''
echo ciao
        ''')

        shell('''
echo ciao ciao
        ''')
    }
}


