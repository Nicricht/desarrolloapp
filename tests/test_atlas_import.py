"""Prueba sin secretos reales de la importacion Atlas del ZIP original."""
from pathlib import Path
from tempfile import TemporaryDirectory
from zipfile import ZipFile
import subprocess

root = Path(__file__).resolve().parents[1]
dotenv = root / ".env"
if dotenv.exists():
    raise SystemExit("La prueba no puede sobrescribir el .env existente")

names = ("roles", "usuarios", "catalogos", "siniestros")
with TemporaryDirectory() as directory:
    archive = Path(directory) / "backend-seguros-bpo-main.zip"
    with ZipFile(archive, "w") as handle:
        for name in names:
            path = f"backend-seguros-bpo-main/{name}-service/src/main/resources/application.properties"
            handle.writestr(path, f"server.port=8081\nspring.mongodb.uri=mongodb+srv://fixture:ci-only@atlas.example/segurosbpo_{name}\n")
    try:
        subprocess.run(
            ["pwsh", "-NoProfile", "-File", str(root / "scripts" / "iniciar-duoc.ps1"),
             "-ConfigOnly", "-AtlasZip", str(archive)],
            cwd=root, check=True,
        )
        content = dotenv.read_text(encoding="utf-8-sig")
        for name in names:
            key = f"ATLAS_{name.upper()}_URI"
            expected = f"{key}='mongodb+srv://fixture:ci-only@atlas.example/segurosbpo_{name}'"
            if expected not in content:
                raise AssertionError(f"URI Atlas no importada para {name}")
        print("Importador Atlas: cuatro URI correctas")
    finally:
        dotenv.unlink(missing_ok=True)
