# 🌿 Smart Irrigation — ET-Based Scheduling for Home Assistant

Intelligent irrigation control using evapotranspiration (ET) calculations with KachelmannWetter weather data and DIIVOO MQTT valves. Waters only when plants actually need it, skips when rain is expected.

## Features

- **ET₀-based water balance** — calculates daily evapotranspiration from solar radiation, temperature, and wind
- **Per-zone crop coefficients (Kc)** — each zone has tailored water demand based on plant type
- **Rain credit system** — actual rainfall is automatically credited to soil moisture balance
- **Forecast skip** — skips irrigation when significant rain is expected (configurable threshold)
- **Frost protection** — skips irrigation on nights with expected frost
- **Evening top-up** — automatic second watering on hot days (ET₀ > threshold) for container zones
- **Sequential zone execution** — runs zones one at a time with pressure recovery delays
- **Safety shutoff** — valves auto-close after 35 minutes regardless of automation state
- **Startup safety** — all valves forced off on Home Assistant restart
- **Persistent water balance** — uses `input_number` to survive HA restarts
- **iPhone notifications** — daily summaries, skip reasons, and safety alerts
- **Dashboard included** — modern sections-based UI with gauges, history, and manual controls
- **Template-based deployment** — `envsubst` for easy entity customization

## Requirements

