# Eureka Server - Full Documentation

## Project Overview

This is a **Spring Boot 3.4.2 Netflix Eureka Server** that serves as the **Service Discovery Registry** for the "Fitness Microservices Platform." The project is intentionally minimal -- it is a standard Eureka Server setup with no custom controllers, services, repositories, DTOs, or entity classes. All functionality is provided by the `spring-cloud-starter-netflix-eureka-server` library.

---

## Table of Contents

1. [Application Methods](#1-application-methods)
2. [Test Methods](#2-test-methods)
3. [Eureka Server Built-in REST API](#3-eureka-server-built-in-rest-api)
4. [Configuration Reference](#4-configuration-reference)
5. [Dependencies](#5-dependencies)
6. [Docker & Infrastructure](#6-docker--infrastructure)

---

## 1. Application Methods

### 1.1 EurekaServerApplication.main()

**File:** `src/main/java/com/example/eurekaserver/EurekaServerApplication.java`

```java
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```

| Attribute | Description |
|---|---|
| **Class** | `com.example.eurekaserver.EurekaServerApplication` |
| **Method** | `main` |
| **Signature** | `public static void main(String[] args)` |
| **Parameters** | `String[] args` - Command-line arguments passed to the application |
| **Return Type** | `void` |
| **Access Modifier** | `public static` |

#### Annotations

| Annotation | Purpose |
|---|---|
| `@SpringBootApplication` | Marks this as a Spring Boot application. Enables auto-configuration, component scanning, and property support. Combines `@Configuration`, `@EnableAutoConfiguration`, and `@ComponentScan`. |
| `@EnableEurekaServer` | Activates the Netflix Eureka Server functionality. Turns this application into a service discovery registry that other microservices can register with. |

#### Implementation Details

The method delegates to `SpringApplication.run()` which:
1. Creates a new `SpringApplication` instance
2. Bootstraps the Spring application context
3. Starts the embedded web server (Tomcat by default)
4. Registers all beans and auto-configured components
5. Starts the Eureka Server on port 8761

#### Execution Flow

```
main() → SpringApplication.run() → Spring Context Initialization → 
Eureka Server Startup → Web Server Start (port 8761)
```

---

## 2. Test Methods

### 2.1 EurekaServerApplicationTests.contextLoads()

**File:** `src/test/java/com/example/eurekaserver/EurekaServerApplicationTests.java`

```java
@SpringBootTest
class EurekaServerApplicationTests {

    @Test
    void contextLoads() {
    }
}
```

| Attribute | Description |
|---|---|
| **Class** | `com.example.eurekaserver.EurekaServerApplicationTests` |
| **Method** | `contextLoads` |
| **Signature** | `void contextLoads()` |
| **Parameters** | None |
| **Return Type** | `void` |
| **Access Modifier** | package-private (default) |

#### Annotations

| Annotation | Purpose |
|---|---|
| `@SpringBootTest` | Boots the full Spring application context for integration testing. Loads all beans, auto-configurations, and embedded server. |
| `@Test` | JUnit 5 annotation that marks this method as a test case. |

#### Implementation Details

This is a **smoke test** with an empty body. Its purpose is to verify that:
- The Spring application context loads successfully
- All beans are properly configured
- No exceptions are thrown during startup
- The Eureka Server can be initialized without errors

If the context fails to load, the test will fail with an `IllegalStateException` or similar exception.

---

## 3. Eureka Server Built-in REST API

Since this project has no custom controllers, all API endpoints are provided by the `spring-cloud-starter-netflix-eureka-server` library. Below is the complete documentation of the built-in Eureka Server REST API.

### 3.1 Service Registration Endpoints

#### Register a New Application Instance

```
POST /eureka/apps/{appID}
```

| Attribute | Description |
|---|---|
| **Purpose** | Registers a new service instance with the Eureka Server |
| **Path Parameter** | `appID` - The application name (e.g., "TRAINING-SERVICE") |
| **Request Body** | XML/JSON containing instance information (hostname, port, health check URL, etc.) |
| **Response** | `204 No Content` on success |
| **Content-Type** | `application/xml` or `application/json` |

**Example Request Body (XML):**
```xml
<instance>
    <hostName>192.168.1.100</hostName>
    <port enabled="true">8080</port>
    <vipAddress>training-service</vipAddress>
    <healthCheckUrl>http://192.168.1.100:8080/actuator/health</healthCheckUrl>
    <statusPageUrl>http://192.168.1.100:8080/actuator/info</statusPageUrl>
    <homePageUrl>http://192.168.1.100:8080/</homePageUrl>
    <dataCenterInfo class="com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo">
        <name>MyOwn</name>
    </dataCenterInfo>
</instance>
```

#### Deregister an Application Instance

```
DELETE /eureka/apps/{appID}/{instanceID}
```

| Attribute | Description |
|---|---|
| **Purpose** | Removes a service instance from the Eureka registry |
| **Path Parameters** | `appID` - Application name, `instanceID` - Instance identifier |
| **Response** | `200 OK` on success |

#### Send Heartbeat (Renew Lease)

```
PUT /eureka/apps/{appID}/{instanceID}?status=UP&lastDirtyTimestamp={timestamp}
```

| Attribute | Description |
|---|---|
| **Purpose** | Renews the lease for a service instance (keeps it alive) |
| **Path Parameters** | `appID` - Application name, `instanceID` - Instance identifier |
| **Query Parameters** | `status` - Current status (UP, DOWN, STARTING, OUT_OF_SERVICE), `lastDirtyTimestamp` - Timestamp |
| **Response** | `200 OK` on success, `404 Not Found` if instance not found |
| **Frequency** | Typically every 30 seconds (configurable via `lease-renewal-interval-in-seconds`) |

### 3.2 Service Discovery Endpoints

#### Get All Applications

```
GET /eureka/apps
```

| Attribute | Description |
|---|---|
| **Purpose** | Returns all registered applications and their instances |
| **Response** | `200 OK` with XML/JSON body containing all applications |
| **Content-Type** | `application/xml` or `application/json` |

**Example Response (JSON):**
```json
{
  "applications": {
    "versions__delta": "1",
    "apps__hashcode": "UP_2_",
    "application": [
      {
        "name": "TRAINING-SERVICE",
        "instance": [
          {
            "hostName": "192.168.1.100",
            "app": "TRAINING-SERVICE",
            "ipAddr": "192.168.1.100",
            "status": "UP",
            "port": {"$": 8080, "@enabled": "true"},
            "securePort": {"$": 443, "@enabled": "false"},
            "countryId": 1,
            "dataCenterInfo": {
              "@class": "com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo",
              "name": "MyOwn"
            }
          }
        ]
      }
    ]
  }
}
```

#### Get Application by ID

```
GET /eureka/apps/{appID}
```

| Attribute | Description |
|---|---|
| **Purpose** | Returns all instances of a specific application |
| **Path Parameter** | `appID` - Application name |
| **Response** | `200 OK` with application details |

#### Get Instance by ID

```
GET /eureka/apps/{appID}/{instanceID}
```

| Attribute | Description |
|---|---|
| **Purpose** | Returns a specific instance by application and instance ID |
| **Path Parameters** | `appID` - Application name, `instanceID` - Instance identifier |
| **Response** | `200 OK` with instance details |

#### Get Instances by VIP Address

```
GET /eureka/vips/{vipAddress}
```

| Attribute | Description |
|---|---|
| **Purpose** | Returns all instances registered under a specific VIP address |
| **Path Parameter** | `vipAddress` - Virtual IP address (logical service name) |
| **Response** | `200 OK` with matching instances |

### 3.3 Instance Status Management

#### Update Instance Status

```
PUT /eureka/apps/{appID}/{instanceID}/status?value=UP&lastDirtyTimestamp={timestamp}
```

| Attribute | Description |
|---|---|
| **Purpose** | Changes the status of a service instance |
| **Path Parameters** | `appID`, `instanceID` |
| **Query Parameters** | `value` - New status (UP, DOWN, STARTING, OUT_OF_SERVICE), `lastDirtyTimestamp` |
| **Response** | `200 OK` on success |

#### Update Instance Metadata

```
PUT /eureka/apps/{appID}/{instanceID}/metadata?key={key}&value={value}
```

| Attribute | Description |
|---|---|
| **Purpose** | Updates custom metadata for a service instance |
| **Path Parameters** | `appID`, `instanceID` |
| **Query Parameters** | `key` - Metadata key, `value` - Metadata value |
| **Response** | `200 OK` on success |

### 3.4 Eureka Server Web Dashboard

| Endpoint | Description |
|---|---|
| `http://localhost:8761/` | Main Eureka Server dashboard showing all registered services, instance details, and server status |

The dashboard provides:
- List of all registered applications
- Instance count and status
- General server information (uptime, memory usage)
- Links to instance details

### 3.5 Actuator Endpoints

Enabled by `spring-boot-starter-actuator`:

| Endpoint | URL | Description |
|---|---|---|
| Health | `/actuator/health` | Shows server health status (UP/DOWN) |
| Info | `/actuator/info` | Shows application information |
| Metrics | `/actuator/metrics` | Shows various metrics (memory, CPU, HTTP requests) |
| Beans | `/actuator/beans` | Lists all Spring beans in the context |
| Mappings | `/actuator/mappings` | Shows all registered request mappings |
| ConfigProps | `/actuator/configprops` | Displays all configuration properties |
| Env | `/actuator/env` | Shows environment properties |
| Loggers | `/actuator/loggers` | View and modify logger levels |

---

## 4. Configuration Reference

### 4.1 Main Configuration (application.yml)

**File:** `src/main/resources/application.yml`

```yaml
server:
  port: 8761

spring:
  application:
    name: eureka-server

eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
    service-url:
      defaultZone: http://localhost:8761/eureka/
  server:
    wait-time-in-ms-when-sync-empty: 0
    enable-self-preservation: false
```

#### Configuration Properties Explained

| Property | Value | Description |
|---|---|---|
| `server.port` | `8761` | The port on which the Eureka Server listens. Port 8761 is the standard Eureka Server port. |
| `spring.application.name` | `eureka-server` | The logical name of this application. Used for identification in logs and monitoring. |
| `eureka.client.register-with-eureka` | `false` | Prevents this server from registering itself with another Eureka Server. Set to `true` in cluster mode. |
| `eureka.client.fetch-registry` | `false` | Prevents this server from fetching the registry from another Eureka Server. Set to `true` in cluster mode. |
| `eureka.client.service-url.defaultZone` | `http://localhost:8761/eureka/` | The URL where other services register. In cluster mode, this points to peer servers. |
| `eureka.server.wait-time-in-ms-when-sync-empty` | `0` | Wait time (in milliseconds) when the registry is empty during initial sync. Set to 0 for immediate startup. |
| `eureka.server.enable-self-preservation` | `false` | Disables self-preservation mode. In self-preservation mode, Eureka stops expiring instances during network issues. Disabled here for development/testing. |

### 4.2 Peer 1 Configuration (application-peer1.yml)

**File:** `src/main/resources/application-peer1.yml`

```yaml
server:
  port: 8761

eureka:
  client:
    register-with-eureka: true
    fetch-registry: true
    service-url:
      defaultZone: http://peer2:8762/eureka/
  instance:
    hostname: peer1
    prefer-ip-address: false
```

| Property | Value | Description |
|---|---|---|
| `eureka.client.register-with-eureka` | `true` | This peer registers with another Eureka Server (peer2). |
| `eureka.client.fetch-registry` | `true` | This peer fetches the registry from peer2 for replication. |
| `eureka.client.service-url.defaultZone` | `http://peer2:8762/eureka/` | Points to peer2 for registration and discovery. |
| `eureka.instance.hostname` | `peer1` | The hostname for this peer instance. |
| `eureka.instance.prefer-ip-address` | `false` | Uses hostname instead of IP address in registration. |

**Run with:** `java -jar app.jar --spring.profiles.active=peer1`

### 4.3 Peer 2 Configuration (application-peer2.yml)

**File:** `src/main/resources/application-peer2.yml`

```yaml
server:
  port: 8762

eureka:
  client:
    register-with-eureka: true
    fetch-registry: true
    service-url:
      defaultZone: http://peer1:8761/eureka/
  instance:
    hostname: peer2
    prefer-ip-address: false
```

| Property | Value | Description |
|---|---|---|
| `server.port` | `8762` | Runs on a different port to avoid conflicts on the same machine. |
| `eureka.client.service-url.defaultZone` | `http://peer1:8761/eureka/` | Points to peer1 for registration and discovery. |
| `eureka.instance.hostname` | `peer2` | The hostname for this peer instance. |

**Run with:** `java -jar app.jar --spring.profiles.active=peer2`

---

## 5. Dependencies

### 5.1 Build Configuration (pom.xml)

**File:** `pom.xml`

#### Parent

| Group ID | Artifact ID | Version |
|---|---|---|
| `org.springframework.boot` | `spring-boot-starter-parent` | `3.4.2` |

#### Dependencies

| Dependency | Group ID | Artifact ID | Scope | Purpose |
|---|---|---|---|---|
| **Spring Boot Actuator** | `org.springframework.boot` | `spring-boot-starter-actuator` | `compile` | Provides production-ready features: health checks, metrics, monitoring endpoints. Enables `/actuator/*` endpoints. |
| **Netflix Eureka Server** | `org.springframework.cloud` | `spring-cloud-starter-netflix-eureka-server` | `compile` | Core Eureka Server library. Provides service discovery, registration, heartbeat, and discovery REST APIs. |
| **Spring Boot Test** | `org.springframework.boot` | `spring-boot-starter-test` | `test` | Testing framework: JUnit 5, Mockito, Spring Test, AssertJ, Hamcrest. |

#### Dependency Management

| Group ID | Artifact ID | Version | Type |
|---|---|---|---|
| `org.springframework.cloud` | `spring-cloud-dependencies` | `2024.0.0` | `pom` (import) |

The Spring Cloud BOM (Bill of Materials) manages compatible versions of all Spring Cloud dependencies.

#### Build Plugin

| Plugin | Purpose |
|---|---|
| `spring-boot-maven-plugin` | Packages the application as an executable JAR file. |

#### Java Version

The project requires **Java 21** (as indicated by the Dockerfile using `eclipse-temurin:21-jre-alpine`).

---

## 6. Docker & Infrastructure

### 6.1 Dockerfile

**File:** `Dockerfile`

```dockerfile
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "app.jar"]
```

| Instruction | Description |
|---|---|
| `FROM eclipse-temurin:21-jre-alpine` | Uses Eclipse Temurin JRE 21 on Alpine Linux (minimal image, ~50MB). |
| `WORKDIR /app` | Sets the working directory inside the container to `/app`. |
| `COPY target/*.jar app.jar` | Copies the built JAR from the `target/` directory into the container as `app.jar`. |
| `EXPOSE 8761` | Documents that the container listens on port 8761. |
| `ENTRYPOINT ["java", "-jar", "app.jar"]` | Executes the JAR file when the container starts. |

**Build Command:**
```bash
mvn clean package -DskipTests
docker build -t eureka-server:latest .
```

**Run Command:**
```bash
docker run -p 8761:8761 eureka-server:latest
```

### 6.2 Docker Compose Configuration

**File:** `docker-compose.yml`

The project defines a multi-service architecture with 7 services on a shared `fitness-network`:

| Service | Port | Description |
|---|---|---|
| `eureka-server` | 8761 | Service discovery registry |
| `api-gateway` | 8075 | API Gateway for routing requests to microservices |
| `trains-service` | - | Microservice for train/workout management |
| `training-service` | - | Microservice for training plans |
| `nutrition-service` | - | Microservice for nutrition tracking |
| `notification-service` | - | Microservice for sending notifications |
| `recommendation-service` | - | Microservice for AI recommendations |

**Key Configuration:**
- All services share a common network: `fitness-network`
- All downstream services depend on `eureka-server` being healthy before starting
- Health checks ensure proper startup order

**Startup Command:**
```bash
docker-compose up -d
```

**Startup Order:**
```
1. eureka-server (starts first)
2. api-gateway (waits for eureka-server)
3. All other services (wait for eureka-server)
```

---

## 7. Architecture Overview

### 7.1 Role in Microservices Ecosystem

```
┌─────────────────────────────────────────────────────────┐
│                   Eureka Server                         │
│                   (Port: 8761)                          │
│                                                         │
│  - Service Registry                                     │
│  - Service Discovery                                    │
│  - Health Monitoring (via heartbeats)                   │
│  - Load Balancing Support                               │
└─────────────────────────────────────────────────────────┘
         ▲              ▲              ▲
         │              │              │
    Register       Register       Register
         │              │              │
┌────────┴────┐  ┌──────┴──────┐  ┌───┴──────────────┐
│   Trains    │  │  Training   │  │    Nutrition     │
│   Service   │  │   Service   │  │     Service      │
└─────────────┘  └─────────────┘  └──────────────────┘

┌─────────────────┐
│    API Gateway  │
│   (Port: 8075)  │
│                 │
│ Discovers all   │
│ services via    │
│ Eureka          │
└─────────────────┘
```

### 7.2 Service Discovery Flow

1. **Registration:** When a microservice starts, it registers itself with the Eureka Server
2. **Heartbeat:** Each service sends heartbeats every 30 seconds to indicate it's alive
3. **Discovery:** API Gateway and other services query Eureka to find available service instances
4. **Load Balancing:** Clients can use Ribbon or Spring Cloud LoadBalancer to distribute requests across instances
5. **Deregistration:** If a service stops sending heartbeats (90 seconds), Eureka removes it from the registry

### 7.3 Self-Preservation Mode

**Current Setting:** `eureka.server.enable-self-preservation: false`

Self-preservation mode is a safety feature that:
- Activates when Eureka detects a high percentage of failed heartbeats
- Prevents mass deregistration during network partitions
- Logs a warning: "THE SELF PRESERVATION MODE IS ON"

**Why Disabled:** For development/testing environments, it's useful to immediately see which services are down rather than keeping stale entries.

---

## 8. Common Operations

### 8.1 Starting the Server

**Via Maven:**
```bash
mvn spring-boot:run
```

**Via JAR:**
```bash
mvn clean package -DskipTests
java -jar target/eureka-server-0.0.1-SNAPSHOT.jar
```

**Via Docker:**
```bash
docker build -t eureka-server .
docker run -p 8761:8761 eureka-server
```

### 8.2 Running in Cluster Mode

**Terminal 1 (Peer 1):**
```bash
java -jar target/eureka-server-0.0.1-SNAPSHOT.jar --spring.profiles.active=peer1
```

**Terminal 2 (Peer 2):**
```bash
java -jar target/eureka-server-0.0.1-SNAPSHOT.jar --spring.profiles.active=peer2
```

### 8.3 Verifying Server Status

**Web Dashboard:**
```
http://localhost:8761/
```

**REST API:**
```bash
curl http://localhost:8761/eureka/apps
```

**Health Check:**
```bash
curl http://localhost:8761/actuator/health
```

### 8.4 Registering a Service Manually

```bash
curl -X POST http://localhost:8761/eureka/apps/MY-SERVICE \
  -H "Content-Type: application/xml" \
  -d '<instance>
        <hostName>localhost</hostName>
        <port enabled="true">8080</port>
        <vipAddress>my-service</vipAddress>
      </instance>'
```

### 8.5 Querying Registered Services

```bash
# Get all applications
curl http://localhost:8761/eureka/apps

# Get specific application
curl http://localhost:8761/eureka/apps/TRAINING-SERVICE

# Get specific instance
curl http://localhost:8761/eureka/apps/TRAINING-SERVICE/localhost:training-service:8080
```

---

## 9. Troubleshooting

### 9.1 Common Issues

| Issue | Solution |
|---|---|
| **Eureka Server won't start** | Check if port 8761 is already in use. Run `netstat -ano | findstr :8761` on Windows. |
| **Services can't register** | Verify `eureka.client.service-url.defaultZone` is correct in client configurations. |
| **Instances show as DOWN** | Check that the service's heartbeat is working and network connectivity exists. |
| **Self-preservation warnings** | This is normal in dev when services stop. Set `enable-self-preservation: false` to suppress. |

### 9.2 Useful Log Messages

| Log Message | Meaning |
|---|---|
| `Started EurekaServer in X seconds` | Server started successfully |
| `Registered instance MY-SERVICE` | A new service has registered |
| `Unregistering instance MY-SERVICE` | A service has been removed |
| `Renewal threshold is X` | Expected number of heartbeats per minute |
| `Self-preservation mode is ON` | Eureka is protecting against false deregistrations |

---

## 10. Project Structure

```
eureka-server/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/eurekaserver/
│   │   │       └── EurekaServerApplication.java    # Main application (1 method: main)
│   │   └── resources/
│   │       ├── application.yml                     # Main configuration
│   │       ├── application-peer1.yml               # Peer 1 profile
│   │       └── application-peer2.yml               # Peer 2 profile
│   └── test/
│       └── java/
│           └── com/example/eurekaserver/
│               └── EurekaServerApplicationTests.java  # Test (1 method: contextLoads)
├── target/                                        # Build output
├── pom.xml                                        # Maven configuration
├── Dockerfile                                     # Docker image definition
├── docker-compose.yml                             # Multi-service orchestration
├── README.md                                      # Project readme
└── SETUP.md                                       # Setup instructions
```

---

## 11. Method Summary Table

| # | Class | Method | Signature | Purpose |
|---|---|---|---|---|
| 1 | `EurekaServerApplication` | `main` | `public static void main(String[] args)` | Entry point. Bootstraps Spring Boot application and starts Eureka Server. |
| 2 | `EurekaServerApplicationTests` | `contextLoads` | `void contextLoads()` | Smoke test. Verifies Spring context loads successfully. |

**Total Custom Methods:** 2  
**Total Custom Classes:** 2  
**Built-in Eureka Endpoints:** 10+ REST API endpoints  
**Actuator Endpoints:** 8+ monitoring endpoints

---

## 12. Version Information

| Component | Version |
|---|---|
| Spring Boot | 3.4.2 |
| Spring Cloud | 2024.0.0 |
| Java | 21 |
| Netflix Eureka Server | Latest (via Spring Cloud BOM) |

---

*Documentation generated for the Fitness Microservices Platform - Eureka Server*
