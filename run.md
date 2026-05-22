# Guía para Ejecutar el Emulador de Android

Hemos configurado un emulador ligero de Android sin la necesidad de tener instalado todo el entorno de Android Studio. Sigue estos sencillos comandos desde tu terminal para iniciar el emulador y correr la aplicación.

---

### 1️⃣ Encender el Emulador de Android
Para iniciar el emulador que creamos (`medium_phone`), ejecuta el siguiente comando en tu terminal:

```bash
~/.local/bin/android emulator start medium_phone
```

*Nota: La primera vez o si se cerró, puede tomar hasta 1-2 minutos en iniciar completamente. Verás un mensaje que confirma que ya está listo:*
`Virtual device successfully started as 'emulator-5554'`

---

### 2️⃣ Ejecutar la Aplicación en el Emulador
Una vez que el emulador esté visible en tu pantalla, ejecuta la app en tu terminal con:

```bash
flutter run
```

Flutter detectará automáticamente el emulador de Android (`emulator-5554`) y compilará la app para ese dispositivo.

*Si tienes múltiples dispositivos conectados (como Chrome, iOS, etc.), Flutter te mostrará una lista numerada. Elige el número que corresponda a `emulator-5554` (usualmente sale como `sdk gphone64 arm64` o similar).*

---

### 🔍 Comandos de Utilidad

#### Ver qué emuladores están creados:
```bash
~/.local/bin/android emulator list
```

#### Ver qué dispositivos reconoce Flutter actualmente:
```bash
flutter devices
```

#### Forzar la ejecución directamente en el emulador:
Si no quieres interactuar con la lista de selección, puedes decirle a Flutter exactamente dónde correr la app usando el flag `-d`:
```bash
flutter run -d emulator-5554
```
