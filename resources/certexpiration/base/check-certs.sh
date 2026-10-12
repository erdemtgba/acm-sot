#!/bin/bash
# Lists TLS secrets that expire within THRESHOLD_DAYS.
set -euo pipefail
THRESHOLD_DAYS="${THRESHOLD_DAYS:-30}"
threshold=$(( $(date +%s) + THRESHOLD_DAYS * 86400 ))
oc get secrets -A --field-selector type=kubernetes.io/tls \
  -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{" "}{.data.tls\.crt}{"\n"}{end}' |
while read -r ns name crt; do
  [ -z "$crt" ] && continue
  end=$(echo "$crt" | base64 -d | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2) || continue
  if [ "$(date -d "$end" +%s)" -lt "$threshold" ]; then
    echo "EXPIRING ns=$ns secret=$name notAfter=\"$end\""
  fi
done
