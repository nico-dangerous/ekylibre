FROM ruby:2.2.3
RUN echo deb http://ftp.debian.org/debian jessie-backports main  >> /etc/apt/sources.list
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get -t jessie-backports install -y postgresql-client && DEBIAN_FRONTEND=noninteractive apt-get install -y libpq-dev nodejs openjdk-7-jdk imagemagick graphicsmagick tesseract-ocr tesseract-ocr-ara tesseract-ocr-jpn tesseract-ocr-fra \
 tesseract-ocr-eng tesseract-ocr-spa pdftk libreoffice poppler-utils poppler-data ghostscript libicu52 libcurl4-openssl-dev libgeos-dev libgeos++-dev libproj-dev libpq-dev libxml2-dev libxslt1-dev  \
zlib1g-dev libicu-dev libqtwebkit-dev clang postgresql-client-9.6
RUN mkdir /webapp
WORKDIR /webapp
ADD Gemfile /webapp/Gemfile
ADD Gemfile.lock /webapp/Gemfile.lock
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/clang++ 100
RUN JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install
ADD . /webapp
