# Eureka Server - Service Discovery Setup

## ✅ Completed Configuration

### 1. **Application Properties** (`src/main/resources/application.yml`)
- Server port: 8761
- Eureka Server configured as standalone (not registering itself)
- Self-preservation mode disabled for development
- Actuator endpoints enabled for health checks

### 2. **Dependencies** (`pom.xml`)
- ✅ spring-cloud-starter-netflix-eureka-server
- ✅ spring-boot-starter-actuator
- ❌ Removed: eureka-client (not needed for server)

### 3. **Main Application** (`EurekaServerApplication.java`)
- ✅ @EnableEurekaServer annotation
- ✅ Spring Boot application

### 4. **Docker Configuration** (`docker-compose.yml`)
- Eureka Server on port 8761
- Health check configuration
- Network setup for microservices communication
- All services configured to connect to Eureka

### 5. **Dockerfile**
- Java 21 JRE Alpine base image
- Exposes port 8761
- Ready for containerization

### 6. **.gitignore**
- Properly configured for Maven/Spring Boot projects

## 🚀 How to Run

### Local Development:
```bash
# Build
mvnw.cmd clean package -DskipTests

# Run
mvnw.cmd spring-boot:run
```

### Docker:
```bash
# Build and run all services
docker-compose up --build

# Run only Eureka Server
docker-compose up eureka-server

# Run in background
docker-compose up -d eureka-server
```

## 📊 Access Points

- **Eureka Dashboard**: http://localhost:8761
- **Health Check**: http://localhost:8761/actuator/health
- **Service Registry**: http://localhost:8761/eureka/

## 🔧 Configuration for Client Services

Add to your microservices' `application.yml`:
```yaml
eureka:
  client:
    service-url:
      defaultZone: http://eureka-server:8761/eureka/
```

Or environment variable:
```bash
EUREKA_SERVER_URL=http://eureka-server:8761/eureka/
```

## 📝 Git Commands to Push

```bash
# Check status
git status

# Add all changes
git add .

# Commit
git commit -m "feat: configure Eureka Server for Service Discovery

- Add application.yml with standalone Eureka configuration
- Remove eureka-client dependency (server only)
- Configure Docker and docker-compose with health checks
- Setup actuator endpoints for monitoring
- Configure network for microservices communication"

# Push to remote
git push origin main
# or your branch name
git push origin <your-branch>
```

## 🏗️ Microservices Architecture

Your setup includes:
1. **Eureka Server** (8761) - Service Registry
2. **API Gateway** (8075) - Routing & Load Balancing
3. **Trains Service** - Training sessions management
4. **Training Service** - Workouts tracking
5. **Nutrition Service** - Diet management
6. **Notification Service** - Alerts & notifications
7. **Recommendation Service** - Personalized suggestions

All services are configured to register with Eureka Server.
