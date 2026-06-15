# Integration Map - Chappie Ecosystem

**Estado:** Active  
**Owner:** Enterprise Architect  
**Última actualización:** 2026-06-14

---

## 0. Infraestructura Base (Auto-Inicio)

### 0.1 chappie-infrastructure → System Boot

| Aspecto | Detalle |
|---|---|
| **Tipo** | Systemd user service |
| **Servicio** | `chappie-infra.service` |
| **Ubicación** | `~/.config/systemd/user/chappie-infra.service` |
| **Acción** | `docker compose up -d` al iniciar sesión |
| **Contenedores** | chappie-n8n, chappie-rabbitmq, chappie-rabbitmq-init |
| **Proyecto** | `projects/chappie-infrastructure/` |

**Flujo de arranque:**
```
1. PC enciende → systemd inicia sesión de usuario
2. systemd --user ejecuta chappie-infra.service
3. docker compose up -d → n8n + RabbitMQ disponibles
4. chappie-daemon, chappie-notification, chappie-quickshell se conectan
```

---

## 1. Integraciones Síncronas (HTTP/REST)

### 1.1 chappie-daemon → n8n (Voice Capture Webhook)

| Aspecto | Detalle |
|---|---|
| **Tipo** | HTTP POST (Webhook) |
| **Endpoint** | `http://localhost:5678/webhook/chappie-voice-capture` |
| **Owner** | chappie-n8n-workflows |
| **Timeout** | 30 segundos |
| **Retry** | 3 intentos con backoff exponencial |
| **Auth** | Header `X-Webhook-Secret` |

**Request Payload:**
```json
{
  "audio_base64": "<base64-encoded-wav>",
  "timestamp": "2026-06-13T10:30:00Z",
  "session_id": "uuid-v4",
  "include_screen": false
}
```

**Response:**
```json
{
  "status": "accepted",
  "workflow_execution_id": "n8n-exec-id"
}
```

### 1.2 chappie-notification → n8n (Error Handler Webhook)

| Aspecto | Detalle |
|---|---|
| **Tipo** | HTTP POST (Webhook) |
| **Endpoint** | `http://localhost:5678/webhook/chappie-error-handler` |
| **Owner** | chappie-n8n-workflows |
| **Timeout** | 15 segundos |
| **Retry** | 2 intentos |

**Descripción del flujo:**
1. `chappie-notification (error_consumer)` envía el error a n8n.
2. n8n ejecuta el workflow "Error Handler":
   - Genera una nueva respuesta con el modelo de IA.
   - Publica el resultado directamente en la cola `chappie.tts.requests` (RabbitMQ).
   - NO devuelve el TTS en la respuesta HTTP.
3. `error_consumer` recibe confirmación de recepción y continúa.
4. `tts_consumer` recibe el mensaje de `chappie.tts.requests` y procesa normalmente.

**Request Payload:**
```json
{
  "original_request": "texto original del usuario",
  "error": "descripción del error",
  "context": "contexto adicional",
  "session_id": "uuid-v4"
}
```

**Response:**
```json
{
  "status": "accepted",
  "workflow_execution_id": "n8n-exec-id"
}
```

### 1.3 chappie-notification → chappie-daemon (TTS Playback and Audio Control)

| Aspecto | Detalle |
|---|---|
| **Tipo** | HTTP POST |
| **Endpoint** | `http://localhost:8765/play-tts` |
| **Owner** | chappie-daemon |
| **Timeout** | 5 segundos |
| **Retry** | No (fire-and-forget) |

**Descripción del flujo completo (gestionado por chappie-daemon):**
1. Recibe la solicitud con el archivo de audio y el texto.
2. Lee `tts-config.yaml` para la configuración de volume ducking.
3. Reduce el volumen al 10% en todos los sinks activos.
4. Escribe `"speaking"` en `/tmp/chappie_tts_state.txt`.
5. Reproduce el archivo de audio mediante PipeWire/WirePlumber.
6. Espera el fin de la reproducción.
7. Restaura el volumen original.
8. Escribe `"idle"` en `/tmp/chappie_tts_state.txt`.
9. Responde a chappie-notification con `{ "status": "success", "message": "Audio played successfully" }`.

