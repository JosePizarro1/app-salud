# Vitali Project Context & Agent Instructions

Este archivo es la fuente de verdad para todos los agentes de IA que trabajen en el proyecto **Vitali**. Su objetivo es mantener la consistencia técnica, arquitectónica y visual.

## 🌟 Visión del Proyecto
Vitali es una aplicación premium enfocada en el bienestar y la salud, diseñada para semilleros de investigación. La experiencia de usuario debe sentirse **calmada, fluida y profesional**, utilizando una estética "Wellness" basada en tonos pastel y micro-animaciones.

## 🛠️ Stack Tecnológico
- **Framework**: Flutter (Channel stable).
- **Backend**: Supabase (Auth, Database, Storage).
- **Gestión de Rutas**: `go_router`.
- **Diseño & Estilo**: 
  - Google Fonts (Fuente principal: `Outfit`).
  - `animate_do` para transiciones de entrada.
  - `dotlottie_flutter` para animaciones interactivas.
  - `AppColors` (Sistema de diseño centralizado).

## 📁 Arquitectura de Archivos
Seguimos una estructura basada en **Features**:
- `lib/app/`: Configuración global, temas, constantes y widgets compartidos.
  - `lib/app/theme/app_colors.dart`: **Fuente única de verdad para colores.**
- `lib/features/`: Módulos independientes por funcionalidad (ej. `auth`, `home`).
  - Cada feature tiene sus propias carpetas: `pages/`, `widgets/`, `controllers/`.
- `.agents/`: Skills y documentación para agentes.

## 🎨 Reglas de Diseño "Vitali Premium" (Mandatorias)
1.  **Colores**: PROHIBIDO usar colores hardcodeados (ej. `Colors.blue`). Usa siempre `AppColors.mint`, `AppColors.lavender`, etc.
2.  **Topografía**: Todos los textos de marca deben usar `GoogleFonts.outfit()`.
3.  **Animaciones**: 
    - Cada nueva pantalla debe usar `FadeInUp` o similar de `animate_do` para sus componentes.
    - Las animaciones Lottie deben envolverse en el widget `_SafeLottie` (definido en `login_page.dart`) para evitar errores 403 o fallos de red.
4.  **Headers**: Preferencia por cabeceras orgánicas/onduladas (`WavyHeader`) para mantener la estética de fluidez.
5.  **Tactile Feedback**: Usa `HapticFeedback.mediumImpact()` en botones principales de acción.

## 🚀 Estado Actual
- [x] **Autenticación**: Login y Registro rediseñados con estética Vitali.
- [x] **Tema**: Sistema de colores pastel y gradientes wavy implementado.
- [x] **Persistencia**: Integración inicial con Supabase completada.
- [x] **Navegación**: GoRouter configurado.

## 🎯 Próximos Pasos (Roadmap)
1.  **Home Redesign**: Continuar iterando el dashboard principal con tarjetas interactivas y animaciones.
2.  **Validaciones**: Implementar validadores de campos en los formularios de Auth.
3.  **Modularización**: Mover widgets compartidos (como `WavyHeader` o `SafeLottie`) de `login_page.dart` a `lib/app/widgets/` para su reutilización.

---
> [!IMPORTANT]
> Antes de realizar cualquier cambio visual, lee siempre `.agents/skills/app-design-system/SKILL.md`.
> Para consultas sobre la base de datos, lee `.agents/skills/supabase-postgres-best-practices/SKILL.md`.
