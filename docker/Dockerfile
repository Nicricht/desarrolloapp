# Cada build extrae el ZIP original y compila el microservicio solicitado.
# No modifica el archivo histórico; elimina la conexión Atlas del JAR generado.
FROM alpine:3.21 AS source
RUN apk add --no-cache unzip
WORKDIR /source
COPY backend-seguros-bpo-main.zip /tmp/backend.zip
RUN unzip -q /tmp/backend.zip -d /source \
    && test -f /source/backend-seguros-bpo-main/roles-service/pom.xml \
    && find /source/backend-seguros-bpo-main -name application.properties -exec sed -i '/^spring\.mongodb\.uri=/d' {} \;

FROM maven:3.9-eclipse-temurin-21 AS build
ARG SERVICE
WORKDIR /workspace
COPY --from=source /source/backend-seguros-bpo-main/ ./
RUN case "$SERVICE" in roles-service|usuarios-service|catalogos-service|siniestros-service) ;; *) exit 2;; esac \
    && mvn -B -ntp -f "$SERVICE/pom.xml" clean verify \
    && test -s "$SERVICE/target/$SERVICE-1.0.0.jar"

FROM eclipse-temurin:21-jre-jammy
ARG SERVICE
WORKDIR /app
RUN groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid 10001 --no-create-home app \
    && mkdir -p /app/uploads/avatares /app/uploads/evidencias \
    && chown -R 10001:10001 /app
COPY --from=build --chown=10001:10001 /workspace/${SERVICE}/target/${SERVICE}-1.0.0.jar /app/app.jar
USER 10001:10001
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=65.0 -Dfile.encoding=UTF-8 -Duser.timezone=America/Santiago"
EXPOSE 8081 8082 8083 8084
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
