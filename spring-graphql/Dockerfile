FROM maven:3.9.9-amazoncorretto-17-alpine as builder
WORKDIR /home/app
ADD . /home/app/spring-graphql
RUN cd spring-graphql && mvn -Dmaven.test.skip=true clean install

FROM openjdk:24-ea-17-oraclelinux9
WORKDIR /home/app
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/home/app/spring-graphql-0.0.1-SNAPSHOT.jar"]
COPY --from=builder /home/app/spring-graphql/target/spring-graphql-0.0.1-SNAPSHOT.jar spring-graphql-0.0.1-SNAPSHOT.jar