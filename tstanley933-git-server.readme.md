# git-server Container

* I rebuilt this container to add cURL so I could hit the REST end point of Jenkins
* You can clone the CICD-Tool-Chain repo into this git-server from git-hub using this link:

    git clone https://github.com/tstanley93/CICD-Tool-Chain.git /git-server-directory

## Configuration

### Pre-requisites

You will need the following:

* An Azure Subscription
* Prefereablly an AWS Subscription as well (to run the multi-cloud scenarios).

### To run entirely in Azure

If you don't have Docker running somwhere on your laptop or desktop, you can run this from Azure's Azure Container Instances.  Follow [this](https://azure.microsoft.com/en-us/blog/announcing-azure-container-instances/) link for more information on ACI.

In the above linked github repo, you can find two ARM templates that will help you install the two containers used for this demo into Azure's ACI.  In this document we will run the aci_toolchain_git.json, to deploy the git server for the demo, and then configure it.

As with most things there is an order that works best, and this is no exception.  I recommend you deploy this git server container first, and then the Jenkins container.  The way I have written the documentation will work better if you do it that way.

#### Order of Operations

* Create an Azure [Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-create-storage-account#manage-your-storage-account) to house the repo and keys directories.
* Create two [File Shares](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-portal) in this storage account
  * One called keys
  * One called repos

* Grab the connection informaton for the two shares, you will need this for the template.
* [Create](key_create.md) a public/private key
* Copy the publick key to the keys share
* Clone the CICD-Tool-Chain repo into the repos share
* Update the ARM template with the above information
* Deploy the ARM template
* Verify connectivity and configuration

#### Configuration Steps

You can use either the Azure Portal or the Azure CLI 2.0 to deploy the template.  To deploy via the Azure CLI 2.0 use the following command:

    az deploymnet create -g resource-group-name -n deployment-name --template-file aci_toolchain_git.json

To use the Azure Portal please follow [this](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-portal#deploy-resources-from-custom-template) doc.

Once the deployment has finished, you'll need to record the public IP address. With the public IP address in hand you can now run the following ssh command to verify all is good to go:

    ssh git@public-ip-address
    ...
    Welcome to git-server-docker!
    You've successfully authenticated, but I do not
    provide interactive shell access.
    ...

If you recieve something other than this, you will need to review the below information and fix any errors.

### To run localy in Docker

How to run the container in port 2222 with two volumes: keys volume for public keys and repos volume for git repositories:

    docker run -d -p 8022:22 -v c:/git-server/keys:/git-server/keys -v c:/git-server/repos:/git-server/repos tstanley933/tstanley-git-serverr

How to use a public key:

    Copy them to keys folder:
    - From host: $ copy ~/.ssh/id_rsa.pub c:\git-server\keys
    You need to restart the container when keys are updated:
    docker restart <container-id>

How to check that container works (you must to have a key):

    ssh git@<ip-docker-server> -p 2222
    ...
    Welcome to git-server-docker!
    You've successfully authenticated, but I do not
    provide interactive shell access.
    ...

How to create a new repo:

    cd myrepo
    git init --shared=true
    git add .
    git commit -m "my first commit"
    cd ..
    git clone --bare myrepo myrepo.git

How to upload a repo:

    From host:
    copy myrepo.git c:\git-server\repos

How to clone a repository:

    git clone ssh://git@<ip-docker-server>:2222/git-server/repos/myrepo.git

### Arguments

* **Expose ports**: 22
* **Volumes**:
  * */git-server/keys*: Volume to store the users public keys
  * */git-server/repos*: Volume to store the repositories

### SSH Keys

How generate a pair keys in client machine:

    ssh-keygen -t rsa

### Build Image

How to make the image:

    docker build -t git-server-docker .

### Docker-Compose

You can edit docker-compose.yml and run this container with docker-compose:

    docker-compose up -d
