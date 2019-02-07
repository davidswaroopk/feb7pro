# Azure-Tomcat-WAR-Deploy
Shows how to deploy a WAR file to Azure Web App and avoid the WAR file locking issue.

Update: July 18, 2018: On Windows: you can now deploy to directories other than ROOT. You need to use the /api/wardeploy?name=<app name> end point. For example: POST /api/wardeploy?name=abc1 will deploy to /wwwroot/webapps/abc1. https://github.com/projectkudu/kudu/wiki/Deploying-WAR-files-using-wardeploy

## Assumptions:
1. You have Java installed
2. You have Maven installed.
3. I use VS Code, but any text editor will do.

## Create Web App in Azure
1. Open Azure Portal

2. Create a Web App
   
3. Give it a name and create a App Service.  
   ![](https://raw.githubusercontent.com/AdamPaternostro/Azure-Tomcat-WAR-Deploy/master/images/step8.png)

4. Open the Web App

5. Set deployment credentials.
   ![](https://raw.githubusercontent.com/AdamPaternostro/Azure-Tomcat-WAR-Deploy/master/images/step9.png)
   - Set your username
   - Set your password

6. Set these settings.
   ![](https://raw.githubusercontent.com/AdamPaternostro/Azure-Tomcat-WAR-Deploy/master/images/step10.png)
   - Set Java Version to Java 8
   - Set Java minor version to Newest
   - Set Java web container to Tomcat 8.5... (whatever you like) 
   - Set Platform to 64-bit
   - Set ARR Affinity to Off





## Create and Clone Repo
1. I used Bitbucket for this demo.  You can use whatever Git repository you would like.

2. Create a repository "tomcatwebapp"

3. Using a prompt, clone to your hard disk: git clone https://adampaternostro@bitbucket.org/adampaternostro/tomcatwebapp.git

## Create Java App
![](https://raw.githubusercontent.com/AdamPaternostro/Azure-Tomcat-WAR-Deploy/master/images/step3.png)

1. CD to your folder: `cd cdtomcatwebapp`

2. Export Maven to your PATH if it is not already in your path: `export PATH=/Users/adampaternostro/apache-maven-3.5.3/bin:$PATH`

3. Generate Java/Maven project: `mvn archetype:generate -DarchetypeArtifactId=maven-archetype-webapp`
   - groupId: myGroupId
   - artifactId: myArtifactId
   - version: 1.0-SNAPSHOT
   - package: myPackage
   
4. Close your prompt.

## Code
1. Open in Visual Studio Code

2. Open your folder

3. Create deploy-local.sh in the src folder

4. Place the following inside the script
```
#!/bin/bash

echo "STEP 1 (Determine WAR file path)"
warFilePath="target/myArtifactId.war"
echo $warFilePath

echo "STEP 2 (Copy WAR file as ROOT.zip)"
cp $warFilePath ROOT.zip 

echo "STEP 3 (Set variables)"
username="adampaternostro"
password="<<REPLACE ME>>"
sitename="<<REPLACE ME>>"
warZipFile="ROOT.zip"

echo "STEP 4 (POST using cURL)"
curl -X POST -u $username:$password https://$sitename.scm.azurewebsites.net/api/wardeploy --data-binary @$warZipFile

echo "DONE"
```

5. Change the sitename and change the password you used when creating your Azure Web App.

6. Open the Integrated Terminal in VS Code (Under View | Integrated Terminal Menu)

7. In terminal: Change directories: `cd myArtifactId`

8. In terminal: Export your Maven Path: `export PATH=/Users/adampaternostro/apache-maven-3.5.3/bin:$PATH`

8. In terminal: Build: `mvn package`

9. In terminal: Set execute: `chmod +x ./src/deploy-local.sh`

10. In terminal: Run deploy: `./src/deploy-local.sh`

11. Open your Azure website and you should see "Hello World"

12. Create deploy-vsts.sh in the src folder

13. Place the following inside the script:
```
#!/bin/bash

echo "STEP 1 (Determine WAR file path)"
warFilePath="$AGENT_RELEASEDIRECTORY\_$BUILD_DEFINITIONNAME\drop\myArtifactId\target\myArtifactId.war"
echo $warFilePath

echo "STEP 2 (Copy WAR file as ROOT.zip)"
cp $warFilePath ROOT.zip 

echo "STEP 3 (Set variables)"
username="adampaternostro"
password="<<REPLACE ME>>"
sitename="<<REPLACE ME>>"
warZipFile="ROOT.zip"

echo "STEP 4 (POST using cURL)"
curl -X POST -u $username:$password https://$sitename.scm.azurewebsites.net/api/wardeploy --data-binary @$warZipFile

echo "DONE"
```

14. Change the sitename and change the password you used when creating your Azure Web App.

15. Check in your code.  Commit and then Push to Bitbucket.  (You can ignore the WAR and Root.zip files)

## Automated Build
1. Create a VSTS project (e.g. https://paternostromicrosoft.visualstudio.com/)

2. Create a new project called "tomcatwebapp".  It does not matter the source control since we are using an external one.
![](https://raw.githubusercontent.com/AdamPaternostro/Azure-Tomcat-WAR-Deploy/master/images/step11.png)

3. Click on Build and Release menu and select Builds

4. Click the "New Defination" button
![](https://raw.githubusercontent.com/AdamPaternostro/Azure-Tomcat-WAR-Deploy/master/images/step12.png)

5. Select Bitbucket Cloud.  You will need to authorize this.  You can use your username and password for the time being.  You should use an OAuth token for production.
![](https://raw.githubusercontent.com/AdamPaternostro/Azure-Tomcat-WAR-Deploy/master/images/step13.png)

6. Select your repository and master branch.  
   NOTE: If you do not see this then you might need to go back in and hit refresh.  The first time can be tricky.  You can also click on the Gear icon at the top of VSTS.  Then click on Services.  You can delete or reset your connection to Bitbucket here.  Then start back at step 3 (create a new build).
![](https://raw.githubusercontent.com/AdamPaternostro/Azure-Tomcat-WAR-Deploy/master/images/step14.png)
   
7. Search for Maven

8. Hover over Maven and click Apply

9. In the Agent Queue select "Hosted".  You might need to authorize your subscription.

10. Cilck on the Maven Task

11. Click the unlink button right after the title "Maven POM file" and change the pom.xml location to myArtifactId/pom.xml

11. Uncheck the JUnit test (optional)
![](https://raw.githubusercontent.com/AdamPaternostro/Azure-Tomcat-WAR-Deploy/master/images/step16.png)

12. Click on the Copy File To task.  Change the **/*.jar to **/*.war. 

13. Right click the Copy File task and select Clone

14.  Change **/*.war to **/*.sh

15.  Press Save and Queue (give it a name).  You can then click on the Build and view it.  An Item will appear near the top of the web page with the Build number.  It is a link.

16. Wait for the Build to complete.

## Automated Deployment
1. Click on Build and Release.  Select Releases.

2. Click the New Defination button

3. Click Empty Process

4. Name your Environment (e.g. Development)

5. Click on Add Artifact in the left hand side.  

6. Select your Build Defination you just created.  Click Add.

7. Click on the Task 0 inside the Development environment.

8. Click the + on Run on Agent

9. Type "bash" in the search box and select "Shell Script" (press Add)

10. Click on the script on the left hand side so you can set some properties.

11. Click the "..." next to script path and select deploy-vsts.sh.  $(System.DefaultWorkingDirectory)/_tomcatwebapp-Maven-CI/drop/myArtifactId/src/deploy-vsts.sh

12.  You can change the release defination name.  Click on the words "New Release Definition" and change.

13. Click Save

14. Click "+ Release" and create a release.

15. Click on the new Release item at the top of the page.  You can watch the release.

## Testing
1. Edit the index.jsp
2. Commit your changes.
3. Push to Bitbucket.
4. Run your Build process in VSTS.
5. Run your Release process in VSTS.
6. You should see your changed in your site.


## Notes
1.	Make sure the WAR has a web.xml file in the WEB-INF directory. 

2.	Make sure you still warm-up your web app (and use slots): https://docs.microsoft.com/en-us/azure/app-service/web-sites-staged-publishing#custom-warm-up-before-swap

3. See: https://github.com/projectkudu/kudu/wiki/Deploying-WAR-files-using-wardeploy 
   
