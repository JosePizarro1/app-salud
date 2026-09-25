# 🩺 Vitali (App Salud)

Aplicación móvil de bienestar integral desarrollada para el **Semillero de Investigación en Enfermería**, diseñada para orientar, acompañar y motivar a los **estudiantes universitarios** durante su formación académica y personal.

---

## 🌟 Visión del Proyecto

**Vitali** busca ofrecer una experiencia de usuario calmada, accesible y fluida con una estética enfocada en el bienestar (*Wellness*), combinando tonos pastel, microinteracciones y contenidos didácticos basados en evidencia para apoyar la salud física y mental de los estudiantes.

---

## 🛠️ Stack Tecnológico

* **Framework:** [Flutter](https://flutter.dev/) (Dart SDK ^3.9.2)
* **Backend & Autenticación:** [Supabase](https://supabase.com/) (Auth, PostgreSQL Database, Storage)
* **Navegación & Enrutamiento:** `go_router`
* **Manejo de Variables de Entorno:** `flutter_dotenv`
* **Diseño & UI:**
  * Tipografía: `Google Fonts (Outfit)`
  * Microanimaciones: `animate_do`
  * Animaciones vectoriales interactivas: `dotlottie_flutter` (.lottie)
  * Sistema de colores centralizado: `AppColors`
* **Multimedia & Sensores:**
  * Reproducción de audio: `audioplayers`
  * Reproducción de video: `video_player`
  * Gráficos interactivos: `fl_chart`
  * Notificaciones locales: `flutter_local_notifications`

---

## 🧩 Módulos y Funcionalidades

* 🔐 **Autenticación & Perfil:** Registro e inicio de sesión seguros mediante Supabase Auth con soporte de persistencia de sesión.
* 🥗 **Alimentación Saludable:** Guías y lecciones interactivas sobre nutrición para estudiantes universitarios.
* 😴 **Cuidado del Sueño (Sleep Care):** Módulos de lectura y consejos prácticos para optimizar el descanso y el rendimiento cognitivo.
* 🧘 **Meditación, Yoga y Respiración:** Sesiones guiadas de respiración consciente, pausas activas y ejercicios posturales con temporizadores y audio.
* 🎵 **Música Relajante:** Reproductor de pistas sonoras ambientales y efectos de sonido para concentración y reducción del estrés.
* 💭 **Gestión Emocional:** Registro, monitoreo y visualización del estado de ánimo con gráficas analíticas.
* 📅 **Organizador Académico:** Herramientas para la gestión del tiempo y hábitos de estudio.
* 🎮 **Gamificación & Minijuegos:** Dinámicas lúdicas para reforzar el aprendizaje y la adherencia a hábitos saludables.
* ⚙️ **Panel de Administración:** Control de contenidos y seguimiento de métricas del semillero.

---

## 📁 Arquitectura del Proyecto

El código está estructurado siguiendo un enfoque **Feature-First / Modular**, separando responsabilidades de forma clara y escalable:

```text
lib/
 ├─ main.dart                        # Punto de entrada de la aplicación
 │
 ├─ app/                             # Configuración global y núcleo
 │   ├─ router.dart                  # Configuración de rutas (GoRouter)
 │   ├─ theme.dart                   # Definición de temas claro/oscuro
 │   ├─ theme/                       # Paleta de colores centralizada (AppColors)
 │   ├─ services/                    # Gestores de audio, SFX y métricas
 │   └─ widgets/                     # Componentes visuales transversales
 │
 ├─ features/                        # Módulos independientes por dominio
 │   ├─ admin/                       # Vistas y paneles administrativos
 │   ├─ auth/                        # Autenticación (Login, Registro)
 │   ├─ emotions/                    # Monitoreo emocional y analítica
 │   ├─ games/                       # Lógica y vistas de gamificación
 │   ├─ home/                        # Dashboard y módulos de bienestar (nutrición, sueño, yoga)
 │   ├─ organizer/                   # Planificación y hábitos
 │   └─ settings/                    # Ajustes de la aplicación
 │
 └─ services/                        # Servicios de notificaciones y sesión
```

---

## ⚙️ Instalación y Configuración

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/JosePizarro1/app-salud.git
cd app-salud
```

### 2️⃣ Instalar dependencias

```bash
flutter pub get
```

### 3️⃣ Configurar variables de entorno

Copia el archivo `.env.example` como `.env` en la raíz del proyecto y completa las credenciales de tu proyecto de Supabase:

```bash
cp .env.example .env
```

Contenido requerido en `.env`:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
```

### 4️⃣ Ejecutar la aplicación

Asegúrate de tener un emulador activo o un dispositivo físico conectado:

```bash
flutter run
```

---

## 📦 Exportación Limpia del Código Fuente

Si necesitas compartir el código fuente como archivo `.zip` sin incluir artefactos compilados ni dependencias:

* **Opción recomendada (vía Git):**
  ```bash
  git archive --format=zip --output=vitali_source_code.zip HEAD
  ```
* **Opción manual:**
  Ejecutar primero `flutter clean` para remover `build/` y temporales antes de comprimir la carpeta.

---

## 🧠 Equipo de Desarrollo

* **Desarrollo:** [José Pizarro Rabanal](https://github.com/JosePizarro1)
* **Institución:** Semillero de Investigación en Enfermería

---

## 📜 Licencia

Proyecto de uso académico y de investigación perteneciente al **Semillero de Investigación en Enfermería**.
