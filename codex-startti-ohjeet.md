# codex-startti ohjeet

`codex-startti.sh` luo uuden Codex-projektikansion joko koodaus- tai ei-koodausprojektia varten.

Skriptin käyttö:

```bash
cd /home/<user>/polku/jossa/skripti/on
chmod +x codex-startti.sh
./codex-startti.sh
```

Mitä skripti tekee:

- kysyy kohdehakemiston `/home/` alta
- luo kohdehakemiston, jos sitä ei vielä ole
- kysyy projektin nimen
- luo projektikansion ja sinne tiedostot:
  - `AGENTS.md`
  - `NOW.md`
  - `CHECKPOINTS.md`
  - `codex_READMEFIRST.md`
  - `<projektin_nimi>.md`
- avaa uuden terminaali-ikkunan tarvittaessa
- siirtyy luotuun projektikansioon
- näyttää ohjeet Codexin käynnistämiseen
- jättää terminaalin auki projektikansioon

Kun skripti on valmis, olet valmiiksi projektikansiossa. Käynnistä siellä Codex ja käytä ensimmäisenä viestinä: `lue codex_READMEFIRST.md`
