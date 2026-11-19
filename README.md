# Seguros BPO: cuatro microservicios con Docker y MongoDB Atlas original

Las carpetas `roles-service/`, `usuarios-service/`, `catalogos-service/` y `siniestros-service/` contienen el código Java 21 y las pruebas Maven.

**Docker no crea una base nueva para la aplicación.** La configuración principal (`compose.yaml`) conecta los cuatro servicios a las cuatro bases **MongoDB Atlas originales**. No modifica contraseñas, datos, rutas REST ni modelos.

## Primera ejecución en Windows / Duoc

1. Inicia Docker Desktop (modo Linux).
2. Conserva tu ZIP **original** `backend-seguros-bpo-main.zip` en Descargas. El ZIP original contiene las URI Atlas preexistentes, no lo publiques nuevamente.
3. Dentro del repositorio ejecuta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\iniciar-duoc.ps1
```

El script localiza el ZIP original en la carpeta del repositorio o en Descargas y copia sus **cuatro conexiones existentes** al archivo privado `.env`. Si no encuentra el ZIP pide su ruta, sin mostrar contraseñas. Después compila y levanta **solo los cuatro contenedores Java**, conectados a Atlas.

En las siguientes ejecuciones, si ya tienes `.env`, puedes hacer directamente:

```powershell
docker compose up --build -d --wait
```

Verificar:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\probar-duoc.ps1
```

Detener:

```powershell
docker compose down
```

## Requisitos y limitaciones

- Docker Desktop / Compose v2 y permisos para ejecutar su motor Linux/WSL2.
- Conexión a Internet, DNS SRV de Atlas y acceso de red autorizado desde el computador de Duoc.
- El administrador de Atlas debe tener permitido el acceso de red desde el computador. Este proyecto no modifica las reglas de Atlas.
- Puertos 8081, 8082, 8083 y 8084 disponibles. Solo se exponen a `127.0.0.1`.
- No se necesita instalar Java, Maven ni MongoDB en Windows.
- Los avatares y evidencias se conservan en volúmenes Docker; sin embargo, estos archivos **no se comparten automáticamente** entre computadores.
- No se afirma que la aplicación Android esté integrada: Retrofit necesita usar las rutas correctas y las URLs del host.

**Seguridad:** el ZIP histórico contiene credenciales y sigue en el historial antiguo de GitHub. Este cambio no las rota ni las vuelve a publicar. No compartas `.env` ni el ZIP original. Si usas un computador público, elimina tu archivo `.env` y los contenedores al terminar; revisa también el historial local de comandos.

Las pruebas GitHub Actions usan `compose.ci.yaml` y un MongoDB descartable exclusivo del CI, porque no deben utilizar las credenciales reales de Atlas. Por eso la CI valida la compilación y el funcionamiento de las API, pero **no puede demostrar conectividad real a Atlas desde Duoc**.
