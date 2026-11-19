# Compilar directamente desde las cuatro carpetas visibles en GitHub.
FROM maven:3.9-eclipse-temurin-21 AS build
ARG SERVICE
WORKDIR /workspace
COPY roles-service/ ./roles-service/
COPY usuarios-service/ ./usuarios-service/
COPY catalogos-service/ ./catalogos-service/
COPY siniestros-service/ ./siniestros-service/
RUN case "$SERVICE" in roles-service|usuarios-service|catalogos-service|siniestros-service) ;; *) exit 2;; esac \
    && if grep -R -q -E 'mongodb[+]srv://|abaylas_db_user' \
         roles-service usuarios-service catalogos-service siniestros-service; then \
         echo 'ERROR: fuente con URI de Atlas; detener construcción.' >&2; exit 3; \
       fi \
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
