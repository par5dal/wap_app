# Script para eliminar transparencia de iconos PNG
Add-Type -AssemblyName System.Drawing

$sourceIcon = "assets\images\app_icon.png"
$tempIcon = "assets\images\app_icon_no_alpha.png"

# Verificar que existe el archivo
if (-not (Test-Path $sourceIcon)) {
    Write-Host "ERROR: No se encuentra $sourceIcon" -ForegroundColor Red
    exit 1
}

Write-Host "Eliminando transparencia del icono..." -ForegroundColor Cyan

# Cargar imagen original
$originalImage = [System.Drawing.Image]::FromFile((Resolve-Path $sourceIcon).Path)

# Crear nueva imagen con fondo blanco
$newImage = New-Object System.Drawing.Bitmap($originalImage.Width, $originalImage.Height)
$graphics = [System.Drawing.Graphics]::FromImage($newImage)

# Rellenar con fondo blanco
$graphics.Clear([System.Drawing.Color]::White)

# Dibujar la imagen original encima
$graphics.DrawImage($originalImage, 0, 0, $originalImage.Width, $originalImage.Height)

# Guardar como PNG sin transparencia
$newImage.Save($tempIcon, [System.Drawing.Imaging.ImageFormat]::Png)

# Limpiar recursos
$graphics.Dispose()
$newImage.Dispose()
$originalImage.Dispose()

Write-Host "✓ Icono sin transparencia guardado en: $tempIcon" -ForegroundColor Green

# Ahora regenerar todos los iconos de iOS
Write-Host ""
Write-Host "Regenerando iconos de iOS..." -ForegroundColor Cyan

$sizes = @(
    @{Size=1024; Scale=1; Name="Icon-App-1024x1024@1x.png"},
    @{Size=20; Scale=1; Name="Icon-App-20x20@1x.png"},
    @{Size=20; Scale=2; Name="Icon-App-20x20@2x.png"},
    @{Size=20; Scale=3; Name="Icon-App-20x20@3x.png"},
    @{Size=29; Scale=1; Name="Icon-App-29x29@1x.png"},
    @{Size=29; Scale=2; Name="Icon-App-29x29@2x.png"},
    @{Size=29; Scale=3; Name="Icon-App-29x29@3x.png"},
    @{Size=40; Scale=1; Name="Icon-App-40x40@1x.png"},
    @{Size=40; Scale=2; Name="Icon-App-40x40@2x.png"},
    @{Size=40; Scale=3; Name="Icon-App-40x40@3x.png"},
    @{Size=50; Scale=1; Name="Icon-App-50x50@1x.png"},
    @{Size=50; Scale=2; Name="Icon-App-50x50@2x.png"},
    @{Size=57; Scale=1; Name="Icon-App-57x57@1x.png"},
    @{Size=57; Scale=2; Name="Icon-App-57x57@2x.png"},
    @{Size=60; Scale=2; Name="Icon-App-60x60@2x.png"},
    @{Size=60; Scale=3; Name="Icon-App-60x60@3x.png"},
    @{Size=72; Scale=1; Name="Icon-App-72x72@1x.png"},
    @{Size=72; Scale=2; Name="Icon-App-72x72@2x.png"},
    @{Size=76; Scale=1; Name="Icon-App-76x76@1x.png"},
    @{Size=76; Scale=2; Name="Icon-App-76x76@2x.png"},
    @{Size=83.5; Scale=2; Name="Icon-App-83.5x83.5@2x.png"}
)

$sourceImage = [System.Drawing.Image]::FromFile((Resolve-Path $tempIcon).Path)
$outputDir = "ios\Runner\Assets.xcassets\AppIcon.appiconset"

foreach ($iconConfig in $sizes) {
    $targetSize = [int]($iconConfig.Size * $iconConfig.Scale)
    $targetPath = Join-Path $outputDir $iconConfig.Name
    
    # Crear nueva imagen redimensionada
    $resizedImage = New-Object System.Drawing.Bitmap($targetSize, $targetSize)
    $resizeGraphics = [System.Drawing.Graphics]::FromImage($resizedImage)
    
    # Configurar calidad alta para redimensionado
    $resizeGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $resizeGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $resizeGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $resizeGraphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    # Dibujar imagen redimensionada
    $resizeGraphics.DrawImage($sourceImage, 0, 0, $targetSize, $targetSize)
    
    # Guardar
    $resizedImage.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Limpiar
    $resizeGraphics.Dispose()
    $resizedImage.Dispose()
    
    Write-Host "  ✓ $($iconConfig.Name) (${targetSize}x${targetSize})" -ForegroundColor Gray
}

$sourceImage.Dispose()

Write-Host ""
Write-Host "✅ Todos los iconos regenerados sin transparencia!" -ForegroundColor Green
Write-Host ""
Write-Host "Recuerda:" -ForegroundColor Yellow
Write-Host "  1. Puedes eliminar el archivo temporal: $tempIcon" -ForegroundColor Yellow
Write-Host "  2. Haz commit de los cambios en ios/Runner/Assets.xcassets/AppIcon.appiconset/" -ForegroundColor Yellow