**Request Payload:**
```json
{
  "audio_file": "/tmp/chappie_tts.mp3",
  "text": "texto que se está reproduciendo",
  "ducking": true
}
```

### 1.4 chappie-notification → OpenCode CLI (Agent Execution)

| Aspecto | Detalle |
|---|---|
| **Tipo** | subprocess (CLI) |
| **Comando** | `opencode run --agent <agent> "<prompt>"` |
| **Owner** | chappie-notification |
| **Timeout** | 120 segundos |
| **Retry** | No (se maneja via RabbitMQ) |

### 1.5 n8n → Gemini API (STT)

| Aspecto | Detalle |
|---|---|
| **Tipo** | HTTPS POST |
| **Endpoint** | `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent` |
| **Owner** | Google |
| **Timeout** | 20 segundos |
| **Retry** | 2 intentos |
| **Auth** | API Key en query param |

### 1.6 n8n → AI Provider API (Model Processing)

| Aspecto | Detalle |
|---|---|
| **Tipo** | HTTPS POST (OpenAI-compatible) |
| **Endpoints** | Configurable en providers.yaml |
| **Owner** | chappie-n8n-workflows |
| **Timeout** | 30 segundos |
| **Retry** | 2 intentos con fallback a otro proveedor |
| **Auth** | Bearer Token |

### 1.7 Hyprland keybinds → chappie-daemon (Shortcut Events)

| Aspecto | Detalle |
|---|---|
| **Tipo** | HTTP POST |
| **Endpoint (Press)** | `POST /shortcut/press` |
| **Endpoint (Release)** | `POST /shortcut/release` |
| **Owner** | chappie-daemon |
| **Timeout** | 2 segundos |
| **Retry** | No |
| **Trigger** | Hyprland keybind via `client.sh` |

**POST /shortcut/press — Descripción del flujo:**
1. Usuario presiona la tecla asignada en Hyprland.
2. `client.sh` envía `POST /shortcut/press` a chappie-daemon.
3. chappie-daemon inicia la grabación de audio.
4. Activa volume ducking (reduce volumen de otros sinks al 10%).
5. Escribe `"listening"` en `/tmp/chappie_state.txt`.
6. Responde con `{ "status": "recording" }`.

**POST /shortcut/release — Descripción del flujo:**
1. Usuario suelta la tecla asignada en Hyprland.
2. `client.sh` envía `POST /shortcut/release` a chappie-daemon.
3. chappie-daemon detiene la grabación de audio.
4. Restaura el volumen original (volume ducking off).
5. Envía el audio capturado a n8n (Voice Capture Webhook).
6. Responde con `{ "status": "processing" }`.

---

## 2. Integraciones Asíncronas (RabbitMQ)

### 2.1 Cola: chappie.responses

| Aspecto | Detalle |
|---|---|
| **Tipo** | Queue (point-to-point) |
| **Producer** | n8n (Voice Pipeline Workflow) |
| **Consumer** | chappie-notification (execution_consumer) |
| **Schema** | Ver abajo |
| **Durability** | Durable |
| **Ack** | Manual (after processing) |
| **DLQ** | chappie.responses.dlq |
| **TTL** | 60 segundos |
| **Idempotency** | session_id + timestamp |

**Schema:**
```json
{
  "session_id": "uuid-v4",
  "timestamp": "2026-06-13T10:30:00Z",
  "voice_response": "texto para dictar con personalidad de Chappie",
  "agent_call": {
    "enabled": false,
    "agent": "",
    "prompt": "",
    "notify_on_complete": true
  },
  "terminal_command": {
    "enabled": false,
    "command": "",
    "requires_confirmation": false
  },
  "notification": {
    "enabled": false,
    "title": "",
    "message": "",
    "urgency": "normal"
  },
  "memory_update": {
    "save_to_memory": true,
    "tags": []
  }
}
```

