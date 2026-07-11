---
name: reduce-assets
description: Guía y estándares técnicos para optimizar, comprimir y reducir el peso de recursos visuales (imágenes, GIFs y animaciones) en el proyecto Vitali.
---

# 📉 Skill: Optimización y Reducción de Assets

Esta guía define las directrices obligatorias para la gestión de recursos visuales en Vitali. El objetivo es mantener el rendimiento de la aplicación en 60 FPS estables y reducir el tamaño del instalador (APK/IPA).

## 📏 Estándares de Peso Máximo

| Tipo de Recurso | Formato Preferido | Peso Límite Recomendado | Peso Límite Absoluto |
| :--- | :--- | :--- | :--- |
| **Iconos / Vectores** | SVG (`flutter_svg`) / Icon Fonts | < 5 KB | 15 KB |
| **Imágenes Pequeñas/Botones** | WebP (con transparencia) | < 25 KB | 50 KB |
| **Ilustraciones/Muebles** | WebP (con transparencia) | < 80 KB | 120 KB |
| **Fondos de Pantalla** | WebP / JPEG Comprimido | < 120 KB | 200 KB |
| **Animaciones Activas** | Lottie (.json / .lottie) | < 100 KB | 300 KB |

> [!WARNING]
> **PROHIBIDO** el uso de archivos GIF pesados (> 500 KB) para animaciones en bucle. Deben convertirse a formato Lottie vectorizado o a WebP animado optimizado si son de naturaleza fotográfica.

---

## 🛠️ Herramientas de Optimización Recomendadas

1. **Imágenes Estáticas (PNG, JPG, WebP)**
   - **Squoosh (squoosh.app)**: Herramienta de Google para convertir a WebP y ajustar calidad/tamaño con previsualización en tiempo real.
   - **TinyPNG (tinypng.com)**: Excelente compresión sin pérdida para PNG/WebP.
   - **CLI Tool (`cwebp`)**: Para optimización por lotes en terminal.
     ```bash
     cwebp -q 80 imagen.png -o imagen.webp
     ```

2. **Animaciones**
   - **Lottie Files**: Usar animaciones vectoriales basadas en JSON.
   - **ezgif.com / ffmpeg**: Si es obligatorio usar un archivo animado rasterizado, convertir el GIF a WebP Animado (`.webp`) o reducir su resolución y framerate.
     ```bash
     ffmpeg -i input.gif -vcodec libwebp -filter_complex "[0:v] split [a][b];[a] palettegen [p];[b][p] paletteuse" -loop 0 output.webp
     ```

---

## 💻 Buenas Prácticas en Código (Flutter)

### 1. Limitar Tamaño de Caché en Memoria
Aunque una imagen pese poco en disco, al decodificarse en RAM ocupará `ancho * alto * 4 bytes`. Si muestras una imagen de `2000x2000` en un contenedor de `100x100`, desperdiciarás megabytes de memoria RAM.
Usa siempre `cacheWidth` o `cacheHeight` en imágenes pesadas:

```dart
Image.asset(
  'assets/images/modulo1.png',
  cacheWidth: 300, // Limita la resolución en memoria RAM a la necesaria
  fit: BoxFit.contain,
);
```

### 2. Evitar Parpadeos con Pre-carga Selectiva
Pre-carga únicamente los assets críticos de la pantalla siguiente o actual en `didChangeDependencies`, pero asegúrate de que ya estén optimizados en disco.

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(const AssetImage('assets/images/fondotiti.webp'), context);
}
```
