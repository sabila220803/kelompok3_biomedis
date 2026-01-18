# PowerShell script untuk build dan jalankan Docker container

Write-Host "🐋 Building Docker image..." -ForegroundColor Cyan
docker-compose build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Starting container..." -ForegroundColor Cyan
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container started successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📱 Aplikasi berjalan di: http://localhost:8080" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 Perintah berguna:" -ForegroundColor White
        Write-Host "  - Lihat logs: docker-compose logs -f"
        Write-Host "  - Stop: docker-compose down"
        Write-Host "  - Restart: docker-compose restart"
        Write-Host "  - Masuk ke container: docker exec -it biomedis-app bash"
    } else {
        Write-Host "❌ Gagal menjalankan container" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Build gagal" -ForegroundColor Red
    exit 1
}
