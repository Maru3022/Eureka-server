# Eureka Server

Service discovery registry fitness-платформы на базе Netflix Eureka. Все остальные сервисы платформы регистрируются здесь и через него находят друг друга — без него Spring Cloud-клиенты не смогут резолвить адреса соседних сервисов по имени. Поддерживает как одиночный режим, так и отказоустойчивый peer-to-peer кластер из двух нод.

![Java](https://img.shields.io/badge/Java-21-orange?logo=openjdk)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.2-brightgreen?logo=springboot)
![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2024.0.0%20Netflix%20Eureka-6DB33F?logo=spring)
![Docker](https://img.shields.io/badge/Docker-alpine-2496ED?logo=docker)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Kustomize-326CE5?logo=kubernetes)

## Что делает сервис

- Поднимает Netflix Eureka Server (`@EnableEurekaServer`) — реестр сервисов, к которому регистрируются все остальные компоненты платформы (Spring Cloud Eureka Client).
- Поддерживает два режима развёртывания через Kustomize-оверлеи: `single-node` (одна реплика, минимальная конфигурация для dev/staging) и `peer-cluster` (две реплики-пира, реплицирующие реестр друг другу, для продакшена).
- В peer-режиме каждая нода регистрируется как клиент другой (`register-with-eureka=true`, `fetch-registry=true`, `defaultZone` указывает на пира), что даёт отказоустойчивость: если одна нода падает, реестр остаётся доступен через вторую.
- Не содержит доменной бизнес-логики, контроллеров или БД — сервис намеренно простой, основная инженерная работа здесь сосредоточена в эксплуатационном контуре: Kubernetes-манифесты, health-пробы, CI с валидацией манифестов.
- Отдаёт собственный веб-дашборд Eureka (кастомизированные Freemarker-шаблоны `templates/eureka/`) для визуального просмотра реестра сервисов.
- Экспонирует liveness/readiness пробы и `/actuator/info` с метаданными о платформе.

## Архитектура

```text
                     +------------------------------+
                     |   single-node (dev/staging)   |
                     |   eureka-server : 8761         |
                     +------------------------------+

                     +-------------------- peer-cluster (prod) --------------------+
                     |                                                              |
                     |   +------------------+   defaultZone    +------------------+ |
                     |   |  eureka-peer1     |<---------------->|  eureka-peer2     | |
                     |   |  :8761            |  репликация      |  :8761 (внутр.)   | |
                     |   |  profile: peer1   |  реестра          |  profile: peer2   | |
                     |   +--------+----------+                  +---------+--------+ |
                     |            |                                        |          |
                     |            +-------------- eureka-registry ---------+          |
                     |                  (Service, агрегирует оба пира)                 |
                     +---------------------------------------------------------------+
                                              ^
                                              |  register-with-eureka / fetch-registry
                  +----------------+----------------+----------------+----------------+
                  |                |                |                |
         Training_Notification  Saga-Orchestrator  Training-Nutrition  Trains-Service
              (8086)                 (8090)              (8083)            (8035)
```

## Архитектурные решения

### 1. Раздельные Kustomize-оверлеи single-node / peer-cluster вместо одного "универсального" манифеста

Вместо набора условных флагов в одном деплойменте репозиторий хранит два полностью независимых набора манифестов (`k8s/single-node/`, `k8s/peer-cluster/`), каждый со своим `Namespace`, `NetworkPolicy`, `PodDisruptionBudget` и стратегией Service. В CI выбор оверлея для деплоя делается через переменную окружения `K8S_OVERLAY` (по умолчанию `single-node`), а оба варианта рендерятся и валидируются на каждый push независимо от того, какой из них реально задеплоится — это снижает риск, что peer-cluster-конфигурация "незаметно сломается", пока в проде используется single-node.

### 2. Peer-to-peer регистрация вместо master-replica

Конфигурация двух пиров (`application-peer1.yml` / `application-peer2.yml`) делает каждую ноду одновременно и Eureka-сервером, и Eureka-клиентом другой ноды: `eureka.client.service-url.defaultZone` peer1 указывает на peer2 и наоборот, `register-with-eureka` и `fetch-registry` включены на обеих сторонах. В Kubernetes-манифестах (`deployment-peer1.yaml`/`deployment-peer2.yaml`) `EUREKA_INSTANCE_HOSTNAME` и `EUREKA_DEFAULT_ZONE` строятся на основе DNS внутри кластера (`eureka-peerN.eureka.svc.cluster.local`), а отдельный сервис `eureka-registry` агрегирует обе ноды под одним стабильным DNS-именем для клиентов платформы — это классическая для Eureka схема симметричной репликации без выделенного "мастера", единая точка отказа исключена на уровне самого реестра.

### 3. Self-preservation выключен в dev-профиле, включён по умолчанию в peer-конфиге

В базовом `application.yml` (single-node/локальный запуск) `eureka.server.enable-self-preservation=false` и `eviction-interval-timer-in-ms=5000` — это намеренное решение для быстрой обратной связи в деве: упавший инстанс выселяется из реестра почти мгновенно, без задержек self-preservation mode. В peer-конфигурации деплойментов `EUREKA_SELF_PRESERVATION=true` — для прод-кластера это более безопасное поведение, защищающее от массового ложного выселения здоровых инстансов при кратковременных сетевых проблемах между нодами.

## Технологический стек

| Категория | Технологии |
|---|---|
| Язык / платформа | Java 21, Spring Boot 3.4.2, Spring Cloud 2024.0.0 |
| Service discovery | Netflix Eureka Server (`spring-cloud-starter-netflix-eureka-server`) |
| Observability | Spring Boot Actuator, liveness/readiness probes |
| CI/CD | GitHub Actions: сборка и тесты, валидация Kustomize-манифестов кастомным Python-скриптом (`scripts/validate_k8s.py`) с проверкой ожидаемого количества ресурсов по типам, Docker build & push в GHCR, рендеринг манифестов как артефактов, условный деплой по наличию `KUBE_CONFIG_DATA` с выбором оверлея через `K8S_OVERLAY` |
| Контейнеризация | Docker (`eclipse-temurin:21-jre-alpine`, non-root пользователь `spring`) |
| Деплой | Kubernetes + Kustomize: `single-node` (Namespace, ConfigMap, Deployment, Service, Ingress, PDB, NetworkPolicy) и `peer-cluster` (Namespace, 2× Deployment, 3× Service, Ingress, PDB, NetworkPolicy) |

## Локальный запуск

### Зависимости

JDK 21+, Maven Wrapper.

### Сборка и тесты

```bash
./mvnw clean verify
```

### Запуск (одна нода)

```bash
./mvnw spring-boot:run
```

Дашборд реестра — `http://localhost:8761`.

### Запуск peer-кластера локально

```bash
SPRING_PROFILES_ACTIVE=peer1 ./mvnw spring-boot:run   # порт 8761
SPRING_PROFILES_ACTIVE=peer2 ./mvnw spring-boot:run   # порт 8762
```

### Переменные окружения

```bash
SERVER_PORT=8761
EUREKA_INSTANCE_HOSTNAME=peer1
EUREKA_PREFER_IP_ADDRESS=false
EUREKA_REGISTER_WITH_EUREKA=true
EUREKA_FETCH_REGISTRY=true
EUREKA_DEFAULT_ZONE=http://peer2:8762/eureka/
```

## Связанные репозитории

- [Saga-Orchestrator](https://github.com/Maru3022/Saga-Orchestrator) — регистрируется в этом реестре как Eureka-клиент
- [Training-Nutrition](https://github.com/Maru3022/Training-Nutrition) — регистрируется в этом реестре как Eureka-клиент
- [Training_Notification](https://github.com/Maru3022/Training_Notification) — сосед по платформе
- [Trains-Service](https://github.com/Maru3022/Trains-Service) — сосед по платформе
