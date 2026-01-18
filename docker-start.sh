#!/bin/bash

# Script untuk build dan jalankan Docker container

echo "🐋 Building Docker image..."
docker-compose build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🚀 Starting container..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo "✅ Container started successfully!"
        echo ""
        echo "📱 Aplikasi berjalan di: http://localhost:8080"
        echo ""
        echo "📋 Perintah berguna:"
        echo "  - Lihat logs: docker-compose logs -f"
        echo "  - Stop: docker-compose down"
        echo "  - Restart: docker-compose restart"
        echo "  - Masuk ke container: docker exec -it biomedis-app bash"
    else
        echo "❌ Gagal menjalankan container"
        exit 1
    fi
else
    echo "❌ Build gagal"
    exit 1
fi
