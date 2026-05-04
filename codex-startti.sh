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

read -r -p "Anna kohdehakemisto /home/ alta (esim. 'codex-projektit', jolloin kansio luodaan sijaintiin /home/<user>/codex-projektit/): " TARGET_INPUT

if [[ -z "${TARGET_INPUT// }" ]]; then
  echo "Kohdehakemisto ei voi olla tyhjä."
  exit 1
fi

if [[ "${TARGET_INPUT}" == /home/* ]]; then
  TARGET_ROOT="${TARGET_INPUT}"
elif [[ "${TARGET_INPUT}" == /* ]]; then
  echo "Anna polku /home/ alta."
  exit 1
else
  TARGET_ROOT="/home/${USER}/${TARGET_INPUT}"
fi

mkdir -p "${TARGET_ROOT}"
cd "${TARGET_ROOT}"

read -r -p "Mikä nimi projektille annetaan? " PROJECT_NAME

if [[ -z "${PROJECT_NAME// }" ]]; then
  echo "Projektin nimi ei voi olla tyhjä."
  exit 1
fi

PROJECT_DIR="${TARGET_ROOT}/${PROJECT_NAME}"
SAFE_PROJECT_NAME="${PROJECT_NAME// /_}"
PROJECT_FILE_NAME="${SAFE_PROJECT_NAME}.md"

if [[ -e "${PROJECT_DIR}" ]]; then
  echo "Projektikansio on jo olemassa: ${PROJECT_DIR}"
  exit 1
fi

mkdir -p "${PROJECT_DIR}"

cat > "${PROJECT_DIR}/AGENTS.md" <<EOF
# AGENTS.md

## Tarkoitus

Tämä kansio on vain projektia \`${PROJECT_NAME}\` varten.

Tarkoituksesi on auttaa käyttäjää edistämään tätä projektia, pitää kirjaa siitä mitä on keskusteltu ja vähentää tarvetta selittää sama tausta uudelleen tulevissa sessioissa.

## Toimintaperiaatteet

1. Pidä kirjaa kaikesta mitä tässä sessiossa työstetään tiedostossa \`NOW.md\`.
2. Päivitä oletusarvoisesti \`${PROJECT_FILE_NAME}\`, \`NOW.md\` ja \`CHECKPOINTS.md\` jokaisen session jälkeen.
3. Älä oleta, että vanhat chat-ketjut ovat aina saatavilla. Kirjaa päätökset, ehdotukset, palaute, suunnitelmat, tuotokset ja tärkeä konteksti tiedostoon \`${PROJECT_FILE_NAME}\` tai muuhun siihen viitattuun markdown-tiedostoon.
4. Jos annat listan ideoita, vaihtoehtoja, vaiheita, suunnitelmia tai suosituksia, kirjaa koko sisältö projektin tiedostoihin.
5. Jos on epäselvää pitääkö jokin asia kirjata projektin tiedostoihin, kysy käyttäjältä.
6. Kirjaa jokainen keskeinen vaihe ja päätös tiedostoon \`CHECKPOINTS.md\` käänteisessä aikajärjestyksessä päivämäärän ja kellonajan kanssa.
7. Jos käyttäjä sanoo \`Where are we at?\`, anna tämän projektin tilannepäivitys tiedostojen \`NOW.md\`, \`CHECKPOINTS.md\` ja \`${PROJECT_FILE_NAME}\` perusteella.
8. Jos käyttäjä sanoo \`That’s all for now.\`, päätä nykyinen sessio ja päivitä \`${PROJECT_FILE_NAME}\`, \`NOW.md\` ja \`CHECKPOINTS.md\`.
9. Keskity vain tähän projektikansioon ja sen omiin tiedostoihin, ellei käyttäjä erikseen pyydä muuta.

## Tiedostot

- \`AGENTS.md\`: projektikohtaiset toimintaohjeet
- \`NOW.md\`: nykyisen session fokus ja seuraavat askeleet
- \`CHECKPOINTS.md\`: käänteinen loki keskeisistä vaiheista ja päätöksistä
- \`${PROJECT_FILE_NAME}\`: projektin päämuisti pitkälle aikavälille
- Muita tiedostoja voi lisätä, jos tarkemmat muistiinpanot, suunnitelmat, luonnokset, koodi, tutkimus tai materiaalit vaativat erillisen tiedoston

## Session kulku

Session alussa:

1. Lue \`AGENTS.md\`, \`NOW.md\`, \`CHECKPOINTS.md\` ja \`${PROJECT_FILE_NAME}\`.
2. Käytä olemassa olevaa kansiorakennetta lähtökohtana.
3. Kysy käyttäjältä mitä hän haluaa tehdä nyt, jos välitön tavoite ei ole ilmeinen.

Session aikana:

1. Pidä muistiinpanot ajan tasalla, kun päätöksiä tehdään.
2. Kirjaa tärkeät tuotokset riittävän yksityiskohtaisesti, jotta projektia voi jatkaa ilman chat-historiaa.
3. Kysy jatkokysymykset yksi kerrallaan, jotta käyttäjä ei kuormitu.

Session lopussa:

1. Päivitä \`${PROJECT_FILE_NAME}\`.
2. Päivitä \`NOW.md\` nykyisellä fokuksella ja seuraavilla askeleilla.
3. Lisää uusi käänteinen merkintä tiedostoon \`CHECKPOINTS.md\`.
EOF

cat > "${PROJECT_DIR}/NOW.md" <<EOF
# NOW

Viimeksi päivitetty: $(date '+%Y-%m-%d %H:%M %Z')

## Nykyinen sessio

- Projektikansio luotu.
- Projektin alkurakenne valmis.

## Nykyinen fokus

- Odottaa käyttäjän ensimmäistä projektikuvausta.

## Seuraavat askeleet

- Kuvaa mistä projektissa on kyse.
- Määrittele haluttu lopputulos.
- Kirjaa mitä on jo tehty.
- Lisää tarvittaessa olennaisia tiedostoja.
EOF

cat > "${PROJECT_DIR}/CHECKPOINTS.md" <<EOF
# CHECKPOINTS

## $(date '+%Y-%m-%d %H:%M %Z')

- Luotiin projektikansio \`${PROJECT_NAME}\`.
- Lisättiin \`AGENTS.md\`, \`NOW.md\`, \`CHECKPOINTS.md\`, \`codex_READMEFIRST.md\` ja \`${PROJECT_FILE_NAME}\`.
- Projektin alkurakenne valmis.
EOF

cat > "${PROJECT_DIR}/${PROJECT_FILE_NAME}" <<EOF
# PROJECT

## Projektin nimi

${PROJECT_NAME}

## Kuvaus

Kuvausta ei ole vielä annettu.

## Tavoiteltu lopputulos

Ei vielä kirjattu.

## Nykytila

Projektikansio on luotu. Odottaa ensimmäistä projektikuvausta.

## Keskeiset päätökset

- Tätä tiedostoa käytetään projektin päämuistina pitkällä aikavälillä.

## Seuraavat askeleet

- Kirjaa mistä projektissa on kyse.
- Kirjaa haluttu lopputulos.
- Kirjaa mitä on jo tehty.
- Päätä pitääkö tähän kansioon lisätä tiedostoja.

## Avoimet kysymykset

- Mistä tässä projektissa on kyse?
- Mitä valmius tarkoittaa tässä projektissa?
- Mitä on jo tehty?
- Pitääkö tähän lisätä tiedostoja nyt?

## Session muistiinpanot

### $(date '+%Y-%m-%d')

- Projektikansio ja aloitusseurannan tiedostot luotu.
EOF

cat > "${PROJECT_DIR}/codex_READMEFIRST.md" <<'EOF'
# codexille aloitusohjeet

```text
Haluan käyttää Codexia apuna tässä projektissa. Tämä voi olla koodausprojekti tai ei-koodausprojekti.

Tämän kansion projektirakenne on jo luotu valmiiksi. Käytä olemassa olevaa rakennetta lähtökohtana ja työskentele sen sisällä.

Tässä projektikansiossa on jo valmiiksi seuraavat tiedostot:
- `AGENTS.md`
- `NOW.md`
- `CHECKPOINTS.md`
- `__PROJECT_FILE_NAME__`

Aloita lukemalla nämä tiedostot ja käyttämällä niitä, älä luo niitä uudelleen.

Noudata tiedoston `AGENTS.md` sääntöjä ja työnkulkua.

Käytä tiedostoa `__PROJECT_FILE_NAME__` projektin pitkän aikavälin päämuistina, `NOW.md` tiedostoa nykyisen session fokukseen ja `CHECKPOINTS.md` tiedostoa keskeisten vaiheiden ja päätösten käänteiseen lokiin.

Säilytä olemassa oleva kansiorakenne ja rakenna sen päälle.

Kysy minulta seuraavaksi:
1. mistä tässä projektissa on kyse
2. mikä on haluttu lopputulos
3. mitä on jo tehty
4. haluanko lisätä tiedostoja, jotta pääset nopeammin kärryille

Kysy jatkokysymykset yksi kerrallaan, jotta en kuormitu liikaa.
```
EOF

sed -i "s/__PROJECT_FILE_NAME__/${PROJECT_FILE_NAME}/g" "${PROJECT_DIR}/codex_READMEFIRST.md"

echo
echo "Projekti luotu: ${PROJECT_DIR}"
echo "Projektin päämuisti: ${PROJECT_FILE_NAME}"
echo "Codexin aloitusohje: codex_READMEFIRST.md"
echo
echo "Seuraavat askeleet Codexin kanssa työskentelyyn:"
echo "1. Käynnistä Codex tässä sijainnissa komennolla: codex-dev"
echo "   Jos se ei toimi, kokeile komentoa: codex"
echo "2. Kun Codex käynnistyy, käytä ensimmäisenä viestinä: lue codex_READMEFIRST.md"
echo "3. Muista session lopuksi kirjoittaa vielä ennen sulkemista: 'lopetellaan' jotta codex päivittää vielä .md tiedostot seuraavaa kertaa varten." 
cd "${PROJECT_DIR}"

echo
echo "Olet nyt projektikansiossa. Nykyinen sijainti:"
pwd
echo
echo "Tämä terminaali jää auki tähän kansioon."
echo
exec bash -i
