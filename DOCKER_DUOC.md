# Seguros BPO: ejecutar los cuatro microservicios en computadores de Duoc

**Código fuente visible en GitHub**: cada microservicio tiene su propia carpeta, con Java, `pom.xml`, configuración y pruebas.

| Carpeta | Función | Puerto |
| --- | --- | --- |
| `roles-service/` | Roles | 8081 |
| `usuarios-service/` | Usuarios, login y avatares | 8082 |
| `catalogos-service/` | Compañías y tipos de siniestro | 8083 |
| `siniestros-service/` | Siniestros, gestiones y evidencias | 8084 |

`docker/Dockerfile` compila cada carpeta directamente, usando `SERVICE` para seleccionar el módulo; `compose.yaml` crea los cuatro servicios, más MongoDB 7 local. No hay que descargar ni extraer un ZIP dentro de Docker.

## Requisitos

- Docker Desktop con motor Linux iniciado y Docker Compose v2.
- Permisos para ejecutar Docker Desktop / WSL2 en el equipo de Duoc.
- Internet la primera vez para descargar las imágenes y las dependencias de Maven.
- Puertos locales 8081–8084 libres.

No necesitas instalar Java, Maven ni MongoDB en Windows.

## Arrancar en PowerShell

En la raíz del repositorio, ejecuta:

```powershell
docker compose up --build -d --wait
```

Sin crear `.env`, Compose inicia los cinco contenedores con credenciales predeterminadas **solo para demostración local**. MongoDB no publica su puerto y las cuatro API escuchan únicamente en `127.0.0.1` del computador. No uses esta configuración por defecto en un servidor o red pública. Si necesitas contraseñas distintas, copia `.env.example` a `.env` y reemplaza su contraseña de ejemplo por una fuerte; `.env` está excluido de Git.

El script alternativo `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\iniciar-duoc.ps1` también funciona sin crear `.env` y comprueba que Docker Engine esté activo.

Comprobar las cuatro API REST:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\probar-duoc.ps1
```

Detener sin perder las bases de datos ni los archivos adjuntos:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\detener-duoc.ps1
```

## URLs de pruebas

- Roles: http://localhost:8081/api/roles
- Usuarios: http://localhost:8082/api/usuarios
- Catálogos: http://localhost:8083/api/companias
- Siniestros: http://localhost:8084/api/siniestros?sinAsignar=true

La aplicación Android todavía requiere adaptar su contrato Retrofit para este backend. En un emulador Android, `10.0.2.2` representa el host, pero las rutas también deben coincidir con las implementadas aquí.

## Diagnóstico

```powershell
docker info
docker compose config
docker compose ps
docker compose logs --tail=100
docker compose logs -f siniestros-service
```

Si aparece `dockerDesktopLinuxEngine`, inicia Docker Desktop y usa contenedores Linux. Si WSL2 está bloqueado en un computador del instituto, solicita habilitación o utiliza otro equipo autorizado.

Los volúmenes `mongodb-data`, `avatares-data` y `evidencias-data` son persistentes. No utilices `docker compose down -v` si quieres conservarlos.

## Seguridad y límites

- La conexión Atlas de los antiguos `application.properties` se ha eliminado de los cuatro servicios visibles. La conexión de Docker usa la variable `SPRING_MONGODB_URI` con un servidor MongoDB local. Por defecto emplea credenciales conocidas de demostración; puedes anularlas mediante `.env`.
- El ZIP antiguo contiene una credencial que **debe revocarse por su propietario**; aunque lo retiramos de la rama visible, **sigue existiendo en versiones antiguas del historial Git**. Ver el Issue #2.
- Los puertos se publican únicamente en `127.0.0.1`. La aplicación es una demostración académica y no incorpora seguridad de producción.
- El workflow `docker-duoc.yml` realiza build y smoke REST. Una prueba verde no sustituye validar todos los flujos de negocio, permisos, persistencia y la integración con Android.
