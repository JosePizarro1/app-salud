# Componentes y Funcionalidades Destacadas (Ejemplos de Referencia)

Este archivo contiene el registro de componentes premium implementados en el proyecto para servir como referencia o plantilla en futuras implementaciones.

---

## 1. Banner de Notificación Flotante con Retraso y Sonido (Floating Tip Banner)
Una tarjeta interactiva que aparece flotando en la pantalla tras un retraso de unos segundos, reproduce un efecto de sonido agradable y se desvanece al hacer tap.

- **Ruta de la Implementación**: [bmi_calculator_page.dart](file:///e:/flutter_application_1/app-salud-clone/lib/features/home/pages/bmi_calculator_page.dart)
- **Características principales**:
  - Tránsito/entrada animada usando `FadeInDown` (`animate_do`).
  - Activación asíncrona mediante un retraso de 3 segundos (`Future.delayed`) al iniciar el estado.
  - Reproducción del sonido `noti_sound.mp3` al mostrarse.
  - Detector de gestos (`GestureDetector`) que permite desvanecer y ocultar el banner al hacer clic en él.
