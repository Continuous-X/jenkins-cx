# Developer Tips
## local build with maven
Please use the maven wrapper:
### update dependencies
``./mvnw versions:update-parent versions:display-plugin-updates versions:display-dependency-updates -s .mvn/settings.xml``
### local build
``./mvnw clean install -s .mvn/settings.xml -Pspotbugs-exclusion-file``
