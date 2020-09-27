# Developer Tips
## local build with maven
Please use the maven wrapper:
### update dependencies
``./mvnw versions:update-parent -s .mvn/settings.xml``
``./mvnw versions:display-plugin-updates -s .mvn/settings.xml``
``./mvnw versions:display-dependency-updates -s .mvn/settings.xml``
### local build
``./mvnw clean install -s .mvn/settings.xml -Pspotbugs-exclusion-file``
