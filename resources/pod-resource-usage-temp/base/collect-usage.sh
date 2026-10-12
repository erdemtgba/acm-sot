#!/bin/bash
# Dumps pod CPU/memory usage for all namespaces into a timestamped CSV.
set -euo pipefail
out="/reports/pod-usage-$(date +%Y%m%d-%H%M).csv"
echo "namespace,pod,cpu,memory" > "$out"
oc adm top pods -A --no-headers | awk '{print $1","$2","$3","$4}' >> "$out"
find /reports -name 'pod-usage-*.csv' -mtime +"${RETENTION_DAYS:-3}" -delete
echo "written $out"
