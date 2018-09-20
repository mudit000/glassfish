FROM maven:3.5-jdk-8

RUN apt-get update
RUN apt-get install -y apt-utils ant unzip tar wget zip sendmail

COPY ./entrypoint.sh /etc/entrypoint.sh
RUN chmod +x /etc/entrypoint.sh

ENV M2_HOME /usr/share/maven
ENV ANT_HOME /usr/share/ant

ENTRYPOINT ["/etc/entrypoint.sh"]