### 2.2 Cola: chappie.errors

| Aspecto | Detalle |
|---|---|
| **Tipo** | Queue (point-to-point) |
| **Producer** | chappie-notification (execution_consumer, tts_consumer) |
| **Consumer** | chappie-notification (error_consumer) |
| **Schema** | Ver abajo |
| **Durability** | Durable |
| **Ack** | Manual |
| **DLQ** | chappie.errors.dlq |
| **TTL** | 30 segundos |

**Schema:**
```json
{
  "session_id": "uuid-v4",
  "timestamp": "2026-06-13T10:30:00Z",
  "original_request": "texto original del usuario",
  "error_type": "agent_failure | command_failure | validation_error",
  "error": "descripción del error",
  "context": {
    "agent": "nombre del agente si aplica",
    "command": "comando si aplica"
  }
}
```

### 2.3 Cola: chappie.tts.requests

| Aspecto | Detalle |
|---|---|
| **Tipo** | Queue (point-to-point) |
| **Producer** | chappie-notification (execution_consumer, error_consumer), n8n (Error Handler Workflow) |
| **Consumer** | chappie-notification (tts_consumer) |
| **Schema** | Ver abajo |
| **Durability** | Durable |
| **Ack** | Manual |
| **Priority** | High (para respuestas de error) |
| **TTL** | 30 segundos |

**Schema:**
```json
{
  "session_id": "uuid-v4",
  "timestamp": "2026-06-13T10:30:00Z",
  "text": "texto para convertir a voz",
  "priority": "normal | high",
  "ducking": true,
  "show_text": true
}
```

### 2.4 Cola: chappie.agent.results

| Aspecto | Detalle |
|---|---|
| **Tipo** | Queue (point-to-point) |
| **Producer** | chappie-notification (execution_consumer) |
| **Consumer** | chappie-notification (notification_consumer) |
| **Schema** | Ver abajo |
| **Durability** | Durable |
| **Ack** | Manual |
| **TTL** | 300 segundos (5 min) |

**Schema:**
```json
{
  "session_id": "uuid-v4",
  "timestamp": "2026-06-13T10:30:00Z",
  "agent": "nombre del agente",
  "status": "success | failure",
  "result": "resultado de la ejecución",
  "notify_user": true
}
```

### 2.5 Cola: chappie.agent.questions

| Aspecto | Detalle |
|---|---|
| **Tipo** | Queue (point-to-point) |
| **Producer** | Agentes de OpenCode (via n8n) |
| **Consumer** | chappie-notification (notification_consumer) |
| **Schema** | Ver abajo |
| **Durability** | Durable |
| **Ack** | Manual |
| **TTL** | 600 segundos (10 min) |

**Schema:**
```json
{
  "session_id": "uuid-v4",
  "timestamp": "2026-06-13T10:30:00Z",
  "agent": "nombre del agente",
  "question": "pregunta para el usuario",
  "options": [
    {"key": "opt1", "label": "Opción 1"},
    {"key": "opt2", "label": "Opción 2"},
    {"key": "ignore", "label": "Ignorar"}
  ],
  "notification_id": "uuid-v4"
}
```

### 2.6 Cola: chappie.agent.answers

| Aspecto | Detalle |
|---|---|
| **Tipo** | Queue (point-to-point) |
| **Producer** | chappie-notification (notification_consumer) |
| **Consumer** | Agentes de OpenCode (via n8n) |
| **Schema** | Ver abajo |
| **Durability** | Durable |
| **Ack** | Manual |
| **Correlation** | notification_id |

**Schema:**
```json
{
  "notification_id": "uuid-v4",
  "session_id": "uuid-v4",
  "timestamp": "2026-06-13T10:30:00Z",
  "answer": "respuesta seleccionada por el usuario"
}
```

### 2.7 Cola: chappie.notifications

