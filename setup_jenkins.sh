#!/bin/bash

# Install required Jenkins plugins
jenkins-plugin-cli --plugins \
    workflow-aggregator \
    git \
    docker-workflow \
    pipeline-stage-view \
    blueocean

# Create Jenkins credentials for Git
cat << EOF > create_credentials.groovy
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*

def jenkins = Jenkins.getInstance()
def domain = Domain.global()
def store = jenkins.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

def credentials = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "git-credentials",
    "Git Credentials",
    "your-username",
    "your-password"
)

store.addCredentials(domain, credentials)
EOF

# Create Jenkins pipeline job
cat << EOF > create_pipeline.groovy
import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.GitSCM
import hudson.plugins.git.BranchSpec

def jenkins = Jenkins.getInstance()
def job = jenkins.createProject(WorkflowJob, "Calculator-Pipeline")

def gitScm = new GitSCM(
    "https://github.com/yourusername/calculator-app.git"
)
gitScm.branches = [new BranchSpec("*/main")]

def flowDefinition = new CpsScmFlowDefinition(gitScm, "Jenkinsfile")
job.setDefinition(flowDefinition)

jenkins.save()
EOF

echo "Jenkins setup scripts created. Please run them in Jenkins script console after initial setup." 