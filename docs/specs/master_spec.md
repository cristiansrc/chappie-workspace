# Master Spec - Chappie Ecosystem (Solution Workspace Global)

**Estado:** Active  
**Owner:** Enterprise Architect  
**Última actualización:** 2026-06-14  
**Workspace Root:** `/home/cristiansrc/Documentos/Proyectos/chappie-workspace`

---

## 1. Propósito del Sistema

Chappie es un ecosistema de asistente de voz personal con personalidad única (basada en el robot de la película CHAPPIE 2015), diseñado para operar en un entorno Linux/Hyprland. El sistema combina:

- Captura de voz por atajo de teclado (modo walkie-talkie)
- Transcripción de voz a texto (STT)
- Procesamiento inteligente con múltiples proveedores de IA
- Síntesis de voz (TTS) con control adaptativo de volumen
- Ejecución de agentes especializados de OpenCode
- Notificaciones interactivas y widget de texto visual

---

## 2. Bounded Contexts

| Bounded Context | Responsabilidad | Lenguaje Ubicuo | Proyecto |
|---|---|---|---|
| **Infrastructure** | Docker Compose, Systemd, auto-inicio, gestión de contenedores n8n + RabbitMQ | "docker", "contenedor", "auto-inicio", "systemd" | chappie-infrastructure |
| **Voice Capture** | Grabación de audio, control de volumen del micrófono, detección de atajos | "grabación", "captura", "walkie-talkie", "atajo" | chappie-daemon |
| **Audio Output Control** | Volume ducking, restauración de volumen, gestión de sinks de audio, escritura de estado TTS | "ducking", "sink", "volumen", "mute" | chappie-daemon |
| **Speech-to-Text (STT)** | Transcripción de audio a texto | "transcripción", "STT", "audio", "texto" | chappie-daemon, n8n |
| **Text-to-Speech (TTS)** | Síntesis de voz, generación de archivo de audio | "voz", "TTS", "reproducción", "audio" | chappie-notification |
| **Orchestration** | Routing de prompts, gestión de workflows, procesamiento de JSON | "workflow", "pipeline", "enrutamiento" | chappie-n8n-workflows |
| **Agent Execution** | Ejecución de agentes OpenCode, comandos de terminal | "agente", "delegación", "comando", "ejecución" | chappie-notification |
| **Event Bus** | Colas de mensajes, publicación/suscripción de eventos | "evento", "cola", "publicar", "suscribir" | chappie-rabbitmq, chappie-notification |
| **Notification** | Notificaciones visuales, interactivas, widget de texto | "notificación", "alerta", "widget", "overlay" | chappie-notification, chappie-quickshell, SwayNC |
| **Memory** | Contexto conversacional, resúmenes, caducidad | "memoria", "contexto", "sesión", "historial" | chappie-n8n-workflows |
| **Configuration** | Proveedores, personalidades, dispositivos, whitelist | "configuración", "proveedor", "personalidad" | chappie-config |
| **Personality** | System prompt, tono, expresiones, identidad de Chappie | "personalidad", "Chappie", "Creador", "flow" | chappie-config |

---

## 3. Proyectos del Workspace

| Proyecto | Ruta | Bounded Contexts | Owner | Estado |
|---|---|---|---|---|
| chappie-infrastructure | `projects/chappie-infrastructure/` | Infrastructure (Docker, Systemd) | Cris | Active |
| chappie-daemon | `projects/chappie-daemon/` | Voice Capture, Audio Output Control, STT Client | Cris | Pendiente |
| chappie-n8n-workflows | `projects/chappie-n8n-workflows/` | Orchestration, Memory | Cris | Pendiente |
| chappie-notification | `projects/chappie-notification/` | Agent Execution, Event Bus Consumer, TTS, Notification | Cris | Pendiente |
| chappie-quickshell | `projects/chappie-quickshell/` | Notification UI (Widget) | Cris | Pendiente |
| chappie-config | `projects/chappie-config/` | Configuration, Personality | Cris | Pendiente |

---

