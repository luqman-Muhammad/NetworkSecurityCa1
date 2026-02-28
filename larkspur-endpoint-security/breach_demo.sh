#!/bin/bash
# Larkspur Retail Group - Automated Breach Simulation
# Designed for B9CY110 Assessment - MSc Cybersecurity
echo "--- STARTING LARKSPUR BREACH SIMULATION ---"
# 1. INITIAL ACCESS: Brute Force Simulation (Rule 100006)
echo "[*] Phase 1: Simulating SSH Brute Force attack (Automated)..."
for i in {1..8}; do
    # BatchMode=yes skips password prompts to keep the script automated
    ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no -o BatchMode=yes invalid_user@localhost 2>/dev/null
done
sleep 2
# 2. PRIVILEGE ESCALATION: Sudo Usage (Rule 5402)
echo "[*] Phase 2: Escalating privileges via Sudo..."
sudo whoami
sleep 2
# 3. DISCOVERY: Network Reconnaissance (Rule 100003)
echo "[*] Phase 3: Performing network interface discovery..."
sudo ss -antp
sleep 2
# 4. DISCOVERY: User Enumeration (Rule 100005)
echo "[*] Phase 4: Enumerating system users..."
sudo cat /etc/passwd > /dev/null
sleep 2
# 5. CREDENTIAL ACCESS: Shadow File Access (Rule 100002)
echo "[*] Phase 5: Attempting to read sensitive system files (Shadow)..."
sudo cat /etc/shadow > /dev/null
echo "--- BREACH SIMULATION COMPLETE: REVIEW WAZUH DASHBOARD ---"
