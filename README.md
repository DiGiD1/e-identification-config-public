Suomi.fi-tunnistaminen asennusohjeet
===================

Tämän ohjeen avulla saat käännettyä Suomi.fi-tunnistaminen lähdekoodit ja käynnistettyä lokaalin testiympäristön omalle koneelle.

### Ympäristö

Asennusohjeet on tehty juuri asennetun Ubuntu 16.04 LTS -käyttöjärjestelmän pohjalta. Aloitetaan asentamalla tarvittavat käännöstyökalut ja ajoympäristö.

```
sudo apt-get update # pakettilistausten päivitys
sudo apt-get -y dist-upgrade # pakettien päivitys

sudo add-apt-repository ppa:webupd8team/java # Oracle JDK
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D # docker
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list # docker
sudo apt-get update
 
sudo apt-get -y install docker-engine # docker
sudo usermod -aG docker $USER # docker
 
sudo apt-get -y install oracle-java8-installer oracle-java8-unlimited-jce-policy # oracle jdk
sudo apt-get -y install maven git ansible curl

curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
 
sudo apt-get -y install nodejs gem ruby-sass ruby-compass # e-identification-static-ui 
sudo ln -s /usr/bin/nodejs /usr/bin/node # e-identification-static-ui
```
Suositeltavaa on tehdä uudelleenkäynnistys (sudo reboot) tässä välissä, jotta päivitetyt paketit ja käyttöoikeudet tulevat varmasti voimaan.

Lisää /etc/hosts -tiedostoon seuraavat rivit:
```
192.168.0.1     tunnistaminen.test
192.168.0.2     kortti.tunnistaminen.test
192.168.0.3     testipalvelu.test
```
Luo hakemisto (mkdir ~/kapa) ja lisää uuteen tiedostoon ~/kapa/deploy-local.properties seuraavat rivit:
```
deploy_dir=~/build/deploy
log_dir=~/build/deploy/logs
```
Luo haluamasi hakemisto lähdekoodeille (tässä ohjeessa ~/build/src) sekä deploy-hakemistolle (tässä ohjeessa ~/build/deploy) ja kloonaa src-hakemistoon kaikki tarvittavat git-repositoryt:
```
mkdir -p ~/build/src
mkdir -p ~/build/deploy
cd ~/build/src
git clone https://github.com/vrk-kpa/e-identification-base-images-public.git
git clone https://github.com/vrk-kpa/e-identification-config-public.git
git clone https://github.com/vrk-kpa/e-identification-docker-images-public.git e-identification-docker-images
git clone https://github.com/vrk-kpa/e-identification-fake-vtj-public.git e-identification-fake-vtj
git clone https://github.com/vrk-kpa/e-identification-feedback-service-public.git e-identification-feedback-service
git clone https://github.com/vrk-kpa/e-identification-hst-idp-public.git e-identification-hst-idp
git clone https://github.com/vrk-kpa/e-identification-idp-service-public.git e-identification-idp-service
git clone https://github.com/vrk-kpa/e-identification-metadata-service-public.git e-identification-metadata-service
git clone https://github.com/vrk-kpa/e-identification-proxy-service-public.git e-identification-proxy-service
git clone https://github.com/vrk-kpa/e-identification-shared-api-public.git e-identification-shared-api
git clone https://github.com/vrk-kpa/e-identification-sp-service-public.git e-identification-sp-service
git clone https://github.com/vrk-kpa/e-identification-test-service-public.git e-identification-test-service
git clone https://github.com/vrk-kpa/e-identification-tupas-idp-public.git e-identification-tupas-idp
git clone https://github.com/vrk-kpa/e-identification-vtj-client-public.git e-identification-vtj-client
git clone https://github.com/vrk-kpa/e-identification-vartti-client-public.git e-identification-vartti-client
git clone https://github.com/vrk-kpa/e-identification-static-ui-public.git e-identification-static-ui
git clone https://github.com/vrk-kpa/e-identification-test-idp-public.git e-identification-test-idp-public
```

