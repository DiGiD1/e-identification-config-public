#!/bin/bash
docker build --no-cache -f Dockerfile -t e-identification-docker-virtual.vrk-artifactory-01.eden.csc.fi/e-identification-tomcat-apache2-shibd-sp-base-image .
docker push e-identification-docker-virtual.vrk-artifactory-01.eden.csc.fi/e-identification-tomcat-apache2-shibd-sp-base-image
