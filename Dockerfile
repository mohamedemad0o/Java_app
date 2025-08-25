# Dockerfile
FROM eclipse-temurin:17-jre
ARG APP_ENV=dev
ENV APP_ENV=${APP_ENV}

COPY target/*.jar /app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]