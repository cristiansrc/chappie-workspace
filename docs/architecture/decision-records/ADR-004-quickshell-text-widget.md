# ADR-004: Quickshell para Widget de Texto TTS

**Estado:** Accepted  
**Fecha:** 2026-06-13  
**Owner:** Enterprise Architect  
**Superseded by:** N/A

---

## Contexto

Chappie necesita mostrar el texto de lo que está diciendo en un widget visual en la pantalla del usuario. Los requisitos son:
- Mostrar texto en una posición configurable (arriba a la derecha)
- Animaciones de entrada/salida suaves
- Toggle con atajo de teclado (SUPER+ALT+T)
- Integración con Hyprland
- Estilo personalizable

Las opciones evaluadas fueron:

1. **Notificación persistente con notify-send:** Mostrar texto en una notificación.
2. **Quickshell QML Widget:** Widget personalizado con QML/Qt6.
3. **Hyprland layer surface:** Overlay nativo de Hyprland.
4. **Barra de estado existente:** Integrar en la barra existente.

## Decisión

**Usar Quickshell** para crear un widget QML que muestre el texto TTS de Chappie.

## Alternativas Consideradas

### Opción 1: Notificación persistente con notify-send
- **Ventajas:** Simple, sin componentes adicionales.
- **Desventajas:** Sin animaciones, estilo limitado, no se puede posicionar con precisión, desaparece después de un tiempo, no es elegante.

### Opción 2: Quickshell QML Widget ✅ (Elegida)
- **Ventajas:**
  - Control total del diseño y animaciones.
  - Posicionamiento preciso en la pantalla.
  - Integración nativa con Hyprland.
  - FileView para leer archivos de estado en tiempo real.
  - QML/Qt6 para UI moderna y fluida.
  - Estándar en ecosistemas Hyprland modernos (dots-hyprland).
  - Reutilizable para otros widgets (estado, overlay).
  - Personalizable con temas.
- **Desventajas:** Requiere instalación de Quickshell, curva de aprendizaje de QML.

### Opción 3: Hyprland layer surface
- **Ventajas:** Nativo de Hyprland, sin dependencias adicionales.
- **Desventajas:** Requiere desarrollo en C/C++ o uso de herramientas externas, menos flexible que QML, sin animaciones fáciles.

### Opción 4: Barra de estado existente
- **Ventajas:** Integrado en el sistema existente.
- **Desventajas:** Espacio limitado, no es el propósito de la barra, difícil de toggle.

## Consecuencias

### Positivas
- Widget elegante con animaciones suaves.
- Posicionamiento configurable.
- Toggle con atajo de teclado.
- Lectura de archivos de estado en tiempo real (FileView).
- Reutilizable para otros widgets (estado de Chappie, overlay).
- Estándar de la comunidad Hyprland.

### Negativas
- Requiere instalación de Quickshell.
- Curva de aprendizaje de QML para modificaciones.
- Un componente más que mantener.

### Riesgos
- Quickshell debe estar corriendo para el widget.
- Los archivos de estado deben actualizarse correctamente.

## Mitigación
- Instalar Quickshell como dependencia del sistema.
- Configurar autostart en Hyprland.
- Fallback a notificación si Quickshell no está disponible.

## Arquitectura del Widget

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CHAPPIE TEXT WIDGET (Quickshell)                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Archivos de estado:                                                    │
│  /tmp/chappie_tts_text.txt     → Texto que se está diciendo            │
│  /tmp/chappie_tts_state.txt    → "speaking" | "idle"                   │
│  /tmp/chappie_text_enabled.txt → "true" | "false" (toggle)             │
│                                                                         │
│  Widget lee archivos con FileView (watch changes):                     │
│  - Si state = "speaking" AND enabled = "true":                         │
│    → Mostrar widget con animación de entrada                           │
│    → Mostrar texto con efecto de "typing"                              │
│  - Si state = "idle":                                                  │
│    → Animación de salida                                               │
│    → Ocultar widget                                                    │
│                                                                         │
│  Posición: Arriba a la derecha, debajo de la barra del shell           │
│  Estilo: Fondo semi-transparente, borde con glow, texto blanco         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Widgets Futuros

El mismo enfoque de Quickshell se puede reutilizar para:
- **ChappieStatusWidget:** Mostrar estado (escuchando, pensando, trabajando, hablando)
- **ChappieOverlay:** Overlay para modo de configuración
- **ChappieNotificationWidget:** Widget de notificaciones personalizado

---

*Decisión revisada: N/A*
