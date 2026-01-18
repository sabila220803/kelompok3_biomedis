# Docker Setup untuk Kelompok 3 Biomedis

Project ini telah dikonfigurasi untuk berjalan dalam satu Docker image yang menjalankan:

- Laravel Web Application (Frontend)
- Python AI Service (Backend)
- Apache Web Server
- Supervisord (Process Manager)

## Prerequisites

- Docker Desktop terinstall di Windows
- Port 8080 tersedia (atau ubah di docker-compose.yml)

## Cara Menjalankan

### Opsi 1: Menggunakan Docker Compose (Recommended)

```bash
# Build dan jalankan container
docker-compose up -d

# Lihat logs
docker-compose logs -f

# Stop container
docker-compose down
```

### Opsi 2: Menggunakan Docker Command Langsung

```bash
# Build image
docker build -t biomedis-app .

# Jalankan container
docker run -d -p 8080:80 --name biomedis-app biomedis-app

# Lihat logs
docker logs -f biomedis-app

# Stop container
docker stop biomedis-app

# Hapus container
docker rm biomedis-app
```

## Akses Aplikasi

Setelah container berjalan, akses aplikasi di:

- **Frontend**: http://localhost:8080

## Struktur Container

Container menjalankan 2 service yang dikelola oleh supervisord:

1. **Apache2** - Web server untuk Laravel (port 80)
2. **Python AI Service** - Service untuk deteksi tinggi badan

## Troubleshooting

### Melihat logs supervisord

```bash
docker exec -it biomedis-app tail -f /var/log/supervisor/supervisord.log
```

### Melihat logs Apache

```bash
docker exec -it biomedis-app tail -f /var/log/apache2/error.log
```

### Masuk ke container

```bash
docker exec -it biomedis-app bash
```

### Rebuild tanpa cache

```bash
docker-compose build --no-cache
docker-compose up -d
```

## Environment Variables

Untuk mengubah environment variables, edit file `.env` di dalam container atau tambahkan di `docker-compose.yml`:

```yaml
environment:
  - APP_ENV=production
  - APP_DEBUG=false
  - DB_CONNECTION=sqlite
```

## Persistent Data

Data berikut akan tetap tersimpan meskipun container di-restart:

- Database SQLite (`web-app/database/database.sqlite`)
- Uploaded files (`web-app/storage`)

## Port Mapping

- Port 80 (container) → Port 8080 (host)
- Hanya port frontend yang di-expose ke host

## Maintenance

### Update dependencies

```bash
# PHP dependencies
docker exec -it biomedis-app composer update

# Node.js dependencies
docker exec -it biomedis-app npm update

# Rebuild assets
docker exec -it biomedis-app npm run build
```

### Jalankan migrations

```bash
docker exec -it biomedis-app php artisan migrate
```

### Clear cache

```bash
docker exec -it biomedis-app php artisan cache:clear
docker exec -it biomedis-app php artisan config:clear
docker exec -it biomedis-app php artisan view:clear
```
