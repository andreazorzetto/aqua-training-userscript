def PROJECT_NAME = "test_job"
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
#Build image
echo "Building image."
        ''')

        shell('''
#Push to registry
echo "Push the image to registry without vulnerability scan. Love living on the edge"
        ''')

        shell('''
#Run the workload
echo "Run the workload. Security... is not my problem"
        ''')
    }
}


