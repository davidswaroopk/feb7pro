#!/bin/bash

# Pushes out the WAR file to Azure Web App and avoids the locking issue when 
# more than one server is running.  The servers can have a race condition where
# they all try to lock the WAR file to unzip it for Tomcat.
# See the file: War-File-Deploy-Readme.txt

# [AGENT_RELEASEDIRECTORY] --> [D:\a\r1\a]
# [BUILD_DEFINITIONNAME] --> [AzureTomcatDemo-Maven-CI]
# WAR file: D:\a\r1\a\_AzureTomcatDemo-Maven-CI\drop\myArtifactId\target\myArtifactId.war

echo "STEP 1 (Determine WAR file path)"
warFilePath="$AGENT_RELEASEDIRECTORY\_$BUILD_DEFINITIONNAME\drop\myArtifactId\target\myArtifactId.war"
echo $warFilePath

echo "STEP 2 (Copy WAR file as ROOT.zip)"
cp $warFilePath ROOT.zip 

echo "STEP 3 (Set variables)"
username="<<removed>>"
password="<<removed>>"
sitename="<<removed>>"
warZipFile="ROOT.zip"

echo "STEP 4 (POST using cURL)"
curl -X POST -u $username:$password https://$sitename.scm.azurewebsites.net/api/wardeploy --data-binary @$warZipFile

echo "DONE"
