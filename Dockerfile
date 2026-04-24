FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring

COPY target/*-exec.jar app.jar

RUN chown spring:spring /app/app.jar

USER spring

ENV JAVA_OPTS=""

EXPOSE 8761 8762

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
