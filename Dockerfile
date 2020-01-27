# Inspired from https://github.com/heikomaass/docker-android/blob/master/android-sdk/Dockerfile
FROM node:12-stretch

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV ANDROID_HOME /opt/android-sdk-linux

RUN dpkg --add-architecture i386 \
  && apt-get update && apt-get install -y --no-install-recommends openjdk-8-jdk-headless \
    expect \
    libncurses5:i386 \
    libstdc++6:i386 \
    zlib1g:i386 \
    build-essential \
    openssh-client \
  && apt-get install -y --no-install-recommends maven \
  && rm -rf /var/lib/apt/lists/*

# Install Android SDK installer
ARG ANDROID_SDK_VERSION=4333796
ARG ANDROID_SDK_SHA256=92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9
RUN curl -o android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
  && echo "${ANDROID_SDK_SHA256} android-sdk.zip" | sha256sum -c \
  && mkdir - ${ANDROID_HOME} \
  && unzip -q -d ${ANDROID_HOME} android-sdk.zip \
  && rm *.zip

# Install newer yarn
ENV YARN_VERSION=1.21.1
RUN wget -qO- https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --import
RUN curl -Lo yarn.tar.gz https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz \
    && curl -Lo yarn.tar.gz.asc https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz.asc \ 
    && gpg --verify yarn.tar.gz.asc \
    && mkdir -p /opt/yarn \
    && tar -x -C /opt/yarn --strip-components=1 -f yarn.tar.gz \
    && rm yarn.tar.gz

# Install gradle
ENV GRADLE_VERSION=5.4.1
ENV GRADLE_SHA256=14cd15fc8cc8705bd69dcfa3c8fefb27eb7027f5de4b47a8b279218f76895a91
RUN curl -Lo gradle.zip https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip \
    && echo "${GRADLE_SHA256} gradle.zip" | sha256sum -c \
    && mkdir -p /opt/gradle \
    && unzip -q -d /opt/gradle gradle.zip \
    && rm gradle.zip

ENV PATH /opt/yarn/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:/opt/gradle/gradle-${GRADLE_VERSION}/bin:${PATH}

# Install Android SDK components
RUN mkdir /root/.android \
  && touch /root/.android/repositories.cfg \
  && yes | sdkmanager --licenses \
  && sdkmanager "tools" \
		"platform-tools" \
		"build-tools;27.0.3" \
		"platforms;android-27" \
		"add-ons;addon-google_apis-google-24" \
		"extras;android;m2repository" \
		"extras;google;google_play_services" \
		"patcher;v4" \
  && yes | sdkmanager --licenses
