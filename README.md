# Larkspur Retail Group — Endpoint Security Lab
### B9CY110 Communication and Network Security | MSc Cybersecurity Assessment

---

## Overview

This repository contains all artefacts for the B9CY110 Endpoint Security Assessment. The project builds a controlled Azure lab that simulates a breach against a fictitious retail organisation (Larkspur Retail Group), detects attacker techniques using Wazuh SIEM, and automates alert triage using a Dockerised AI stack (Ollama Phi-3).

---

## Lab Architecture

| Component | Details |
|-----------|---------|
| Wazuh Manager (SIEM) | Ubuntu 24.04 — Azure D2s v3 — IP 4.233.137.30 |
| Linux Endpoint | Ubuntu 24.04 — Azure B2ats v2 — IP 172.17.4.4 — Agent 001 |
| Windows Endpoint | Windows Server 2025 — Azure B2ats v2 — IP 172.17.1.4 — Agent 002 |
| AI Stack | Ollama Phi-3 + Python triage script — Dockerised on Wazuh Manager |

All VMs run in Azure France Central on the same virtual network (`vnet-francecentral-1`).

---

## Repository Structure

```
larkspur-endpoint-security/
├── breach_demo.sh          # 5-phase Linux breach simulation script
├── triage_ai.py            # AI alert triage — monitors Wazuh alerts, calls Ollama Phi-3
├── Dockerfile              # Docker build file for ai-security-stack container
├── local_rules.xml         # 5 custom Wazuh detection rules mapped to MITRE ATT&CK
└── README.md               # This file
```

---

## Files Explained

### `breach_demo.sh`
Runs a 5-phase automated attack simulation on the Linux endpoint:

| Phase | Technique | ATT&CK | Wazuh Rule |
|-------|-----------|--------|------------|
| 1 | SSH brute force (8 attempts) | T1110 | 100006 |
| 2 | Sudo privilege escalation (whoami) | T1548.003 | 5402 built-in |
| 3 | Network reconnaissance (ss -antp) | T1016 | 100003 |
| 4 | User enumeration (cat /etc/passwd) | T1087 | 100005 |
| 5 | Shadow file access (cat /etc/shadow) | T1003.008 | 100002 |

No real malware is used. All actions are benign and fully reversible.

**To run:**
```bash
chmod +x breach_demo.sh
sudo ./breach_demo.sh
```

**To roll back:**
```bash
sudo rm -f /root/hidden_malware.sh
sudo rm -f /etc/cron.d/backdoor
sudo rm -f /bin/malware_test_file
echo "Rollback complete"
```

---

### `local_rules.xml`
Five custom Wazuh detection rules. Place this file at:
```
/var/ossec/etc/rules/local_rules.xml
```
Then restart the Wazuh manager:
```bash
sudo systemctl restart wazuh-manager
```

Rules summary:

| Rule ID | Level | Description | MITRE |
|---------|-------|-------------|-------|
| 100002 | 12 | Shadow file read via sudo | T1003.008 |
| 100003 | 10 | Network recon via sudo (ss -antp) | T1016 |
| 100004 | 13 | Encoded PowerShell (-EncodedCommand) | T1059.001 / T1027 |
| 100005 | 8 | User enumeration via sudo | T1087 |
| 100006 | 12 | SSH brute force (5+ failures in 60s) | T1110 |

---

### `triage_ai.py`
Monitors the Wazuh alerts JSON log in real time. When an alert at rule level 7 or above appears, it sends the alert description to a locally running Ollama Phi-3 model and writes the AI recommendation to `/tmp/remediation_final.log`.

**Requirements:**
- Ollama installed and running: `ollama serve`
- Phi-3 model pulled: `ollama pull phi3`
- Python 3 with requests library: `pip3 install requests`

**To run:**
```bash
python3 triage_ai.py
```

**Output example:**
```
[!] ALERT 1/3: CRITICAL: Unauthorized attempt to read shadow file
[AI REMEDIATION]: Immediately restrict sudo access for the luqative account
and audit all recent privilege escalation activity on this host.
```

---

### `Dockerfile`
Builds the `ai-security-stack` Docker image containing the triage_ai.py script.

**To build:**
```bash
sudo docker build -t ai-security-stack .
```

**To run:**
```bash
sudo docker run --network=host ai-security-stack
```

The container uses `python:3.9-slim` as the base image. It has no privileged access and cannot execute system commands — the AI output is advisory only.

---

## How to Reproduce the Full Demo

1. Start the AI analyst on the Wazuh Manager (Terminal 1):
```bash
python3 triage_ai.py
```

2. SSH into the Linux endpoint and run the breach simulation (Terminal 2):
```bash
sudo ./breach_demo.sh
```

3. On the Windows endpoint, run the encoded PowerShell attack (Terminal 3):
```powershell
powershell.exe -e JAB3AGMAPQBOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ADsA
```

4. Open Wazuh Dashboard at `https://4.233.137.30` and filter detections:
```
rule.id: 100002
rule.id: 100003
rule.id: 100005
rule.id: 100006
rule.level: 15
```

5. Check the AI remediation log:
```bash
cat /tmp/remediation_final.log
```

---

## MITRE ATT&CK Coverage

| Technique | Name | Tactic | Detected By |
|-----------|------|--------|-------------|
| T1110 | Brute Force | Credential Access | Rule 100006 |
| T1548.003 | Sudo Abuse | Privilege Escalation | Built-in 5402 |
| T1016 | System Network Discovery | Discovery | Rule 100003 |
| T1087 | Account Discovery | Discovery | Rule 100005 |
| T1003.008 | Shadow File Dumping | Credential Access | Rule 100002 |
| T1059.001 | PowerShell Execution | Execution | Rule 100004 |
| T1027 | Obfuscated Files | Defense Evasion | Rule 100004 |

---

## Safety and Ethics

- No real malware was used at any point
- All simulations use benign commands with no destructive payloads
- The lab is fully isolated within Azure — no attack tools were exposed to public networks
- The AI component is read-only and advisory — it cannot execute system commands
- All simulation artefacts are reversible (see rollback commands above)

---

## Module Information

- **Module:** B9CY110 — Communication and Network Security
- **Programme:** MSc Cybersecurity
- **Assessment:** Endpoint Security Assessment (CA1, 60%)
- **SIEM Platform:** Wazuh 4.14.3
- **AI Model:** Ollama Phi-3 (local inference)
