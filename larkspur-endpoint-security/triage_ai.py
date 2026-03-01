import json
import requests
import subprocess

# Path to Wazuh alerts
ALERTS_PATH = "/var/ossec/logs/alerts/alerts.json"
OLLAMA_URL = "http://localhost:11434/api/generate"

def get_ai_response(alert_text):
    payload = {
        "model": "phi3",
        "prompt": f"Analyze this security alert and provide a 1-sentence remediation: {alert_text}",
        "stream": False
    }
    try:
        response = requests.post(OLLAMA_URL, json=payload, timeout=60)
        return response.json().get('response', 'No response.')
    except:
        return "AI Connection Error. Check if 'ollama serve' is running."

def monitor_logs():
    print("--- AI SOC ANALYST: WAITING FOR 5 UNIQUE REMEDIATIONS ---")
    seen_alerts = set()
    count = 0

    # tail -n 0 tells it to only look at NEW alerts from now
    command = f"tail -n 0 -F {ALERTS_PATH}"
    p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)

    while count < 5:
        line = p.stdout.readline().decode('utf-8')
        if not line:
            continue

        try:
            alert = json.loads(line)
            level = int(alert.get("rule", {}).get("level", 0))
            desc = alert.get("rule", {}).get("description", "")

            # Level 7+ catches brute force, shadow access, and PowerShell
            if level >= 7 and desc not in seen_alerts:
                count += 1
                seen_alerts.add(desc)

                print(f"\n[!] ALERT {count}/5: {desc}")
                print("[*] Consulting AI Analyst...")

                recommendation = get_ai_response(desc)
                print(f"[AI REMEDIATION]: {recommendation}")

                # Save to log file for project evidence
                with open("/tmp/remediation_final.log", "a") as f:
                    f.write(f"--- REMEDY {count}/5 ---\n")
                    f.write(f"Alert: {desc}\n")
                    f.write(f"AI Remedy: {recommendation}\n\n")
        except:
            continue

    print("\n--- GOAL REACHED: 5 REMEDIATIONS COMPLETED ---")
    print("Final log saved to: /tmp/remediation_final.log")
    p.terminate()

if __name__ == "__main__":
    monitor_logs()
