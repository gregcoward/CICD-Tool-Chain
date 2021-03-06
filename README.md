# CICD-Tool-Chain

[![Releases](https://img.shields.io/github/release/tstanley93/CICD-Tool-Chain.svg)](https://github.com/tstanley93/CICD-Tool-Chain/releases)
[![Commits](https://img.shields.io/github/commits-since/tstanley93/CICD-Tool-Chain/v1.0.svg)](https://github.com/tstanley93/CICD-Tool-Chain/commits)
[![Issues](https://img.shields.io/github/issues/tstanley93/CICD-Tool-Chain.svg)](https://github.com/tstanley93/CICD-Tool-Chain/issues)
[![TMOS Version](https://img.shields.io/badge/tmos--version-13.0.2-ff0000.svg)](https://github.com/tstanley93/CICD-Tool-Chain)

## Project Summary

This project is to help illustrate how F5 BIG-IP VE, and F5 BIG-IP PerApp VE, can be deployed and fully configured for use in a DevOps CI/CD Toolchain.  This project conisists of 2 containers, one is a git repo server, the second is a container containing Jenkins and the Azure, and AWS CLI's, as well as several other tools to make this project work.

## Create the new git-server

I recommend that you deploy this in the order I have it in the documentation.  git-server first, and then the jenkins container.

You can find the tstanley-git-server container on Docker Hub [here](https://hub.docker.com/r/tstanley933/tstanley-git-server/).  You will find configuration documentation [here](tstanley933-git-server.readme.md) on how to setup and use the git-server container.

## Create the Jenkins server

You can find the f5-rs-container on Docker Hub as well [here](https://hub.docker.com/r/tstanley933/f5-rs-container/).  You will also find the documentation to setup and use this container [here](f5-rs-container-readme.md) as well.

## Internal Documentation for the Super-NetOps container

Follow the instruction on GitSwarm here to standup the [f5-rs-container](https://gitswarm.f5net.com/f5-reference-solutions/f5-rs-docs) container.

## How to Run the Demo

Once you have both containers up and running.  Do a git clone of the git-server repository to your machine.  This will make sure that you are working from a version that is connected to the git-server container.  Edit appConfig.json file as you see fit, and then save it.  Next use git to commit your changes back to the reposity.

Commiting the changes will fire the post-recieve hook script, and kick off the job in Jenkins via a REST call to build out the application (OpenCart) as well the AutoScale F5 WAF.

Go forth and automate!