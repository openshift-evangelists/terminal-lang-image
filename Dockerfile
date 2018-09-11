FROM workshop-base-centos7:latest

USER root

# Install Python 3.6.

ENV PYTHON_VERSION=3.6
RUN HOME=/root && \
    INSTALL_PKGS="rh-python36 rh-python36-python-devel \
        rh-python36-python-setuptools rh-python36-python-pip \
        httpd24 httpd24-httpd-devel httpd24-mod_ssl httpd24-mod_auth_kerb \
        httpd24-mod_ldap httpd24-mod_session atlas-devel gcc-gfortran \
        libffi-devel libtool-ltdl" && \
    yum install -y centos-release-scl && \
    yum -y --setopt=tsflags=nodocs install --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    # Remove centos-logos (httpd dependency) to keep image size smaller.
    rpm -e --nodeps centos-logos && \
    yum -y clean all --enablerepo='*'

RUN source scl_source enable rh-python36 && \
    virtualenv /opt/app-root && \
    source /opt/app-root/bin/activate && \
    pip install -U pip setuptools wheel && \
    chown -R 1001:0 /opt/app-root && \
    fix-permissions /opt/app-root -P

COPY profiles/. /opt/workshop/etc/profile.d/

# Install Java JDK 8, Maven 3.3, Gradle 2.6.

RUN HOME=/root && \
    INSTALL_PKGS="bc java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

ENV MAVEN_VERSION 3.3.9
RUN HOME=/root && \
    (curl -s -0 http://www.eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn

ENV GRADLE_VERSION 2.6
RUN HOME=/root && \
    curl -sL -0 https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip -o /tmp/gradle-$GRADLE_VERSION-bin.zip && \
    unzip /tmp/gradle-$GRADLE_VERSION-bin.zip -d /usr/local/ && \
    rm /tmp/gradle-$GRADLE_VERSION-bin.zip && \
    mv /usr/local/gradle-$GRADLE_VERSION /usr/local/gradle && \
    ln -sf /usr/local/gradle/bin/gradle /usr/local/bin/gradle

USER 1001
