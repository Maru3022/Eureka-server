# Eureka Server

Service discovery registry for the Fitness Microservices Platform, built with Spring Boot 3.4, Spring Cloud 2024, and Netflix Eureka.

## What This Repository Contains

This repository is intentionally focused on one responsibility:

- running a standalone Eureka Server on port `8761`
- exposing the standard Eureka registry endpoints
- providing a polished custom dashboard over the built-in Eureka UI
- supporting local single-node mode and two-peer cluster mode

There are no domain controllers, services, repositories, or persistence layers in this project. The core behavior comes from `spring-cloud-starter-netflix-eureka-server`.

## Architecture Role

In the wider fitness platform, this service acts as the registry that other microservices use to:

- register themselves on startup
- send periodic heartbeats
- discover peer services through logical names
- support gateway routing and load-balancing

Typical flow:

1. A downstream service starts.
2. It registers in Eureka using `defaultZone`.
3. Eureka stores the instance metadata and health state.
4. Other services query Eureka to resolve service locations.

## Stack

- Java 21 runtime
- Spring Boot `3.4.2`
- Spring Cloud `2024.0.0`
- Netflix Eureka Server
- Spring Boot Actuator
- Maven Wrapper
- Docker

## Project Layout

```text
.
|-- src/main/java/com/example/eurekaserver/EurekaServerApplication.java
|-- src/main/resources/application.yml
|-- src/main/resources/application-peer1.yml
|-- src/main/resources/application-peer2.yml
|-- src/main/resources/templates/eureka/
|-- src/main/resources/static/eureka/css/wro.css
|-- src/test/java/com/example/eurekaserver/EurekaServerApplicationTests.java
|-- Dockerfile
|-- pom.xml
`-- DOCUMENTATION.md
```

## Run Locally

### With Maven Wrapper

```bash
./mvnw spring-boot:run
```

On Windows:

```powershell
.\mvnw.cmd spring-boot:run
```

The dashboard will be available at:

```text
http://localhost:8761/
```

## Build

```bash
./mvnw clean package
```

## Test

```bash
./mvnw test
```

## Profiles

### Default

`application.yml` runs a single standalone registry:

- `register-with-eureka: false`
- `fetch-registry: false`

### Peer 1

```bash
java -jar target/eureka-server-0.0.1-SNAPSHOT.jar --spring.profiles.active=peer1
```

### Peer 2

```bash
java -jar target/eureka-server-0.0.1-SNAPSHOT.jar --spring.profiles.active=peer2
```

These profiles are meant for clustered Eureka experiments where the nodes replicate registry state between each other.

## Docker

Build the image:

```bash
docker build -t eureka-server .
```

Run the container:

```bash
docker run -p 8761:8761 eureka-server
```

## UI Customization

The default Eureka dashboard is overridden through classpath resources:

- `src/main/resources/templates/eureka/status.ftlh`
- `src/main/resources/templates/eureka/lastn.ftlh`
- `src/main/resources/templates/eureka/header.ftlh`
- `src/main/resources/static/eureka/css/wro.css`

That keeps the server logic standard while allowing the dashboard to feel more intentional and project-specific.

## Notes

- `target/` is generated build output and should not be committed.
- This repository currently contains only the registry service, even if the larger platform includes gateway and business services elsewhere.
- Detailed technical analysis lives in [DOCUMENTATION.md](/C:/Project/eureka-server/DOCUMENTATION.md).