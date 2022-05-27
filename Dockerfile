FROM centos:latest

ENV HOME=/home/jenkins
# In future chnage the verison tag to have latest remoting jar
ARG VERSION=4.7

RUN yum -y install git sudo openssh-server openssh-clients curl wget yum zip unzip

# Install Java 8
RUN yum install -y wget java-1.8.0-openjdk && yum install -y java-1.8.0-openjdk-devel && \
    echo "JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" | tee -a /etc/profile && source /etc/profile && echo $JAVA_HOME

# Add Jenkins user and group
RUN groupadd -g 10000 jenkins \
    && useradd -d $HOME -u 10000 -g jenkins jenkins

# Install jenkins jnlp
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/slave.jar

COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod 755 /usr/local/bin/jenkins-slave && chown jenkins:jenkins /usr/local/bin/jenkins-slave

RUN mkdir /home/jenkins/.jenkins \
    && mkdir -p /home/jenkins/agent \
    && chown -R jenkins:jenkins /home/jenkins

VOLUME /home/jenkins/.jenkins
VOLUME /home/jenkins/agent

WORKDIR /home/jenkins

USER jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
