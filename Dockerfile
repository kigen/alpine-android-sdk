# Android Dockerfile
FROM anapsix/alpine-java:8_jdk

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="alpine-android-sdk" \
      org.label-schema.description="Android SDK Image based on Alpine distro" \
      org.label-schema.url="https://www.254bit.com/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/kigen/alpine-android-sdk" \
      org.label-schema.vendor="254Bit" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="0.1.0"

# Sets language to UTF8 : this works in pretty much all cases
ENV LANG en_US.UTF-8

ENV ANDROID_COMPONENTS platform-tools,android-23,build-tools-23.0.2,build-tools-24.0.0

# Environment variables
ENV ANDROID_HOME /usr/local/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV ANDROID_NDK_HOME /usr/local/android-ndk
ENV JENKINS_HOME $HOME
ENV PATH ${INFER_HOME}/bin:${PATH}
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools
ENV PATH $PATH:$ANDROID_SDK_HOME/build-tools/23.0.2
ENV PATH $PATH:$ANDROID_SDK_HOME/build-tools/24.0.0

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms4096m -Xmx4096m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Add build user account, values are set to default below
ENV RUN_USER mobileci
ENV RUN_UID 5089
ENV GROUP_ID 1900

ENV PROJECT /project

RUN	addgroup -g "${GROUP_ID}" "${RUN_USER}" \
	&& id $RUN_USER || adduser -u "$RUN_UID" \
		-g 'Build User' \
		-s '/bin/sh' \
		-S \
		-D "$RUN_USER" \
		-G "$RUN_USER" \ 
	&& apk update \                                                                                                                                                                                                                                                                                                                                                                                                                          
	&& set -x \
	&& apk add --no-cache \
		ca-certificates wget \
	&& update-ca-certificates \
	&& wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz \
	&& tar -xvzf android-sdk_r24.4.1-linux.tgz \
	&& mv android-sdk-linux /usr/local/android-sdk \
	&& rm android-sdk_r24.4.1-linux.tgz \
	&& echo y | /usr/local/android-sdk/tools/android update sdk --filter "${ANDROID_COMPONENTS}" --no-ui -a\ 
 	&& chown -R $RUN_USER:$RUN_USER $ANDROID_HOME $ANDROID_SDK_HOME  \
	&& chmod -R a+rx $ANDROID_HOME $ANDROID_SDK_HOME  \
	&& mkdir $PROJECT && chown -R $RUN_USER:$RUN_USER $PROJECT \
	&& echo "sdk.dir=$ANDROID_HOME" > local.properties &&  unset ANDROID_NDK_HOME \
	&& echo y | android update sdk --filter "extra-android-m2repository" --no-ui -a\ 
	&& mkdir "${ANDROID_HOME}/licenses" || true \
	&& echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_HOME}/licenses/android-sdk-license" \
	&& echo "d56f5187479451eabf01fb78af6dfcb131a6481e" >> "${ANDROID_HOME}/licenses/android-sdk-license"

WORKDIR $PROJECT