| Aspecto | Detalle |
|---|---|
| **Tipo** | Queue (fanout para múltiples consumidores) |
| **Producer** | n8n, chappie-notification |
| **Consumer** | chappie-notification (notification_consumer) |
| **Schema** | Ver abajo |
| **Durability** | Durable |
| **Ack** | Manual |
| **TTL** | 120 segundos |

**Schema:**
```json
{
  "timestamp": "2026-06-13T10:30:00Z",
  "title": "título de la notificación",
  "message": "mensaje de la notificación",
  "urgency": "low | normal | critical",
  "actions": [
    {"key": "action1", "label": "Acción 1"},
    {"key": "dismiss", "label": "Cerrar"}
  ],
  "category": "agent_complete | error | info | question"
}
```

---

## 3. Integraciones por Archivo de Estado

### 3.1 chappie-notification → chappie-quickshell (TTS Text)

| Aspecto | Detalle |
|---|---|
| **Tipo** | File-based state |
| **Archivo** | `/tmp/chappie_tts_text.txt` |
| **Writer** | chappie-notification (tts_consumer) |
| **Reader** | chappie-quickshell (ChappieTextWidget) |
| **Format** | Texto plano |
| **Sync** | FileView de Quickshell (watch file changes) |

### 3.2 chappie-daemon → chappie-quickshell (TTS State)

| Aspecto | Detalle |
|---|---|
| **Tipo** | File-based state |
| **Archivo** | `/tmp/chappie_tts_state.txt` |
| **Writer** | chappie-daemon (POST /play-tts handler) |
| **Reader** | chappie-quickshell (ChappieTextWidget) |
| **Values** | "speaking" | "idle" |
| **Sync** | FileView de Quickshell |

### 3.3 chappie-daemon → chappie-quickshell (Text Toggle)

| Aspecto | Detalle |
|---|---|
| **Tipo** | File-based state |
| **Archivo** | `/tmp/chappie_text_enabled.txt` |
| **Writer** | chappie-daemon (client.sh TOGGLE_TEXT) |
| **Reader** | chappie-quickshell (ChappieTextWidget) |
| **Values** | "true" | "false" |
| **Sync** | FileView de Quickshell |

### 3.4 chappie-daemon → chappie-quickshell (Daemon State)

| Aspecto | Detalle |
|---|---|
| **Tipo** | File-based state |
| **Archivo** | `/tmp/chappie_state.txt` |
| **Writer** | chappie-daemon |
| **Reader** | chappie-quickshell (ChappieStatusWidget) |
| **Values** | "idle" | "listening" | "thinking" | "working" | "speaking" |
| **Sync** | FileView de Quickshell |

---

## 4. Contratos de Configuración (YAML)

### 4.1 providers.yaml

Existen dos versiones del archivo `providers.yaml` para contextos distintos:

**A. `chappie-config/providers.yaml`** — Configuración detallada para el ecosistema Chappie:
```yaml
llm_providers:
  opencode:
    display_name: "OpenCode API"
    base_url: "https://api.opencode.ai/v1"
    auth_type: bearer_token
    auth_env_var: "OPENCODE_API_KEY"
    priority: 1
    models:
      deepseek-v4-flash:
        display_name: "DeepSeek V4 Flash"
        context_window: 128000
        default_temperature: 0.7
      qwen3.6-plus-free:
        display_name: "Qwen 3.6 Plus"
        context_window: 128000
        default_temperature: 0.8
      mimo-v2.5:
        display_name: "Mimo V2.5"
        context_window: 64000
        default_temperature: 0.7
  gemini:
    display_name: "Google Gemini API"
    base_url: "https://generativelanguage.googleapis.com/v1beta"
    auth_type: api_key
    auth_env_var: "GEMINI_API_KEY"
    priority: 2
    models:
      gemini-2.5-flash:
        display_name: "Gemini 2.5 Flash"
        context_window: 256000
        supports_audio: true
      gemini-2.5-flash-lite:
        display_name: "Gemini 2.5 Flash Lite"
        context_window: 128000
stt:
  provider: gemini
  model: gemini-2.5-flash
  audio:
    format: "wav"
    sample_rate: 16000
    channels: 1
  fallback:
    provider: whisper
    model: base
opencode_cli:
  binary: "opencode"
  default_timeout_ms: 120000
task_routing:
  default:
    provider: opencode
    model: deepseek-v4-flash
  orchestration:
    provider: opencode
    model: qwen3.6-plus-free
```

