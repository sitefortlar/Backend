#!/usr/bin/env python3
"""
Script de migração: arquivos locais → MinIO

Suporta duas fontes:
  1. Backup do Supabase Storage:  backup_supabase_storage/storage_backup/
  2. Storage local legado:        uploads/

Mapeamento de destino:
  {fonte}/produtos/**  → bucket "produtos"  /  key = caminho relativo
  {fonte}/planilhas/** → bucket "planilhas" /  key = caminho relativo

Uso:
  # Migrar backup do Supabase
  python scripts/migrate_to_minio.py --source backup_supabase_storage/storage_backup

  # Migrar uploads locais legados
  python scripts/migrate_to_minio.py --source uploads

  # Dry run (só mostra o que seria enviado, sem fazer upload)
  python scripts/migrate_to_minio.py --source backup_supabase_storage/storage_backup --dry-run

  # Pular arquivos que já existem no MinIO (incremental)
  python scripts/migrate_to_minio.py --source backup_supabase_storage/storage_backup --skip-existing
"""

import os
import sys
import argparse
import mimetypes
from pathlib import Path

# Adiciona o root do projeto ao path
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from dotenv import load_dotenv
load_dotenv(ROOT / ".env")

import envs
from app.infrastructure.storage.minio_client import MinioClient


BUCKET_MAP = {
    "produtos": envs.MINIO_BUCKET_PRODUTOS,
    "planilhas": envs.MINIO_BUCKET_PLANILHAS,
}


def content_type_for(path: Path) -> str:
    mime, _ = mimetypes.guess_type(str(path))
    return mime or "application/octet-stream"


def migrate(source_dir: Path, dry_run: bool, skip_existing: bool) -> None:
    if not source_dir.exists():
        print(f"[ERRO] Diretório não encontrado: {source_dir}")
        sys.exit(1)

    print(f"Fonte: {source_dir}")
    print(f"Buckets: {list(BUCKET_MAP.values())}")
    print(f"Dry run: {dry_run}  |  Skip existing: {skip_existing}")
    print("-" * 60)

    # Garante que os buckets existem
    if not dry_run:
        MinioClient.ensure_buckets(list(BUCKET_MAP.values()))

    total = uploaded = skipped = errors = 0

    for folder_name, bucket in BUCKET_MAP.items():
        folder = source_dir / folder_name
        if not folder.exists():
            print(f"[AVISO] Pasta '{folder_name}' não encontrada em {source_dir}, pulando.")
            continue

        files = [f for f in folder.rglob("*") if f.is_file()]
        print(f"\n📁 {folder_name}/ → bucket '{bucket}' ({len(files)} arquivos)")

        for file_path in files:
            total += 1
            # key = caminho relativo à pasta do bucket
            # Ex: produtos/123/abc.jpg → key = "123/abc.jpg"
            key = str(file_path.relative_to(folder)).replace("\\", "/")
            ct = content_type_for(file_path)

            if skip_existing and not dry_run:
                if MinioClient.exists(bucket, key):
                    print(f"  SKIP  {key}")
                    skipped += 1
                    continue

            if dry_run:
                print(f"  DRY   {bucket}/{key}  ({ct})")
                uploaded += 1
                continue

            try:
                data = file_path.read_bytes()
                MinioClient.upload(bucket, key, data, ct)
                print(f"  OK    {bucket}/{key}  ({len(data):,} bytes)")
                uploaded += 1
            except Exception as e:
                print(f"  ERRO  {bucket}/{key}: {e}")
                errors += 1

    print("\n" + "=" * 60)
    print(f"Total: {total}  |  Enviados: {uploaded}  |  Pulados: {skipped}  |  Erros: {errors}")

    if errors:
        print("[AVISO] Alguns arquivos falharam. Verifique os logs acima.")
        sys.exit(1)
    else:
        label = "simulados" if dry_run else "migrados"
        print(f"✓ {uploaded} arquivo(s) {label} com sucesso.")


def main():
    parser = argparse.ArgumentParser(description="Migra arquivos locais para o MinIO")
    parser.add_argument(
        "--source",
        default="backup_supabase_storage/storage_backup",
        help="Diretório raiz contendo as pastas 'produtos/' e 'planilhas/'",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simula a migração sem fazer upload real",
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="Pula arquivos que já existem no MinIO (migração incremental)",
    )
    args = parser.parse_args()

    source = Path(args.source)
    if not source.is_absolute():
        source = ROOT / source

    migrate(source, dry_run=args.dry_run, skip_existing=args.skip_existing)


if __name__ == "__main__":
    main()
