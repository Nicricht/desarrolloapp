# Seguros BPO: ejecutar los cuatro microservicios con Docker en Duoc

Este repositorio contenía únicamente `backend-seguros-bpo-main.zip`. Docker descomprime el ZIP **durante la construcción de las imágenes**; no es necesario extraerlo manualmente. Los cuatro servicios usan Spring Boot 4.1.2, Java 21 y MongoDB. La base MongoDB es **local al entorno Docker**, no Atlas.

## Requisitos del computador

- Docker Desktop con motor Linux activo y Docker Compose v2.
- Permiso para usar Docker Desktop / WSL2 (en los computadores del instituto podría estar bloqueado).
- Internet durante la primera construcción para descargar imágenes y dependencias Maven.
- Puertos locales 8081, 8082, 8083, 8084 disponibles.

No se necesita instalar Java, Maven o MongoDB en Windows.

## Arranque

Abre PowerShell en la raíz del repositorio y ejecuta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\iniciar-duoc.ps1
```

En el primer arranque, el script crea el archivo local `.env` con un usuario y una contraseña aleatoria. Ese archivo está excluido de Git. Luego ejecuta `docker compose up --build -d --wait` y muestra los contenedores. El primer build descarga y compila Java 21 / Spring Boot; puede requerir recursos y tiempo.

Verificar todas las API:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\probar-duoc.ps1
```

Detener sin eliminar los datos:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\detener-duoc.ps1
```

## Direcciones

| Servicio | URL local de prueba |
| --- | --- |
| Roles | http://localhost:8081/api/roles |
| Usuarios | http://localhost:8082/api/usuarios |
| Catálogos | http://localhost:8083/api/companias |
| Siniestros | http://localhost:8084/api/siniestros?sinAsignar=true |

En el emulador Android, reemplaza `localhost` por `10.0.2.2`. El frontend todavía debe adaptar las rutas y modelos a estas cuatro API.

## Diagnóstico

```powershell
docker info
docker compose config
docker compose ps
docker compose logs --tail=100
docker compose logs -f siniestros-service
```

Si Docker informa error `dockerDesktopLinuxEngine`, inicia Docker Desktop y habilita el motor Linux. Si no está disponible en un computador de Duoc, solicita habilitación o ejecuta el sistema en un equipo donde Docker funcione.

Si el puerto 8081 a 8084 está ocupado, detén el servicio que lo utiliza. No expongas los puertos del backend a Internet: este sistema usa cuentas académicas y no tiene autenticación de producción.

Los contenedores guardan tres volúmenes: `mongodb-data`, `avatares-data` y `evidencias-data`. No uses `docker compose down -v` salvo que quieras borrar los datos locales.

## Seguridad y limitaciones

- Las propiedades del código archivado incluían una credencial MongoDB Atlas. **Esa credencial debe revocarse y el ZIP público debe sanearse**. Docker elimina esas líneas de propiedades **antes de compilar**, por lo que los JAR generados no llevan esa URI histórica. Esto no elimina la credencial del ZIP ni del historial Git.
- El MongoDB de este Compose usa una cuenta local creada por el script. Su puerto no se expone al equipo ni a Internet.
- Los cuatro servicios se inician en orden mediante dependencias y controles de salud (salida TCP / ping MongoDB).
- `docker compose --wait` comprueba que los procesos arrancan; **no certifica los flujos completos de negocio**. Por eso se suministra una prueba REST básica y un workflow de CI.
- Las credenciales demo de los usuarios y el HTTP local son exclusivamente para prácticas académicas.

## Estructura

```text
backend-seguros-bpo-main.zip   <- código original
docker/Dockerfile              <- extracción del ZIP y compilación multi-stage
compose.yaml                   <- MongoDB + Roles + Usuarios + Catálogos + Siniestros
scripts/iniciar-duoc.ps1       <- genera .env y ejecuta Compose
scripts/probar-duoc.ps1        <- comprueba cuatro API
scripts/detener-duoc.ps1       <- apaga sin borrar datos
.github/workflows/docker-duoc.yml <- CI real de arranque y smoke
```
