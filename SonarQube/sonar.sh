#!/usr/bin/env bash
exec /opt/java/openjdk/bin/java -jar lib/sonar-application-"${SONAR_VERSION}".jar -Dsonar.log.console=true "$@"
