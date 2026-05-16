# Agent Instructions for ha-smart-irrigation

## Architecture

This project uses a **template-based deployment** workflow:

```
packages/smart-irrigation.yaml.tpl     ← SOURCE OF TRUTH (edit this!)
dashboard/smart-irrigation-dashboard.yaml.tpl
        │
        │  ./deploy.sh (envsubst)
        ▼
/Volumes/config/ha-smart-irrigation/   ← GENERATED OUTPUT (never edit!)
```

## Critical Rules

1. **NEVER edit files in `/Volumes/config/`** — they are generated output and
   will be overwritten on the next deploy. The config volume is mounted
   read-write only so we can inspect deploy results.

2. **Always edit the `.tpl` template files** in `packages/` and `dashboard/`.

3. **Use `${VARIABLE}` placeholders** for hardware-specific values (switches,
   sensors, device names). Available variables are defined in `.env.example`.

4. **Deploy via `./deploy.sh`** — this runs `envsubst` on templates, syncs to
   the HA config mount, and optionally reloads/restarts Home Assistant.

## Environment Variables

All device-specific values are in `.env` (gitignored). See `.env.example` for
the full list. Key variables:

| Variable | Purpose |
|----------|---------|
| `ZONE1_SWITCH` .. `ZONE4_SWITCH` | Valve switch entity IDs |
| `ZONE1_NAME` .. `ZONE4_NAME` | Human-readable zone names |
| `ZONE1_SENSOR` .. `ZONE4_SENSOR` | Soil moisture sensor entity IDs |
| `IPHONE_DEVICE` | iPhone device name for `notify.mobile_app_*` |
| `HA_URL` / `HA_TOKEN` | HA API access for reload/dashboard push |

## Deploy Commands

```bash
./deploy.sh              # Render templates → config mount (no reload)
./deploy.sh --reload     # Deploy + soft reload (~3s entity blip)
./deploy.sh --restart    # Deploy + hard restart (~60s downtime)
./deploy.sh --force      # Force reload even if unchanged
```

## Template Syntax

- `${ENV_VAR}` — substituted by envsubst at deploy time
- `{{ jinja }}` / `{% jinja %}` — Home Assistant Jinja2 (passed through as-is)
- Both syntaxes coexist in the same file; envsubst only touches `${...}`

## File Structure

```
ha-smart-irrigation/
├── packages/
│   └── smart-irrigation.yaml.tpl    # Main HA package (automations, sensors, scripts)
├── dashboard/
│   └── smart-irrigation-dashboard.yaml.tpl  # Lovelace dashboard config
├── tools/
│   └── ha_update_dashboard.py       # Dashboard API push helper
├── deploy.sh                        # Build & deploy script
├── .env.example                     # Template for environment variables
├── .env                             # Local config (gitignored)
├── AGENTS.md                        # This file
└── README.md                        # Project documentation
```
