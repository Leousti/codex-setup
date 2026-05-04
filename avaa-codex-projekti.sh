#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")"

open_in_terminal() {
  local quoted_script
  quoted_script=$(printf '%q' "${SCRIPT_PATH}")

  if command -v x-terminal-emulator >/dev/null 2>&1; then
    x-terminal-emulator -e bash -lc "${quoted_script} --inside-terminal"
    exit 0
  fi

  if command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal -- bash -lc "${quoted_script} --inside-terminal"
    exit 0
  fi

  if command -v xfce4-terminal >/dev/null 2>&1; then
    xfce4-terminal --command="bash -lc ${quoted_script}\ --inside-terminal"
    exit 0
  fi

  if command -v konsole >/dev/null 2>&1; then
    konsole -e bash -lc "${quoted_script} --inside-terminal"
    exit 0
  fi
}

if [[ "${1:-}" != "--inside-terminal" && ( ! -t 0 || ! -t 1 ) ]]; then
  open_in_terminal
fi

if [[ "${1:-}" == "--inside-terminal" ]]; then
  shift
fi

while true; do
  read -r -p "Anna juurikansio /home/ alta (esim. 'codex-projektit', jolloin kansio on sijainnissa /home/<user>/codex-projektit): " TARGET_INPUT

  if [[ -z "${TARGET_INPUT// }" ]]; then
    echo "Juurikansio ei voi olla tyhjä. Yritä uudelleen."
    continue
  fi

  if [[ "${TARGET_INPUT}" == /home/* ]]; then
    TARGET_ROOT="${TARGET_INPUT}"
    TARGET_NAME="$(basename "${TARGET_INPUT}")"
  elif [[ "${TARGET_INPUT}" == /* ]]; then
    echo "Anna polku /home/ alta. Yritä uudelleen."
    continue
  else
    TARGET_ROOT="/home/${USER}/${TARGET_INPUT}"
    TARGET_NAME="${TARGET_INPUT}"
  fi

  if [[ ! -d "${TARGET_ROOT}" ]]; then
    echo "Haluamaasi kansiota (${TARGET_NAME}) ei vielä ole luotu! Yritä uudelleen."
    continue
  fi

  break
done

mapfile -t PROJECT_DIRS < <(
  find "${TARGET_ROOT}" -mindepth 1 -maxdepth 1 -type d | sort | while read -r dir; do
    if [[ -f "${dir}/AGENTS.md" && -f "${dir}/NOW.md" && -f "${dir}/CHECKPOINTS.md" && -f "${dir}/codex_READMEFIRST.md" ]]; then
      echo "${dir}"
    fi
  done
)

if [[ ${#PROJECT_DIRS[@]} -eq 0 ]]; then
  echo "Kelvollisia Codex-projekteja ei löytynyt kansiosta: ${TARGET_ROOT}"
  exit 1
fi

echo
echo "Löydetyt projektit:"
for i in "${!PROJECT_DIRS[@]}"; do
  printf "%d. %s\n" "$((i + 1))" "$(basename "${PROJECT_DIRS[$i]}")"
done

while true; do
  echo
  read -r -p "Valitse avattava projekti numerolla: " SELECTION

  if [[ ! "${SELECTION}" =~ ^[0-9]+$ ]]; then
    echo "Anna projektin numero."
    continue
  fi

  if (( SELECTION < 1 || SELECTION > ${#PROJECT_DIRS[@]} )); then
    echo "Valinta ei ole listalla."
    continue
  fi

  break
done

PROJECT_DIR="${PROJECT_DIRS[$((SELECTION - 1))]}"

cd "${PROJECT_DIR}"

echo
echo "Projekti avattu: ${PROJECT_DIR}"
echo "Nykyinen sijainti:"
pwd
echo
echo "Seuraavat askeleet tässä kansiossa:"
echo "1. Käynnistä Codex komennolla: 'codex-dev', tai 'codex'"
echo "2. Kun Codex käynnistynyt: kirjoita: <Missä mennään?>"
echo "3. Muista session lopuksi ennen sulkemist kirjoittaa codexille vielä esim. lopetellaan' jotta .md tiedostot päivittyvät seuraavaa kertaa varten."
echo
echo "Tämä terminaali jää auki tähän projektikansioon."
echo

exec bash -i
