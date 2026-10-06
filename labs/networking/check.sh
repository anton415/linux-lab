#!/usr/bin/env bash
host="${1:-example.com}"
port="${2:-80}"
url="http://$host:$port/"

if getent ahostsv4 "$host" >/dev/null; then
	echo "DNS OK: $host"
else
	echo "DNS FAIL: $host"
	exit 1
fi

if curl --noproxy '*' -fsS -o /dev/null \
    --connect-timeout 3 --max-time 5 "$url"; then
	echo "HTTP OK: $url"
	exit 0
else
	echo "HTTP FAIL: $url"
	exit 1
fi
