# 🏋️ Fitness Microservices Platform

A Spring Boot microservices application for fitness management, including training, nutrition, recommendations, and notifications — orchestrated via Docker Compose and service discovery with Eureka.

---

## 📐 Architecture

```
Client
  │
  ▼
API Gateway (port 8075)
  │
  ├──▶ Trains Service        /api/trains/**
  ├──▶ Training Service      /api/training/**
  ├──▶ Nutrition Service     /api/nutrition/**
  ├──▶ Notification Service  /api/notifications/**
  └──▶ Recommendation Service /api/recommendations/**

All services register with Eureka Server (port 8761)
```

---

## 🧩 Services

| Service | Container | Port | Description |
|---|---|---|---|
| Eureka Server | `eureka-server` | `8761` | Service registry & discovery |
| API Gateway | `api-gateway` | `8075` | Single entry point, load balancer |
| Trains Service | `trains-service` | — | Training plans management |
| Training Service | `training-service` | — | Workout session tracking |
| Nutrition Service | `nutrition-service` | — | Nutrition & diet management |
| Notification Service | `notification-service` | — | Training notifications |
| Recommendation Service | `recommendation-service` | — | Personalized recommendations |

---

## 🚀 Getting Started

### Prerequisites

- [Docker](https://www.docker.com/) & Docker Compose
- Java 17+
- Maven or Gradle (for local development)

### Run with Docker Compose

```bash
# Clone the repository
git clone <your-repo-url>
cd <project-folder>

# Build and start all services
docker-compose up --build

# Run in detached mode
docker-compose up --build -d
```

### Stop all services

```bash
docker-compose down
```

---

## 🔍 Service Discovery (Eureka)

Eureka Server is available at:

```
http://localhost:8761
```

All microservices automatically register themselves with Eureka on startup. The API Gateway uses Eureka to perform client-side load balancing (`lb://SERVICE-NAME`).

---

## 🌐 API Gateway

The API Gateway runs on port `8075` and routes requests to the appropriate microservice:

| Endpoint prefix | Routes to |
|---|---|
| `/api/trains/**` | `TRAINS-SERVICE` |
| `/api/training/**` | `TRAINING-SERVICE` |
| `/api/nutrition/**` | `NUTRITION-SERVICE` |
| `/api/notifications/**` | `NOTIFICATION-SERVICE` |
| `/api/recommendations/**` | `RECOMMENDATION-SERVICE` |

Example request:

```bash
curl http://localhost:8075/api/nutrition/foods
```

---

## ⚙️ Configuration

### API Gateway (`application.yml`)

```yaml
server:
  port: 8075

spring:
  application:
    name: API_Gateway
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_SERVER_URL:http://eureka-server:8761/eureka/}
  instance:
    prefer-ip-address: true
```

### Environment Variables

Each service accepts the following environment variable:

| Variable | Default | Description |
|---|---|---|
| `EUREKA_SERVER_URL` | `http://eureka-server:8761/eureka/` | Eureka registry URL |

---

## 🐳 Docker Network

All services communicate over a shared Docker bridge network called `fitness-network`. Services can reach each other by container name (e.g., `http://eureka-server:8761`).

---

## 🏥 Health Check

The Eureka Server has a health check configured:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8761/eureka/"]
  interval: 10s
  timeout: 5s
  retries: 10
```

All other services use `depends_on: condition: service_healthy` to wait for Eureka to be ready before starting.

---

## 📁 Project Structure

```
.
├── docker-compose.yml
├── eureka-server/
│   └── src/main/
│       ├── java/com/example/eurekaserver/EurekaServerApplication.java
│       └── resources/application.yml
├── API_Gateway/
│   └── src/main/resources/application.yml
├── Trains-Service/
├── Training-Servive/
├── Nutrition-Service/
├── Training_Notification/
└── Recommendation-Service/
```

---

## 🛠️ Tech Stack

- **Java 17+** — Core language
- **Spring Boot** — Microservice framework
- **Spring Cloud Netflix Eureka** — Service discovery
- **Spring Cloud Gateway** — API Gateway & routing
- **Docker & Docker Compose** — Containerization & orchestration
