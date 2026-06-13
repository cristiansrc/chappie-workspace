# ADR-003: SwayNC para Notificaciones

**Estado:** Accepted  
**Fecha:** 2026-06-13  
**Owner:** Enterprise Architect  
**Superseded by:** N/A

---

## Contexto

Chappie necesita un sistema de notificaciones que:
- Muestre notificaciones emergentes (popups)
- Soporte acciones interactivas (botones)
- Tenga un centro de notificaciones para ver historial
- Se integre con Hyprland
- Permita al usuario responder preguntas de los agentes

Las opciones evaluadas fueron:

1. **notify-send + dunst:** Notificaciones básicas sin acciones.
2. **SwayNC:** Centro de notificaciones con acciones.
3. **Mako:** Notificador ligero para Wayland.
4. **Quickshell notification daemon:** Widget personalizado.

## Decisión

**Usar SwayNC** como daemon de notificaciones principal para Chappie.

## Alternativas Consideradas

### Opción 1: notify-send + dunst
- **Ventajas:** Simple, ligero, ampliamente usado.
- **Desventajas:** No soporta acciones interactivas (botones), sin centro de notificaciones, limitado para el flujo de preguntas/respuestas de agentes.

### Opción 2: SwayNC ✅ (Elegida)
- **Ventajas:**
  - Soporte nativo de acciones interactivas (botones en notificaciones).
  - Centro de notificaciones con historial.
  - Configurable con CSS para personalización visual.
  - Integración nativa con Hyprland/Wayland.
  - Do Not Disturb mode.
  - MPRIS integration para control de multimedia.
  - API de línea de comandos (`swaync-client`).
  - Notificaciones persistentes cuando se necesita.
- **Desventajas:** Requiere instalación adicional, un componente más.

### Opción 3: Mako
- **Ventajas:** Ligero, simple, Wayland-native.
- **Desventajas:** Sin centro de notificaciones, soporte limitado de acciones, menos configurable.

### Opción 4: Quickshell notification daemon
- **Ventajas:** Control total del diseño, integración perfecta con el resto del shell.
- **Desventajas:** Desarrollo significativo, reinventar la rueda, mantenimiento continuo.

## Consecuencias

### Positivas
- Notificaciones con botones de acción para preguntas de agentes.
- Centro de notificaciones para ver historial.
- Personalización visual con CSS.
- Integración nativa con Hyprland.
- `notify-send` compatible (no requiere cambiar la forma de enviar notificaciones).

### Negativas
- Un componente más que instalar y mantener.
- Configuración adicional necesaria.

### Riesgos
- SwayNC debe estar corriendo para las notificaciones.
- Las acciones interactivas requieren que el consumer esté escuchando.

## Mitigación
- Instalar SwayNC como dependencia del sistema.
- Configurar autostart en Hyprland.
- Fallback a `notify-send` básico si SwayNC no está disponible.

## Flujo de Notificaciones Interactivas

```
1. Agente necesita preguntar → Publica en chappie.agent.questions
2. notification_consumer → Crea notificación con acciones:
   notify-send "Chappie necesita tu atención" \
     "El agente executor tiene una pregunta" \
     --action="typescript=TypeScript" \
     --action="javascript=JavaScript" \
     --action="ignore=Ignorar"
3. Usuario hace clic en un botón → SwayNC emite evento
4. notification_consumer captura la acción
5. Publica en chappie.agent.answers
6. Agente recibe la respuesta y continúa
```

---

*Decisión revisada: N/A*
