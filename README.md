

# 🩺 App Salud

Aplicación móvil desarrollada para el **Semillero de Investigación en Enfermería**, con el objetivo de orientar, acompañar y motivar a los **estudiantes cachimbos** durante su proceso de formación universitaria en la carrera de Enfermería.

---

## 🚀 Objetivo del Proyecto

Brindar una herramienta interactiva, didáctica y accesible que permita a los estudiantes de primeros ciclos:

* Conocer recursos esenciales de su carrera.
* Acceder a contenido educativo confiable.
* Organizar su experiencia universitaria.
* Mantenerse informados sobre actividades del semillero.
* Recibir orientación de manera amigable y moderna.

---

## 🧩 Funcionalidades Previstas

* **Autenticación con Firebase** (email/contraseña).
* **Gestión de perfil del estudiante**.
* **Módulos educativos** (videos, guías, infografías, consejos).
* **Sistema de notificaciones push** con Firebase Messaging.
* **Calendario de eventos académicos**.
* **Chat interno o buzón de dudas**.
* **Gamificación ligera** (puntos, insignias, progreso).
* **Animaciones interactivas con Rive** para mejorar la experiencia visual.
* **UI amigable, minimalista y orientada a estudiantes universitarios.**

---

## 🛠️ Tecnologías Utilizadas

* **Flutter** (framework principal).
* **Dart** (lenguaje).
* **Firebase Suite**:

  * Authentication
  * Firestore Database
  * Cloud Messaging
  * Cloud Storage
* **Rive** (animaciones dinámicas y modernas).
* **Riverpod / Provider** (manejo de estado).
* **Git y GitHub** (control de versiones).
* **VS Code** (IDE recomendado).

---

## ⚙️ Instalación y Configuración Inicial

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/JosePizarro1/app-salud.git
cd app-salud
```

### 2️⃣ Instalar dependencias

```bash
flutter pub get
```

### 3️⃣ Configurar Firebase

1. Entra a Firebase Console
2. Crear un proyecto → agregar app Android/iOS
3. Descargar el archivo `google-services.json` (Android)
4. Descargar el archivo `GoogleService-Info.plist` (iOS)
5. Colocarlos en su carpeta correspondiente
6. Activar:

   * Authentication (Email/Password)
   * Firestore
   * Cloud Messaging

### 4️⃣ Ejecutar la aplicación

```bash
flutter run
```

> 💡 Recomendación: usar Flutter 3.16+ para mayor compatibilidad.

---

# 📁 Estructura del Proyecto (Arquitectura Simple & Modular)

La app utiliza una arquitectura modular ligera, fácil de escalar y pensada para apps pequeñas–medianas con enfoque visual.

```
lib/
 ├─ main.dart
 │
 ├─ app/
 │   ├─ router.dart            # Rutas principales (GoRouter o Navigator)
 │   ├─ theme.dart             # Temas globales
 │   └─ widgets/               # Widgets globales reutilizables
 │        └─ ...
 │
 ├─ services/
 │   ├─ firebase_auth_service.dart
 │   └─ firebase_db_service.dart
 │
 └─ features/
      ├─ auth/
      │    ├─ pages/
      │    │     ├─ login_page.dart
      │    │     └─ register_page.dart
      │    ├─ controller/
      │    │     └─ auth_controller.dart
      │    └─ widgets/
      │          └─ login_form.dart
      │
      ├─ home/
      │    ├─ pages/
      │    │     └─ home_page.dart
      │    ├─ controller/
      │    │     └─ home_controller.dart
      │    └─ widgets/
      │          └─ home_header.dart
      │
      ├─ modulo1/
      │    ├─ pages/
      │    │     ├─ modulo1_menu_page.dart
      │    │     ├─ modulo1_detail_page.dart
      │    │     └─ modulo1_result_page.dart
      │    ├─ controller/
      │    │     └─ modulo1_controller.dart
      │    └─ widgets/
      │          ├─ modulo1_card.dart
      │          └─ modulo1_list_item.dart
      │
      └─ modulo2/
           ├─ pages/
           ├─ controller/
           └─ widgets/
```

---

# 🎨 Carpetas de recursos

```
assets/
 ├─ rive/        # Animaciones .riv
 ├─ images/
 └─ icons/
```

> ✔ Rive se usará para: animaciones de loading, login, mascota de la app, transiciones y microinteracciones.

---

# 🔥 Características Técnicas Importantes

### ✔ Uso de Firebase

La app utiliza Firebase como backend principal para:

* Autenticación de estudiantes.
* Base de datos para recursos, módulos y progreso.
* Notificaciones push para avisos del semillero.
* Almacenamiento de imágenes y materiales educativos.

### ✔ Uso de Rive

Rive proporciona:

* Animaciones suaves y nativas en tiempo real.
* Mejor UX en pantallas como login, carga y tutoriales.
* Mascota animada que interactúa con el usuario.

---

# 🧠 Equipo de Desarrollo

* **Desarrollo:** [José Pizarro Rabanal](https://github.com/JosePizarro1)
* **Institución:** Semillero de Investigación de Enfermería
* **Apoyo:** Estudiantes y docentes del semillero

---

# 📜 Licencia

Este proyecto es de uso académico y pertenece al **Semillero de Investigación en Enfermería**.
Puedes reutilizarlo con fines educativos indicando la autoría.

---

# 🌱 Estado Actual del Proyecto

🧩 En desarrollo (versión inicial)
📆 Inicio: Noviembre 2025
🎨 Próxima meta: Diseño UI + mascota animada con Rive

---

# 💬 Contacto

📧 [josepizarro.dev@gmail.com](mailto:josepizarro.dev@gmail.com)
🔗 GitHub: [@JosePizarro1](https://github.com/JosePizarro1)

---

