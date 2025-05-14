FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /workspace/app

COPY . .
RUN ./gradlew build -x test

FROM eclipse-temurin:17-jre-alpine
VOLUME /tmp
COPY --from=build /workspace/app/build/libs/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
