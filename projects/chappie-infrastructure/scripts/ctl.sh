#!/usr/bin/env bash
# ============================================
# Chappie Infrastructure - Start / Stop Helper
# ============================================
# Inicia o detiene los servicios según el argumento.
#
# Uso:
#   ./ctl.sh start    → Inicia todos los servicios
#   ./ctl.sh stop     → Detiene todos los servicios
#   ./ctl.sh restart  → Reinicia todos los servicios
#   ./ctl.sh status   → Muestra el estado
#   ./ctl.sh logs     → Muestra logs en tiempo real
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="${PROJECT_DIR}/docker-compose.yaml"

cd "${PROJECT_DIR}"

case "${1:-status}" in
  start)
    echo "▶ Iniciando servicios de Chappie..."
    docker compose -f "${COMPOSE_FILE}" up -d
    echo "✓ Servicios iniciados"
    docker compose -f "${COMPOSE_FILE}" ps
    ;;

  stop)
    echo "■ Deteniendo servicios de Chappie..."
    docker compose -f "${COMPOSE_FILE}" down
    echo "✓ Servicios detenidos"
    ;;

  restart)
    echo "↻ Reiniciando servicios de Chappie..."
    docker compose -f "${COMPOSE_FILE}" down
    docker compose -f "${COMPOSE_FILE}" up -d
    echo "✓ Servicios reiniciados"
    docker compose -f "${COMPOSE_FILE}" ps
    ;;

  status)
    echo "📊 Estado de servicios:"
    docker compose -f "${COMPOSE_FILE}" ps
    echo ""
    echo "Endpoints:"
    echo "  n8n:       http://localhost:5678"
    echo "  RabbitMQ:  http://localhost:15672"
    ;;

  logs)
    echo "📜 Logs (Ctrl+C para salir):"
    docker compose -f "${COMPOSE_FILE}" logs -f --tail=100
    ;;

  *)
    echo "Uso: ./ctl.sh {start|stop|restart|status|logs}"
    exit 1
    ;;
esac
