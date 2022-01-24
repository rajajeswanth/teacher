# syntax=docker/dockerfile:1

FROM openjdk:16-alpine3.13

WORKDIR /student

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

COPY src ./src

CMD ["./mvnw", "spring-boot:run"]