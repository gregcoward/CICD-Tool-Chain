# Updated f5-rs-container

 I updated the f5-rs-ontainer from Yossi R. to also deploy AutoScale WAF to Azure. This includes an "ecommerce" application called OpenCart. This version also includes the use of a git-server, that can also be found on my docker hub repo, ([tstanley933/tstanley-git-server](https://hub.docker.com/r/tstanley933/tstanley-git-server/)).  Together these two containers are designed to demostrate F5's true CI/CD tool-chain integration, and capabilites.

__<span style="color:blue">NOTE:</span>__

I recommend that you run both containers, and show how this works from the developers perspective.  You will then be able to easily answer questions from the DevOps folks this way, on how it is actually implemented, once you have set the context.  This means to actually check out the appConfig.json file from the git container, make a change, save the change and then commit the change.  This fires off the Jenkins jobs, and does a full deployment of the application and autoscale WAF.  When completed you will be able to connect to the application through the WAF, as well as demostarte its ability to block right out of the box.

## Configuring the Container for your environment

### Deploy the container

The first thing is to pull the container, and stand it up.  Yossi R. has a great [document](https://gitswarm.f5net.com/f5-reference-solutions/f5-rs-docs) on GitSwarm that will help you to get this up and running and configured for AWS.  This document will focus on what needs to be done differently to get the Azure side configured so you can show deployments to Azure and/or a multi-cloud use case.

As previously said we are going to deviate a little, because of the git-server portion of the deployment.  Per his instructions, pull and run the container via the docker run command:

    docker run -p 2222:22 -p 10000:8080 -it tstanley933/tstanley-git-server:latest

This will download the container not from gitswarm, but from my docker repo.  I am choosing this option until Yossi has time to implement my changes to the f5-rs-container that he manages. Once the container is running, you will automatically be logged into the container, and at the prompt.

Following Yossi's doc change to the jenkins user:

    su root -c "su jenkins"

Follow the next few steps in Yossi's doc as well:

    aws configure
    echo F5snopssupersecurepassword! > ~/.vault_pass.txt
    ansible-vault edit --vault-password-file ~/.vault_pass.txt/home/snops/f5-rs-global-vars-vault.yaml
    ansible-playbook --vault-password-file ~/.vault_pass.txt /home/snops/f5-rs-jenkins/playbooks/jenkins_config.yaml

For the next step, we will need to import the private and public keys that we used in the git container setup.  Remember that for the git container we uploaded just the public key into the keys directory.  Now we will make sure that all the keys are the same, and place both keys in the following directory (You can use something like filezilla to copy the keys):

    /var/jenkins_home/

Now change the permissions on the private key with the following command:

    chmod 400 /var/jenkins_home/id_rsa

Again this will be the key that both allows you access to the git-server, and will be used to login to various deployed BIG-IP's.

### A list of changes that must be made

Now that the two containers are up and running, the below items must be changed in your Jenkins environment in order for this to work;

* Service Principle

  * You will need to create a Sevice Principal in Azure to allow the scripts to login to your account automatically.  Follow the below link for instructions for doing so.  You can use the "az" commands from the f5-rs-container to create the Service Principal.
  * [https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest)
  * Make sure to collect the following information when complete.
    * Tenant ID
    * Service Principle ID
    * Service Principle Secret

* git repo ssh private key
  * This is the same private key that you imported above.  This will be used to synch Jenkins jobs with the git repository, to allow it to pickup the changes.

* git repo container IP address updated in the Azure Jenkins jobs.
  * You will need to record the git-server container IP address.
    * If this is a local docker instance, you can run the following:

            docker container inspect containerID

    * If however this is running in Azure ACI, you will need to grab the Public IP address from Azure.
* clone the git-server repo to your local file system
* update the post-recieve hook script with the correct Jenkins container IP address
  * You will need to edit the post-receive hook script in the .git directory of where you cloned the github repo to on your local machine.  This must be the IP address of the Jenkins server.

Once these are updated, you should be able to commit a change to the appConfig.json file in the newly cloned git-server repo, and the demo should start.

### Edit jobs in Jenkins

There are some changes you will need to make to the Jenkins configuration.

* First, using the SP information you gathered from above you will need to enter into the Jenkins credentials manager your Azure Service Principal information.

  * Login to Jenkins
  * In the left hand pane, click on credentials
  * Under "Stores scoped to Jenkins", click the "global" link.
  * On the left hand side click "Add Credentials".
  * In the "Kind" drop down, select "Username with Password"
  * In "Username" paste in the "Service Principal Id"
  * In "Password" paste in the "Service Principal Secret/Password"
  * Select an ID # for this.
  * Give it a short description like Azure Login.
  * Click "OK"

* Next, add the tenant ID as a Secret Text

  * On the left hand side click "Add Credentials".
  * In the "Kind" drop down, select "Secret Text"
  * In "Secret" paste in the "Tenant Id"
  * Select a different ID # for this.
  * Give it a short description like Azure Tenant Id.
  * Click "OK"

* Now, add the git ssh private key

  * On the left hand side click "Add Credentials".
  * In the "Kind" drop down, select "SSH Username with Private Key"
  * In "Username" type in "git"
  * In Private Key, select "Enter directly"
  * Paste in the contents of the private key
  * Leave "Passphrase" empty.
  * Select a different ID # for this.
  * Give it a short description like git key.
  * Click "OK"

* Next we'll edit the git location and credentials in the Azure jobs.

  * Click on Jenkins in the top left of the screen to take you back to the list of jobs.
  * Click on the "Azure WAF with OMS" job.
  * For each of the jobs, do the following:
    * Click on the job name
    * On the left hand side click on "Configure"
    * In the "Source Code Management" section correct the Reposity URL to reflect the proper IP address, and repo path to the CICD-Tool-Chain repo.  Mine looks like this:

            ssh://git@52.160.111.186/git-server/repos/CICD-Tool-Chain

    * Then in the Credentals drop down, slect the "git key" and press the tab key.
      * Pressing the tab key should cause Jenkins to try and connect.  It should NOT give you an error.  If it does, make sure you reslove this error before moving on.
    * Now click "Save" in the bottom left to save your changes.
    * Scroll down to Bindings.
      * Make sure you have two bindings called:
        * Username and password (separated)
        * Secret Text
      * If not, you need to create them
        * Click on "add" in the Bindings section, and select "Username and password (separated).
        * Create a Username Variable call "My_User" and a Password Varibale called "My_Pass"
        * Click on "Specific Credentials" and from the drop down box select your Azure Login credentials, the onese with Username and Password.
        * Click on "add" in the bindings section again, and this time select Secret Text
        * Name the variable "My_Tenant", and slect the Azure Tenant ID from the Credentials drop down.
        * Click Save in the bottom left hand corner.
  * Do this for each of the jobs.
* Next we will create the post-recieve hook script and make it reflect the correct IP address of the Jenkins container.
  * In the folder that you cloned the CICD-Tool-Chain repo into, navigate to the ".git/hooks" folder.
  * Create a file called post-recieve
  * copy the contents of the "post-commit.sh" file found in the root of the repo, into this new file.
  * replace the IP address/FQDN of the Jenkins server with your IP address/FQDN.
  * Next you will need to replace the token value, (found at the end of the cURL string), with a secret value of your own.
  * Save this file and commit to the git repo remote origin
  * Log back into Jenkins
  * From the main list of jobs, click on the "Azure WAF with OMS" job
  * Click on the "azure-create_rg_vnet job
  * In the left pane, click on "configure"
  * Scroll down to "Build Triggers", and repalce the "Authentication Token" string with your own secure string that you used in the above steps of the cURL command in the post-recieve hook script.
  * Click "Save"

Finally, you should now be able to clone the toolchain.git repo to your laptop. This makes sure that the remote origin is set for the git-server container, and that when a change is commited, it will fire the post-recieve hook script.  Once cloned, open and edit the appConfig.json file and then save and commit the changes.  The post-recieve hook will fire at the Jenkins REST endpoint for the Azure WAF with OMS job, triggering the build of the application and autoscaled WAF.