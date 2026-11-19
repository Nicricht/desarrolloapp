# Seguros BPO: backend Java

Cuatro microservicios Spring Boot (Java 21) y MongoDB local, preparados para iniciar con **Docker Compose** desde un computador Windows con Docker Desktop.

## Estructura

- [roles-service](roles-service) — roles y permisos académicos
- [usuarios-service](usuarios-service) — usuarios, cuentas y avatar
- [catalogos-service](catalogos-service) — catálogos de compañías y siniestros
- [siniestros-service](siniestros-service) — registro, consulta, gestiones y documentos

Los cuatro servicios están descomprimidos y versionados como código fuente. Docker compila directamente estas carpetas.

## Inicio rápido

```powershell
git clone https://github.com/Nicricht/desarrolloapp.git
cd desarrolloapp
docker compose up --build -d --wait
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\probar-duoc.ps1
```

No necesitas crear un archivo `.env` para la demostracion local: Compose utiliza una cuenta MongoDB de prueba que solo funciona dentro de la red Docker. Si vas a guardar información importante o ejecutar el sistema fuera de tu equipo, define credenciales propias en `.env` y revisa la seguridad.

También puedes iniciar con `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\iniciar-duoc.ps1`.

Para detenerlos: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\detener-duoc.ps1`.

Consulta [DOCKER_DUOC.md](DOCKER_DUOC.md) para los requisitos, puertos, diagnósticos y limitaciones de seguridad.

**Nota:** son servicios de desarrollo local; la integración completa con Android todavía necesita adaptación y pruebas. La contraseña expuesta en el ZIP histórico debe revocarse.
