FROM openjdk:17
RUN mkdir -p /app
COPY target/numeric-0.0.1.jar /app
WORKDIR /app
EXPOSE 8080
ENTRYPOINT [ "java", "-jar", "numeric-0.0.1.jar" ]