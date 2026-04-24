# Eureka Server

Kubernetes-ready service discovery registry for the Fitness Microservices Platform, built with Spring Boot 3.4, Spring Cloud 2024, Netflix Eureka, Docker, Kustomize, and GitHub Actions.

## What Is In This Repository

This repository focuses on one responsibility and now covers the full delivery path around it:

- Eureka Server application code
- custom Eureka dashboard templates and styling
- Docker image packaging
- Kubernetes manifests for `single-node` and `peer-cluster` modes
- multi-stage CI/CD pipeline for build, test, image publishing, manifest rendering, and optional deployment

There are still no domain controllers, repositories, or persistence layers here. The service remains intentionally small, but its runtime and delivery model are now much more production-oriented.

## Stack

- Java 21
- Spring Boot `3.4.2`
- Spring Cloud `2024.0.0`
- Netflix Eureka Server
- Spring Boot Actuator
- Docker
- Kubernetes
- Kustomize
- GitHub Actions
- GHCR image publishing

## Project Layout

```text
.
|-- .github/workflows/ci-cd.yml
|-- k8s/single-node/
|-- k8s/peer-cluster/
|-- src/main/java/com/example/eurekaserver/
|-- src/main/resources/application.yml
|-- src/main/resources/application-peer1.yml
|-- src/main/resources/application-peer2.yml
|-- src/main/resources/templates/eureka/
|-- src/main/resources/static/eureka/css/wro.css
|-- src/test/java/com/example/eurekaserver/EurekaServerApplicationTests.java
|-- .dockerignore
|-- Dockerfile
|-- pom.xml
|-- README.md
`-- DOCUMENTATION.md
```

## Local Development

Run locally:

```bash
./mvnw spring-boot:run
```

Windows:

```powershell
.\mvnw.cmd spring-boot:run
```

Dashboard:

```text
http://localhost:8761/
```

Run tests:

```bash
./mvnw test
```

Build the jar:

```bash
./mvnw clean package
```

## Docker

Build the container image after packaging:

```bash
docker build -t eureka-server .
```

Run it:

```bash
docker run -p 8761:8761 eureka-server
```

The Docker image now runs as a non-root user and supports `JAVA_OPTS` for container and Kubernetes runtime tuning.

## Kubernetes

The repository ships with two deployment modes.

### 1. Single Node

Use this for local clusters, demos, or simple environments:

```bash
kubectl apply -k k8s/single-node
```

What it includes:

- namespace
- configmap-driven runtime settings
- deployment
- service
- ingress
- pod disruption budget
- network policy
- health probes wired to Actuator readiness and liveness endpoints

### 2. Peer Cluster

Use this when you want an actual two-node Eureka peer topology inside Kubernetes:

```bash
kubectl apply -k k8s/peer-cluster
```

What it includes:

- dedicated peer services for `peer1` and `peer2`
- two deployments with `peer1` and `peer2` Spring profiles
- shared front-door service for clients
- ingress
- disruption budget
- network policy

The cluster overlay keeps both peers on port `8761` in Kubernetes and uses service DNS names for replication.

## Configuration Model

The application is now parameterized for container and cluster deployment through environment variables such as:

- `SERVER_PORT`
- `EUREKA_INSTANCE_HOSTNAME`
- `EUREKA_DEFAULT_ZONE`
- `EUREKA_REGISTER_WITH_EUREKA`
- `EUREKA_FETCH_REGISTRY`
- `EUREKA_SELF_PRESERVATION`

Actuator health probes are enabled at:

- `/actuator/health/liveness`
- `/actuator/health/readiness`

## CI/CD

The GitHub Actions pipeline in `.github/workflows/ci-cd.yml` now performs:

1. Maven build and test
2. Kubernetes manifest rendering and client-side validation for both deployment modes
3. Docker image build
4. GHCR push on `main`
5. rendered manifest artifact publishing
6. optional Kubernetes deployment when `KUBE_CONFIG_DATA` is configured

Optional CD behavior:

- `KUBE_CONFIG_DATA` secret enables cluster deployment from the workflow
- `K8S_OVERLAY` repository variable selects `single-node` or `peer-cluster`

## Testing

The test suite now verifies:

- Spring context startup
- dashboard availability at `/`
- readiness probe availability at `/actuator/health/readiness`

## Notes

- `target/` remains generated build output.
- The untracked local `.qwen/` directory is not part of the deployment story and is intentionally untouched.
- Detailed implementation analysis lives in [DOCUMENTATION.md](/C:/Project/Eureka-Server/DOCUMENTATION.md).