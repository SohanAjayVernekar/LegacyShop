#!/usr/bin/env bash
set -u

echo "========== LEGACYSHOP ENV CHECK =========="
echo
echo "[OS]"
cat /etc/os-release | grep -E '^(PRETTY_NAME|VERSION_CODENAME)=' || true

echo
echo "[Mono]"
mono --version | head -n 3 || true

echo
echo "[C# compiler]"
command -v csc || command -v mcs || true
(csc -version 2>/dev/null || mcs --version 2>/dev/null) || true

echo
echo "[Build tools]"
command -v msbuild || true
command -v xbuild || true
(msbuild -version 2>/dev/null | head -n 2 || true)
(xbuild /version 2>/dev/null | head -n 4 || true)

echo
echo "[Docker]"
docker --version || sudo docker --version || true
docker compose version || sudo docker compose version || true

echo
echo "==========================================="
