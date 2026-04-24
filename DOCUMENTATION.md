# Eureka Server Technical Analysis

## 1. Executive Summary

The project is still a minimal Eureka registry at the code level, but it is no longer minimal in delivery capabilities. The repository now supports:

- Docker packaging for containerized runtime
- Kubernetes deployment in both `single-node` and `peer-cluster` modes
- richer runtime configuration through environment variables
- liveness and readiness probes through Actuator
- a multi-job CI/CD pipeline with optional deployment

This keeps the application small while making the operational story substantially more complete.

## 2. Current Repository Inventory

### Application Layer

- `src/main/java/com/example/eurekaserver/EurekaServerApplication.java`
- `src/main/resources/application.yml`
- `src/main/resources/application-peer1.yml`
- `src/main/resources/application-peer2.yml`
- `src/main/resources/templates/eureka/`
- `src/main/resources/static/eureka/css/wro.css`

### Delivery Layer

- `Dockerfile`
- `.dockerignore`
- `.github/workflows/ci-cd.yml`
- `k8s/single-node/`
- `k8s/peer-cluster/`

### Test Layer

- `src/test/java/com/example/eurekaserver/EurekaServerApplicationTests.java`

## 3. Application Architecture

### Service Role

This service acts as the discovery registry for the wider platform:

- downstream services register themselves in Eureka
- clients discover service locations through the registry
- peer mode allows two registry nodes to replicate instance state

### Code Complexity

The Java surface remains intentionally small:

- one application bootstrap class
- framework-provided REST and dashboard behavior
- no custom business domain model

That is still the correct design for a dedicated infrastructure service.

## 4. Configuration Strategy After The Change

### Default Runtime

`application.yml` is now suitable for both local and container-based runtime because it is parameterized with environment variables.

Main improvements:

- `server.port` can be overridden with `SERVER_PORT`
- `defaultZone` can be overridden with `EUREKA_DEFAULT_ZONE`
- hostname and IP behavior can be driven from the environment
- self-preservation is externally configurable
- readiness and liveness probes are enabled

### Peer Profiles

`application-peer1.yml` and `application-peer2.yml` are still present, but they now support environment overrides. This matters because Kubernetes peer deployments can keep both pods on the same service port while still pointing each peer at the other peer's service DNS name.

## 5. Kubernetes Design

## 5.1 Single-Node Topology

Path: `k8s/single-node/`

Use case:

- dev clusters
- demos
- environments where one registry node is acceptable

Resources included:

- namespace
- configmap
- deployment
- service
- ingress
- pod disruption budget
- network policy

Operational considerations:

- probes are mapped to Actuator liveness and readiness endpoints
- runtime behavior is controlled by configmap environment variables
- service exposure is standardized through one Kubernetes service

## 5.2 Peer-Cluster Topology

Path: `k8s/peer-cluster/`

Use case:

- environments where a single registry instance is not desirable
- teams that want to use the already existing `peer1` and `peer2` profiles

Resources included:

- namespace
- shared client-facing service
- dedicated peer services
- `eureka-peer1` deployment
- `eureka-peer2` deployment
- ingress
- pod disruption budget
- network policy

Operational considerations:

- each peer runs with its corresponding Spring profile
- both peers expose port `8761` inside Kubernetes for operational consistency
- peer replication uses Kubernetes service DNS names
- clients can point at the shared `eureka-registry` service

## 6. Containerization Changes

The Docker image is now more suitable for orchestrated environments:

- non-root runtime user
- `JAVA_OPTS` support for runtime tuning
- compatibility with packaged jar delivery from the CI pipeline
- cleaner build context through `.dockerignore`

The image remains intentionally simple, which is good for a registry service.

## 7. CI/CD Design

The new GitHub Actions pipeline is no longer a basic build-only flow. It now models a real delivery chain.

### Jobs

1. `build-and-test`
   - checks out the repository
   - restores Maven cache
   - runs `clean verify`
   - uploads the packaged jar as an artifact

2. `validate-kubernetes`
   - installs `kubectl`
   - renders both Kustomize deployment modes
   - validates them with client-side dry-run

3. `build-and-publish-image`
   - downloads the packaged jar
   - builds the container image with Buildx
   - pushes to GHCR on `main`
   - keeps PR builds non-publishing

4. `render-manifests`
   - produces rendered manifest bundles as downloadable artifacts

5. `deploy`
   - runs only on pushes to `main`
   - requires `KUBE_CONFIG_DATA`
   - applies either `single-node` or `peer-cluster`
   - verifies rollout status

### Why This Is Stronger

The pipeline now validates three layers independently:

- Java application correctness
- container packaging readiness
- Kubernetes deployment correctness

That is a meaningful upgrade from a plain Maven run.

## 8. Testing Improvements

The test suite now covers more than context startup:

- context bootstrapping
- dashboard response at `/`
- readiness probe response at `/actuator/health/readiness`

This is still lightweight, but it is much more aligned with modern platform deployment checks.

## 9. Risks And Remaining Tradeoffs

### Strengths

- the application remains simple to understand
- deployment options are now explicit and versioned
- health probes and env-driven config make the service much easier to operate
- the pipeline supports both validation and release concerns

### Remaining Tradeoffs

- the peer cluster is more operationally complex than the single-node mode
- true production HA still depends on how downstream clients are configured and how ingress/service routing is handled in the target cluster
- the workflow assumes GHCR and GitHub Actions as the default delivery stack
- local validation here is limited to Maven tests unless the machine also has Docker and kubectl installed

## 10. Final Assessment

The repository is no longer just a code wrapper around the Eureka starter. It now has a complete delivery story: runtime configuration for containers, Kubernetes deployment variants, health-aware behavior, and a multi-stage CI/CD path. The service remains intentionally small in code, but it is now much more realistic as an infrastructure component in a modern platform.