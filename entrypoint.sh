#!/bin/bash
# Larkspur Retail Group - Wazuh Linux Agent Entrypoint
# Starts the Wazuh agent and keeps the container alive

set -e

echo "=========================================="
echo " LARKSPUR WAZUH LINUX AGENT STARTING"
echo "=========================================="
echo "Manager: ${WAZUH_MANAGER:-4.233.137.30}"
echo "Agent Name: ${WAZUH_AGENT_NAME:-linix-agent-docker}"
echo "=========================================="

# Set manager IP from environment variable if provided
if [ -n "$WAZUH_MANAGER" ]; then
    sed -i "s/<address>.*<\/address>/<address>${WAZUH_MANAGER}<\/address>/" \
        /var/ossec/etc/ossec.conf
    echo "[OK] Manager address set to: $WAZUH_MANAGER"
fi

# Set agent name if provided
if [ -n "$WAZUH_AGENT_NAME" ]; then
    sed -i "s/<agent_name>.*<\/agent_name>/<agent_name>${WAZUH_AGENT_NAME}<\/agent_name>/" \
        /var/ossec/etc/ossec.conf
    echo "[OK] Agent name set to: $WAZUH_AGENT_NAME"
fi

# Start Wazuh agent
echo "[*] Starting Wazuh agent..."
/var/ossec/bin/ossec-control start

echo "[OK] Wazuh agent started"
echo "[*] Agent is running — tailing logs..."

# Keep container alive and stream agent logs
tail -f /var/ossec/logs/ossec.log