- Home Assistant 2024.1+
- [KachelmannWetter integration](https://github.com/meteotool/home-assistant-kachelmannwetter) (HACS)
- DIIVOO irrigation valves connected via MQTT (via [hassio-diivoo2mqtt](https://github.com/Technerd-SG/hassio-diivoo2mqtt))
- macOS for `deploy.sh` auto-mount (optional; manual copy works on any OS)

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/nodomain/ha-smart-irrigation.git
cd ha-smart-irrigation

# 2. Create your .env from the template
cp .env.example .env
# Edit .env with your actual entity IDs

# 3. Deploy to Home Assistant
chmod +x deploy.sh
./deploy.sh

# 4. Reload Home Assistant
./deploy.sh --reload
```

After deployment, configure your dashboard:
1. Go to **Settings → Dashboards → Add Dashboard**
2. Create a new dashboard with URL path `smart-irrigation`
3. Switch to YAML mode and paste the contents of `smart-irrigation-dashboard.yaml`

Or, if `HA_URL` and `HA_TOKEN` are set in `.env`, the dashboard is pushed automatically.

## How It Works

### The ET Model

The system uses a simplified **water balance** approach inspired by FAO-56 methodology:

```
Balance_tomorrow = Balance_today − ET_zone + Rain + Irrigation
```

Where:
- **ET_zone** = ET₀ × Kc (reference evapotranspiration × crop coefficient)
- **Rain** = actual measured rainfall (credited in real-time)
- **Irrigation** = water applied (calculated from run duration)

#### Reference ET₀ Calculation

ET₀ (reference evapotranspiration) represents how much water a reference grass surface would lose on a given day. The system uses a **simplified radiation-based formula** with KachelmannWetter data:

```
IF solar radiation available:
  ET₀ = radiation × 0.0004 + (temp − 10) × 0.08 + wind × 0.01

ELSE (fallback to sunshine hours):
  ET₀ = sunshine_hours × 0.6 + (temp − 10) × 0.12 + wind × 0.015
```

This produces realistic values of **0–8 mm/day** for Central Europe.

#### Daily Cycle

1. **Throughout the day**: Rain credits are added to all zones in real-time
2. **At 23:55**: Daily ET is subtracted from each zone's balance
3. **At 05:00** (configurable): The morning scheduler checks each zone and waters those below their trigger threshold
4. **At 20:00** (configurable): If ET₀ exceeded the evening threshold, high-demand zones (Kc ≥ 0.9) get a second shorter watering to prevent overnight wilting

#### Irrigation Decision

A zone gets watered when:
```
balance < capacity × (trigger_percent / 100)
```

The duration is calculated as:
```
duration = min(deficit × minutes_per_mm, max_duration)
```

### Skip Logic

Irrigation is skipped entirely when:
- Rain forecast ≥ threshold (default 5mm)
- Frost expected tonight
- Rain imminent (3h binary) AND forecast ≥ 60% of threshold

## Zone Configuration

| Zone | Name | Switch | Kc | Capacity | Trigger | Description |
|------|------|--------|-----|----------|---------|-------------|
| 1 | Terrasse Tropfer | `diivoo_..._ventil_2` | 1.2 | 10mm | 30% | South, full sun, container plants |
| 2 | Hecke Tropfer | `diivoo_..._ventil_3` | 0.8 | 25mm | 40% | South, full sun, lawn + hedge |
| 3 | Vorgarten Tropfer | `diivoo_..._ventil_4` | 0.6 | 25mm | 40% | North, morning sun, flowers |
| 4 | Seitliche Terrasse | `diivoo_..._ventil_1` | 0.9 | 15mm | 35% | West, mostly shade, raised bed |

### Parameter Explanations

- **Kc (Crop Coefficient)**: How much more/less water than reference grass. Containers in full sun → 1.2+, shade groundcover → 0.5
- **Capacity (mm)**: How much water the soil/container can hold. Small pots → 8-12mm, in-ground → 20-30mm
- **Trigger (%)**: Water when balance drops below this % of capacity. Drought-tolerant → 40%+, thirsty plants → 25-30%
- **Duration per mm**: How long to run drippers to deliver 1mm equivalent. Depends on flow rate and coverage area.

## Sensors Created

### Template Sensors
| Entity | Description |
|--------|-------------|
| `sensor.irrigation_today_et0` | Reference evapotranspiration (mm/day) |
| `sensor.irrigation_zone_X_daily_et` | Zone-specific ET (ET₀ × Kc) |
| `sensor.irrigation_zone_X_balance_pct` | Soil moisture as % of capacity |
| `sensor.irrigation_zone_X_deficit` | Water deficit in mm |
| `sensor.irrigation_zone_X_recommended_duration` | Suggested run time (min) |
| `sensor.irrigation_skip_reason` | Human-readable skip explanation |

### Binary Sensors
| Entity | Description |
|--------|-------------|
| `binary_sensor.irrigation_zone_X_needs_water` | True when zone is below trigger |
| `binary_sensor.irrigation_rain_skip_active` | True when skip conditions are met |

### Input Numbers (persistent)
| Entity | Description |
|--------|-------------|
| `input_number.irrigation_zone_X_balance` | Current water balance (mm) |
| `input_number.irrigation_zone_X_kc` | Crop coefficient |
| `input_number.irrigation_zone_X_capacity` | Soil water holding capacity (mm) |
| `input_number.irrigation_zone_X_trigger` | Depletion trigger (%) |
| `input_number.irrigation_zone_X_duration_per_mm` | Minutes of watering per mm |
| `input_number.irrigation_rain_skip_threshold` | Rain threshold to skip (mm) |
| `input_number.irrigation_max_duration` | Max single zone run (min) |
| `input_number.irrigation_start_hour` | Morning scheduler start hour |
| `input_number.irrigation_evening_hour` | Evening top-up hour |
| `input_number.irrigation_evening_et_threshold` | ET₀ threshold to trigger evening run (mm) |

## Automations

| Automation | Trigger | Description |
|-----------|---------|-------------|
| Daily ET deduction | 23:55 daily | Subtracts ET loss, adds rain to all zones |
| Rain credit | Rain sensor change | Credits actual rainfall in real-time |
| Morning scheduler | Configured start hour | Main irrigation — checks conditions, runs zones sequentially |
| Evening top-up | Configured evening hour | Second run for high-Kc zones on hot days (ET₀ > threshold) |
| Safety shutoff | Valve on > 35 min | Emergency off + critical notification |
| Startup safety | HA start | All valves off after restart |

## Scripts

| Script | Description |
|--------|-------------|
| `script.irrigation_run_zone_1` | Run Zone 1 for recommended duration |
| `script.irrigation_run_zone_2` | Run Zone 2 for recommended duration |
| `script.irrigation_run_zone_3` | Run Zone 3 for recommended duration |
| `script.irrigation_run_zone_4` | Run Zone 4 for recommended duration |
| `script.irrigation_stop_all` | Emergency stop — all valves off immediately |

## File Structure

```
ha-smart-irrigation/
├── README.md                                    # This file
├── LICENSE                                      # MIT license
├── .env.example                                 # Template for personal config
├── .gitignore                                   # Excludes .env
├── deploy.sh                                    # SMB auto-mount + envsubst deploy
├── packages/
│   └── smart-irrigation.yaml.tpl                # HA package template (the brain)
├── dashboard/
│   └── smart-irrigation-dashboard.yaml.tpl      # Lovelace dashboard template
└── tools/
    └── ha_update_dashboard.py                   # WebSocket API dashboard pusher
```

After deployment, files land in `<HA_CONFIG>/ha-smart-irrigation/`:
```
ha-smart-irrigation/
├── smart-irrigation.yaml                        # Rendered package (loaded by HA)
└── smart-irrigation-dashboard.yaml              # Rendered dashboard config
```

Include in your `configuration.yaml`:
```yaml
homeassistant:
  packages:
    smart_irrigation: !include ha-smart-irrigation/smart-irrigation.yaml
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `ZONE1_SWITCH` | ✅ | — | Entity ID of Zone 1 valve switch |
| `ZONE2_SWITCH` | ✅ | — | Entity ID of Zone 2 valve switch |
| `ZONE3_SWITCH` | ✅ | — | Entity ID of Zone 3 valve switch |
| `ZONE4_SWITCH` | ✅ | — | Entity ID of Zone 4 valve switch |
| `ZONE1_NAME` | — | Zone 1 | Friendly name for Zone 1 |
| `ZONE2_NAME` | — | Zone 2 | Friendly name for Zone 2 |
| `ZONE3_NAME` | — | Zone 3 | Friendly name for Zone 3 |
| `ZONE4_NAME` | — | Zone 4 | Friendly name for Zone 4 |
| `IPHONE_DEVICE` | ✅ | — | iPhone device name for notifications |
| `HA_CONFIG_MOUNT` | — | `/Volumes/config` | Mount point for HA config |
| `HA_CONFIG_SMB_URL` | — | — | SMB URL for auto-mount |
| `HA_URL` | — | — | HA base URL (enables API features) |
| `HA_TOKEN` | — | — | Long-lived access token |
| `HA_DASHBOARD_URL_PATH` | — | `smart-irrigation` | Dashboard URL path |

## Dashboard

The included dashboard uses the modern **sections** view type with two views:

### Overview View
- **System Status**: Master toggle, today's ET₀, rain skip status, frost warning
- **Zone Cards** (×4): Moisture gauge, needs-water indicator, recommended duration, last watered, manual run button
- **Weather**: Temperature, sunshine, radiation, rain, wind from KachelmannWetter
- **History Charts** (7 days each):
  - Soil moisture balances (all zones)
  - Daily ET₀ and per-zone ET
  - Rainfall and skip events
  - Weather drivers (temp, sun, wind, radiation)
  - Valve activity timeline
- **Quick Actions**: Emergency stop all button

### Settings View
- **Global Parameters**: Start hour, max duration, rain threshold
- **Per-Zone Settings**: Kc, capacity, trigger, duration/mm, current balance

## Tuning Guide

### Crop Coefficient (Kc) Reference

| Plant Type | Kc Range | Notes |
|-----------|----------|-------|
| Cool-season grass (lawn) | 0.7–0.9 | Higher in peak summer |
| Warm-season grass | 0.5–0.7 | More drought-tolerant |
| Hedges (Liguster, etc.) | 0.6–0.8 | Established = lower |
| Roses | 0.8–1.0 | Heavy feeders, need moisture |
| Mediterranean (olive, lavender) | 0.4–0.6 | Very drought-tolerant |
| Container plants (mixed) | 1.0–1.4 | Limited root volume, dry faster |
| Ground cover | 0.4–0.6 | Low water demand |
| Herbs | 0.6–0.8 | Mediterranean herbs lower |
| Strawberries | 0.8–1.0 | Need consistent moisture for fruit |

### Soil/Container Capacity

| Medium | Capacity | Notes |
|--------|----------|-------|
| Small pot (< 5L) | 5–8 mm | Dries out in 1 hot day |
| Medium pot (5–20L) | 8–15 mm | 1–2 days buffer |
| Large pot (> 20L) | 12–20 mm | 2–3 days buffer |
| Sandy soil (in-ground) | 15–20 mm | Drains fast |
| Loamy soil (in-ground) | 25–35 mm | Good retention |
| Clay soil (in-ground) | 30–45 mm | Holds most, but slow drainage |
| Raised bed (mixed) | 15–25 mm | Depends on mix |

### Tuning Process

1. **Start with defaults** — run for 3–5 days and observe
2. **Check balance values** — if a zone's balance frequently hits 0, increase capacity or decrease Kc
3. **Watch for over-watering** — if plants look waterlogged, increase trigger % or decrease duration_per_mm
4. **Seasonal adjustment** — increase Kc by 0.1–0.2 in peak summer (Jul/Aug), decrease in spring/autumn
5. **Container vs. ground** — containers need higher Kc (1.0+) because they can't draw from deeper soil

## Troubleshooting

### Valves don't turn on
1. Check MQTT connection: verify DIIVOO entities exist and are `available`
2. Check `input_boolean.irrigation_enabled` is `on`
3. Check zone-specific enable: `input_boolean.irrigation_zone_X_enabled`
4. Check if rain skip is active: `binary_sensor.irrigation_rain_skip_active`
5. Manually run a script: `script.irrigation_run_zone_1`

### ET₀ shows 0 all day
- Verify KachelmannWetter sensors have valid values (not `unavailable`)
- Check `sensor.kachelmannwetter_globalstrahlung_heute` — should increase during the day
- Check `sensor.aussentemperatur_gerundet` — should be a reasonable number

### Balance never decreases
- The ET deduction runs at **23:55** — check automation logs
- Verify `sensor.irrigation_zone_X_daily_et` shows a non-zero value during the day
- If ET₀ is 0, balance won't change (check weather sensors)

### Watering too much / too little
- **Too much**: Increase `trigger` %, decrease `duration_per_mm`, or decrease `Kc`
- **Too little**: Decrease `trigger` %, increase `duration_per_mm`, or increase `Kc`
- Check the history graph — balance should oscillate between trigger and capacity

### Rain credit not working
- Verify `sensor.kachelmannwetter_niederschlag_1h` updates during rain
- The rain credit automation triggers on **state change** of the rain sensor
- Check automation traces in Developer Tools → Automations

### Safety shutoff triggered unexpectedly
- Default safety timeout is 35 minutes. If your zones need longer runs, increase `irrigation_max_duration` and update the safety automation's `for` duration.
- Check for MQTT connectivity issues that might cause delays between on/off commands.

### After HA restart, irrigation ran with wrong values
- Water balance is stored in `input_number` entities — these persist across restarts
- However, a restart mid-irrigation will leave the balance un-credited for that run
- The startup safety automation turns all valves off 30s after restart

## License

MIT
