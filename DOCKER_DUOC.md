# Guía Docker para computadores Duoc

La configuración principal del backend está en `compose.yaml` y utiliza **Atlas original** para las bases `segurosbpo_roles`, `segurosbpo_usuarios`, `segurosbpo_catalogos` y `segurosbpo_siniestros`.

## Primer arranque

```powershell
git clone https://github.com/Nicricht/desarrolloapp.git
cd desarrolloapp
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\iniciar-duoc.ps1
```

Guarda el ZIP **original del backend** en Descargas; el script importa las cuatro URI Atlas al archivo local `.env` sin cambiar claves ni bases. Si el ZIP no está en Descargas, te pide su ruta. No subas ese ZIP al repositorio.

Luego ejecuta las pruebas de las cuatro API:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\probar-duoc.ps1
```

## Arranques posteriores

```powershell
docker compose up --build -d --wait
```

`docker compose down` detiene los servicios sin borrar el almacenamiento de avatares y evidencias. MongoDB Atlas permanece ajeno a la operación de Docker Compose.

## Qué hay y qué no hay

| Componente | Puerto | Base de datos |
|---|---|---|
| roles-service | 8081 | Atlas: segurosbpo_roles |
| usuarios-service | 8082 | Atlas: segurosbpo_usuarios |
| catalogos-service | 8083 | Atlas: segurosbpo_catalogos |
| siniestros-service | 8084 | Atlas: segurosbpo_siniestros |

- **No hay contenedor MongoDB en el Compose principal**.
- MongoDB local solo existe en `compose.ci.yaml` para los tests de GitHub Actions. No debe utilizarse para prácticas con datos compartidos.
- Los servicios internos se comunican mediante `roles-service:8081`, `usuarios-service:8082` y `catalogos-service:8083`, aunque las API publicadas siguen en `localhost:8081..8084`.
- El código Java (endpoints, modelos y lógica) no se modifica.
- No es necesario Java ni Maven en Windows: la imagen se compila con Java 21 dentro de Docker.

## Problemas habituales

```powershell
docker info
docker compose ps
docker compose logs --tail=80
```

- Si Docker Engine no existe, abre Docker Desktop en modo Linux.
- Si las dependencias Maven fallan, confirma acceso a Internet.
- Si Atlas no responde, comprueba DNS SRV, acceso a Internet y las políticas de red permitidas. **No cambies el acceso ni las contraseñas de Atlas sin autorización.**
- Si la conexión Atlas funciona pero Android no, verifica URLs Retrofit. `10.0.2.2` es el host para emulador Android; para teléfonos físicos la IP/red y políticas deben revisarse.

## Privacidad

`.env` almacena las URI originales en tu computador, sin Git. Cuídalo especialmente en equipos compartidos: evita dejarlo guardado allí después de la práctica. Las credenciales originales siguen siendo las mismas. El archivo ZIP histórico debe mantenerse privado porque contenía secretos.