**B. `chappie-n8n-workflows/config/providers.yaml`** — Configuración simplificada para n8n:
```yaml
providers:
  stt:
    primary: "gemini"
    gemini:
      api_key_env: "GEMINI_API_KEY"
      model: "gemini-2.5-flash"
      endpoint: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
      timeout_seconds: 20
      max_retries: 2
  processing:
    primary: "opencode"
    fallback_order:
      - "opencode"
      - "gemini"
    opencode:
      endpoint: "http://localhost:3000/api/v1/chat/completions"
      models:
        - "opencode/deepseek-v4-flash-free"
        - "opencode/mimo-v2.5-free"
        - "opencode/qwen3.6-plus-free"
      timeout_seconds: 30
      max_retries: 2
    gemini:
      api_key_env: "GEMINI_API_KEY"
      model: "gemini-2.5-flash"
      timeout_seconds: 30
      max_retries: 2
  rabbitmq:
    host: "chappie-rabbitmq"
    port: 5672
    username_env: "RABBITMQ_USER"
    password_env: "RABBITMQ_PASSWORD"
    virtual_host: "/"
```

Ambas versiones son válidas para sus respectivos contextos: la de `chappie-config` ofrece control granular para el ecosistema general, mientras que la de `chappie-n8n-workflows` está optimizada para el consumo directo desde los workflows de n8n.

### 4.2 tts-config.yaml

```yaml
tts:
  volume_ducking:
    enabled: true
    target_percent: 10
    restore_after: true
    all_sinks: true
  
  display:
    show_text: true
    text_position: "top-right"
    text_duration: 5
  
  provider: "edge-tts"
  voice: "es-AR-ElenaNeural"
```

### 4.3 commands-whitelist.yaml

```yaml
allowed_commands:
  - pattern: "systemctl poweroff"
  - pattern: "systemctl reboot"
  - pattern: "systemctl suspend"
  - pattern: "wpctl set-volume *"
  - pattern: "wpctl set-mute *"
  - pattern: "brightnessctl set *"
  - pattern: "playerctl *"
  - pattern: "notify-send *"
  - pattern: "grim *"
  - pattern: "wl-copy *"
  - pattern: "wl-paste"
  - pattern: "hyprctl dispatch *"
  - pattern: "gtk-launch *"
  - pattern: "xdg-open *"
  - pattern: "curl *"
  - pattern: "ls *"
  - pattern: "cat *"
  - pattern: "glow *"
  - pattern: "bat *"

denied_commands:
  - pattern: "rm -rf /*"
  - pattern: "mkfs *"
  - pattern: "dd *"
  - pattern: "chmod 777 *"
  - pattern: "* | sh"
```

---

## 5. SLA/SLO

| Integración | SLA (Latencia) | SLO (Disponibilidad) |
|---|---|---|
| STT (Gemini) | < 5s | 99% |
| Model Processing | < 15s | 95% |
| TTS (Edge-TTS) | < 3s | 99% |
| RabbitMQ | < 100ms | 99.9% |
| n8n Webhook | < 1s | 99% |
| OpenCode CLI | < 120s | 90% |

---

## 6. Idempotencia

| Integración | Estrategia |
|---|---|
| Voice Webhook | session_id + timestamp |
| RabbitMQ Messages | message_id (UUID) |
| Agent Execution | session_id + agent_name |
| TTS Generation | session_id + text_hash |

---

*Documento mantenido por: Enterprise Architect*  
*Próxima revisión: Al completar Fase 1*