Osassa komponenteista build-skripteistä on poistettava käytöstä viittaukset sisäiseen docker-repoon:
```
sed --in-place "s/docker pull e-identification-docker-virtual/#docker pull e-identification-docker-virtual/g" \
 e-identification-idp-service/script/build.sh \
 e-identification-metadata-service/script/build.sh \
 e-identification-hst-idp/script/build.sh \
 e-identification-fake-vtj/script/build.sh \
 e-identification-sp-service/script/build.sh \
 e-identification-test-service/script/build.sh \
 e-identification-feedback-service/script/build.sh \
 e-identification-proxy-service/script/build.sh \
 e-identification-tupas-idp/script/build.sh \
 e-identification-vartti-client/script/build.sh \
 e-identification-test-idp/script/build.sh \
 e-identification-vtj-client/script/build.sh \
 e-identification-base-images-public/tomcat/build_images.sh \
 e-identification-base-images-public/tomcat-idp-3.2.1/build_images.sh \
 e-identification-base-images-public/tomcat-idp-3.4.1/build_images.sh \
 e-identification-base-images-public/tomcat-apache2-shibd-sp/build_images.sh \
 e-identification-base-images-public/centos7-shibd/build.sh
```

Lataa java base imageja varten tarvittavat jdk-8u151-linux-x64.rpm ja jdk-8u151-linux-x64.tar.gz:
Sen saa Esimerkiksi täältä http://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html

Siirrä ladattu jdk-8u151-linux-x64.rpm tiedosto oikeean paikkaan: 
mv jdk-8u151-linux-x64.rpm ~/build/src/e-identification-base-images-public/centos7-java8

Siirrä ladattu jdk-8u151-linux-x64.tar.gz tiedosto oikeean paikkaan: 
mv jdk-8u151-linux-x64.tar.gz ~/build/src/e-identification-base-images-public/java8

Käännä kaikki komponentit:
```
# Docker base imaget:
cd ~/build/src/e-identification-base-images-public/centos7-java8
./build.sh

cd ~/build/src/e-identification-base-images-public/centos7-shibd
./build.sh

cd ~/build/src/e-identification-base-images-public/java8
./build.sh

cd ~/build/src/e-identification-base-images-public/node
./build.sh

cd ~/build/src/e-identification-base-images-public/tomcat
./build_images.sh

cd ~/build/src/e-identification-base-images-public/tomcat-apache2-shibd-sp
./build_images.sh

cd ~/build/src/e-identification-base-images-public/tomcat-idp-3.2.1
./build_images.sh

cd ~/build/src/e-identification-base-images-public/tomcat-idp-3.4.1
./build_images.sh

# Shared api:
cd ~/build/src/e-identification-shared-api
mvn clean install

# Router-imaget:
cd ~/build/src/e-identification-docker-images
e-identification-external-router/script/build.sh local
e-identification-hst-router/script/build.sh local
e-identification-internal-router/script/build.sh local

# Loput imaget:
cd ~/build/src/e-identification-fake-vtj
script/build.sh -d local

cd ~/build/src/e-identification-feedback-service
script/build.sh -d local

cd ~/build/src/e-identification-hst-idp
script/build.sh -d local

cd ~/build/src/e-identification-idp-service
script/build.sh -d local

cd ~/build/src/e-identification-metadata-service
script/build.sh -d local

cd ~/build/src/e-identification-proxy-service
script/build.sh -d local

cd ~/build/src/e-identification-sp-service
script/build.sh -d local

cd ~/build/src/e-identification-test-service
script/build.sh -d local

cd ~/build/src/e-identification-tupas-idp
script/build.sh -d local

cd ~/build/src/e-identification-vtj-client
script/build.sh -d local

cd ~/build/src/e-identification-vartti-client
script/build.sh -d local

cd ~/build/src/e-identification-static-ui
script/build.sh -d local

cd ~/build/src/e-identification-test-idp
script/build.sh -d local
```

Aja deploy-prosessi lokaalille ympäristölle:
```
cd ~/build/src/e-identification-config-public/local-public
./deploy.sh all
```

Deployn jälkeen paketin mukana tuleva testiasiointipalvelu löytyy osoitteesta https://testipalvelu.test/

Huom! Selain varoittaa palvelinvarmenteista. Tämä on normaalia sillä julkaisussa on käytössä ns. self-signed varmenteet. Jotkin selaimet voivat vaatia yksityisen tilan käyttöä varoituksen ohittamiseksi.