## 4. Contratos de Integración Globales

### 4.1 Comunicación Síncrona (HTTP/REST)

| Origen | Destino | Endpoint | Propósito |
|---|---|---|---|
| chappie-daemon | chappie-n8n-workflows | `POST /webhook/chappie-voice-capture` | Enviar audio capturado |
| chappie-notification | chappie-n8n-workflows | `POST /webhook/chappie-error-handler` | Reportar error para regenerar respuesta |
| chappie-notification | chappie-daemon | `POST /play-tts` | Solicitar reproducción de audio TTS |

### 4.2 Comunicación Asíncrona (RabbitMQ)

| Cola | Producer | Consumer | Propósito |
|---|---|---|---|
| chappie.responses | n8n | execution_consumer | Respuestas del modelo de IA |
| chappie.errors | execution_consumer | error_consumer | Errores de ejecución |
| chappie.tts.requests | execution_consumer, error_consumer, n8n | tts_consumer | Solicitudes de TTS |
| chappie.agent.results | execution_consumer | notification_consumer | Resultados de agentes |
| chappie.agent.questions | Agentes (vía n8n) | notification_consumer | Preguntas de agentes |
| chappie.agent.answers | notification_consumer | Agentes (vía n8n) | Respuestas del usuario |
| chappie.notifications | n8n, chappie-notification | notification_consumer | Notificaciones genéricas |

### 4.3 Comunicación por Archivos de Estado

| Archivo | Writer | Reader | Propósito |
|---|---|---|---|
| `/tmp/chappie_tts_text.txt` | chappie-notification | chappie-quickshell | Texto TTS actual |
| `/tmp/chappie_tts_state.txt` | chappie-daemon | chappie-quickshell | speaking / idle |
| `/tmp/chappie_text_enabled.txt` | chappie-daemon | chappie-quickshell | true / false (toggle) |
| `/tmp/chappie_state.txt` | chappie-daemon | chappie-quickshell | idle / listening / thinking / working / speaking |

---

## 5. Reglas de Negocio Globales

### 5.1 Flujo de Voz (Voice Loop)
1. Usuario oprime `SUPER+ALT+C` (hold) → chappie-daemon detecta atajo.
2. chappie-daemon aplica volume ducking (10%) en todos los sinks e inicia grabación.
3. Usuario suelta `SUPER+ALT+C` → chappie-daemon restaura volumen, guarda el WAV.
4. chappie-daemon envía el audio a n8n vía webhook HTTP.
5. n8n (workflow "Chappie Voice Pipeline") procesa: STT → Modelo → JSON → publica en `chappie.responses`.
6. execution_consumer (chappie-notification) recibe la respuesta y decide acciones.
7. Si hay `voice_response` → publica en `chappie.tts.requests`.
8. tts_consumer (chappie-notification) genera audio TTS, lo guarda y envía `POST /play-tts` a chappie-daemon.
9. chappie-daemon recibe el play request, aplica ducking, escribe estado "speaking", reproduce, restaura volumen, escribe estado "idle".
10. chappie-quickshell (widget) lee los archivos de estado y muestra/oculta el texto.

### 5.2 Flujo de Error
1. execution_consumer detecta error → publica en `chappie.errors`.
2. error_consumer recibe el error → llama al webhook `chappie-error-handler` en n8n.
3. n8n ejecuta workflow "Error Handler": modelo genera nueva respuesta.
4. n8n publica directamente en `chappie.tts.requests` (RabbitMQ).
5. tts_consumer procesa normalmente.

### 5.3 Flujo de Notificación Interactiva
1. Agente necesita preguntar → publica en `chappie.agent.questions`.
2. notification_consumer crea notificación SwayNC con acciones.
3. Usuario hace clic → notification_consumer captura la acción.
4. Publica en `chappie.agent.answers`.
5. Agente recibe la respuesta y continúa.

---

## 6. Responsabilidades Clave por Componente

