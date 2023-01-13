#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

pkill -9 -f spring-petclinic || echo "Failed to kill any apps"

docker-compose kill || echo "No docker containers are running"

echo "Running infra"
docker-compose up -d grafana-server prometheus-server tracing-server

echo "Running apps"
mkdir -p target
nohup java -javaagent:/root/spring-petclinic-microservices/scripts/opentelemetry-javaagent.jar \
-Dotel.resource.attributes="service.name=config_server,service.version=1.1,deployment.environment=production" \
-Dotel.exporter.otlp.endpoint="https://abc40654749f4311bf845a8f8e4461d0.apm.ap-southeast-1.aws.cloud.es.io:443" \
-Dotel.exporter.otlp.headers="Authorization=Bearer YldnKGU3uvzjQkY4Of" \
-Dotel.metrics.exporter="otlp" \
-Dotel.logs.exporter="otlp" \
-Dotel.traces.exporter="otlp" \
-jar spring-petclinic-config-server/target/*.jar --server.port=8888 --spring.profiles.active=chaos-monkey > target/config-server.log 2>&1 &
echo "Waiting for config server to start"
sleep 20
nohup java -javaagent:/root/spring-petclinic-microservices/scripts/opentelemetry-javaagent.jar \
-Dotel.resource.attributes="service.name=discovery_server,service.version=1.1,deployment.environment=production" \
-Dotel.exporter.otlp.endpoint="https://abc40654749f4311bf845a8f8e4461d0.apm.ap-southeast-1.aws.cloud.es.io:443" \
-Dotel.exporter.otlp.headers="Authorization=Bearer YldnKGU3uvzjQkY4Of" \
-Dotel.metrics.exporter="otlp" \
-Dotel.logs.exporter="otlp" \
-Dotel.traces.exporter="otlp" \
-jar spring-petclinic-discovery-server/target/*.jar --server.port=8761 --spring.profiles.active=chaos-monkey > target/discovery-server.log 2>&1 &
echo "Waiting for discovery server to start"
sleep 20
nohup java javaagent:/root/spring-petclinic-microservices/scripts/opentelemetry-javaagent.jar \
-Dotel.resource.attributes="service.name=customer_service,service.version=1.1,deployment.environment=production" \
-Dotel.exporter.otlp.endpoint="https://abc40654749f4311bf845a8f8e4461d0.apm.ap-southeast-1.aws.cloud.es.io:443" \
-Dotel.exporter.otlp.headers="Authorization=Bearer YldnKGU3uvzjQkY4Of" \
-Dotel.metrics.exporter="otlp" \
-Dotel.logs.exporter="otlp" \
-Dotel.traces.exporter="otlp" \
-jar spring-petclinic-customers-service/target/*.jar --server.port=8081 --spring.profiles.active=chaos-monkey > target/customers-service.log 2>&1 &
nohup java -javaagent:/root/spring-petclinic-microservices/scripts/opentelemetry-javaagent.jar \
-Dotel.resource.attributes="service.name=visit_service,service.version=1.1,deployment.environment=production" \
-Dotel.exporter.otlp.endpoint="https://abc40654749f4311bf845a8f8e4461d0.apm.ap-southeast-1.aws.cloud.es.io:443" \
-Dotel.exporter.otlp.headers="Authorization=Bearer YldnKGU3uvzjQkY4Of" \
-Dotel.metrics.exporter="otlp" \
-Dotel.logs.exporter="otlp" \
-Dotel.traces.exporter="otlp" \
-jar spring-petclinic-visits-service/target/*.jar --server.port=8082 --spring.profiles.active=chaos-monkey > target/visits-service.log 2>&1 &
nohup java -javaagent:/root/spring-petclinic-microservices/scripts/opentelemetry-javaagent.jar \
-Dotel.resource.attributes="service.name=vet_service,service.version=1.1,deployment.environment=production" \
-Dotel.exporter.otlp.endpoint="https://abc40654749f4311bf845a8f8e4461d0.apm.ap-southeast-1.aws.cloud.es.io:443" \
-Dotel.exporter.otlp.headers="Authorization=Bearer YldnKGU3uvzjQkY4Of" \
-Dotel.metrics.exporter="otlp" \
-Dotel.logs.exporter="otlp" \
-Dotel.traces.exporter="otlp" \
-jar spring-petclinic-vets-service/target/*.jar --server.port=8083 --spring.profiles.active=chaos-monkey > target/vets-service.log 2>&1 &
nohup java -javaagent:/root/spring-petclinic-microservices/scripts/opentelemetry-javaagent.jar \
-Dotel.resource.attributes="service.name=api_gateway,service.version=1.1,deployment.environment=production" \
-Dotel.exporter.otlp.endpoint="https://abc40654749f4311bf845a8f8e4461d0.apm.ap-southeast-1.aws.cloud.es.io:443" \
-Dotel.exporter.otlp.headers="Authorization=Bearer YldnKGU3uvzjQkY4Of" \
-Dotel.metrics.exporter="otlp" \
-Dotel.logs.exporter="otlp" \
-Dotel.traces.exporter="otlp" \
-jar spring-petclinic-api-gateway/target/*.jar --server.port=8080 --spring.profiles.active=chaos-monkey > target/gateway-service.log 2>&1 &
nohup java -javaagent:/root/spring-petclinic-microservices/scripts/opentelemetry-javaagent.jar \
-Dotel.resource.attributes="service.name=admin_service,service.version=1.1,deployment.environment=production" \
-Dotel.exporter.otlp.endpoint="https://abc40654749f4311bf845a8f8e4461d0.apm.ap-southeast-1.aws.cloud.es.io:443" \
-Dotel.exporter.otlp.headers="Authorization=Bearer YldnKGU3uvzjQkY4Of" \
-Dotel.metrics.exporter="otlp" \
-Dotel.logs.exporter="otlp" \
-Dotel.traces.exporter="otlp" \
-jar spring-petclinic-admin-server/target/*.jar --server.port=9090 --spring.profiles.active=chaos-monkey > target/admin-server.log 2>&1 &
echo "Waiting for apps to start"
sleep 60