### chappie-infrastructure
- Gestión de contenedores Docker (n8n + RabbitMQ)
- Inicialización de colas RabbitMQ (rabbitmq-init)
- Auto-inicio al boot del PC vía systemd (chappie-infra.service)
- Scripts de setup y control (setup.sh, ctl.sh)
- Archivo de variables de entorno (.env) con API keys

### chappie-daemon
- Captura de audio del micrófono
- Detección de atajos de teclado (SUPER+ALT+C)
- Volume ducking durante grabación y reproducción TTS
- Reproducción de audio TTS
- Gestión de archivos de estado: `chappie_tts_state.txt`, `chappie_text_enabled.txt`, `chappie_state.txt`
- NOTA: No ejecuta STT ni orquestación (delega a n8n)

### chappie-notification
- Consume colas de RabbitMQ (execution, error, tts, notification)
- Ejecuta agentes de OpenCode y comandos de terminal
- Genera audio TTS (síntesis de voz)
- Escribe archivo de texto TTS: `/tmp/chappie_tts_text.txt`
- Envía solicitudes de reproducción a chappie-daemon
- Crea notificaciones SwayNC
- NOTA: No realiza volume ducking ni escribe estado TTS

### chappie-n8n-workflows
- Orquestación de workflows (Voice Pipeline, Error Handler)
- Integración con APIs de IA (Gemini, OpenCode, etc.)
- Publicación de mensajes en RabbitMQ
- Gestión de memoria conversacional

### chappie-quickshell
- Widget visual de texto TTS
- Widget de estado de Chappie
- Lectura de archivos de estado con FileView

### chappie-config
- Configuración de proveedores (providers.yaml)
- Configuración de TTS y ducking (tts-config.yaml)
- Whitelist de comandos (commands-whitelist.yaml)
- Personalidad de Chappie

---

## 7. Seguridad Global

| Aspecto | Implementación |
|---|---|
| API Keys | Variables de entorno en Docker Compose |
| Comandos de terminal | Whitelist estricta en commands-whitelist.yaml |
| Sin sudo | Todos los comandos sin privilegios elevados |
| RabbitMQ Auth | Usuario/contraseña en variables de entorno |
| n8n Auth | Header `X-Webhook-Secret` |

---

## 8. SLA/SLO Globales

| Integración | SLA (Latencia) | SLO (Disponibilidad) |
|---|---|---|
| STT (Gemini) | < 5s | 99% |
| Model Processing | < 15s | 95% |
| TTS (Edge-TTS) | < 3s | 99% |
| RabbitMQ | < 100ms | 99.9% |
| n8n Webhook | < 1s | 99% |
| OpenCode CLI | < 120s | 90% |

---

## 9. Lenguaje Ubicuo Global

| Término | Definición | Contexto de uso |
|---|---|---|
| Creador | El usuario (Cris) | Personality, Notification |
| Chappie | El asistente de voz | Todos los contextos |
| Grabación | Captura de audio del micrófono | Voice Capture |
| Ducking | Reducción temporal de volumen | Audio Output Control, TTS |
| Transcripción | Conversión de audio a texto | STT |
| Workflow | Flujo de trabajo en n8n | Orchestration |
| Agente | Especialista de OpenCode | Agent Execution |
| Evento | Mensaje en RabbitMQ | Event Bus |
| Notificación | Alerta visual en SwayNC | Notification |
| Widget | Elemento visual en Quickshell | Notification |

---

## 10. Archivos de Referencia del Workspace

| Archivo | Propósito |
|---|---|
| `docs/architecture/system-landscape.md` | Diagrama C4 Level 2, flujos detallados |
| `docs/architecture/context-map.md` | Bounded contexts, relaciones DDD, lenguaje ubicuo |
| `docs/architecture/integration-map.md` | Contratos de integración detallados, payloads, colas |
| `docs/architecture/workspace-mapping.md` | Estructura del workspace, dependencias entre proyectos |
| `docs/architecture/decision-records/*.md` | Registro de decisiones arquitectónicas (ADRs) |

---

*Documento mantenido por: Enterprise Architect*  
*Próxima revisión: Al completar Fase 1*
