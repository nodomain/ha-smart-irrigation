# 🌿 Smart Irrigation — ET + Sensor Fusion for Home Assistant

Intelligent irrigation control combining **evapotranspiration (ET) modeling** with **real soil moisture sensors** (Ecowitt) for truly adaptive watering. Uses KachelmannWetter weather data and DIIVOO MQTT valves.

## Features

- **ET₀-based water balance** — calculates daily evapotranspiration from solar radiation, temperature, and wind
- **Soil moisture sensor fusion** — real Ecowitt sensor data overrides and calibrates the model
- **Sensor veto** — skips irrigation when soil is still moist enough (even if model says "dry")
- **Sensor emergency** — forces immediate irrigation when soil is critically dry (even if model says "OK")
- **Daily sensor calibration** — blends model with real measurements to prevent long-term drift
- **Per-zone crop coefficients (Kc)** — each zone has tailored water demand based on plant type
- **Rain credit system** — actual rainfall is automatically credited to soil moisture balance
- **Forecast skip** — skips irrigation when significant rain is expected (configurable threshold)
- **Frost protection** — skips irrigation on nights with expected frost
- **Evening top-up** — automatic second watering on hot days (ET₀ > threshold) for container zones
- **Sequential zone execution** — runs zones one at a time with pressure recovery delays
- **Safety shutoff** — valves auto-close after 35 minutes regardless of automation state
- **Startup safety** — all valves forced off on Home Assistant restart
- **Persistent water balance** — uses `input_number` to survive HA restarts
- **iPhone notifications** — daily summaries with sensor values, skip reasons, and safety alerts
- **Dashboard included** — modern sections-based UI with gauges, sensor tiles, history graphs, and manual controls
- **Template-based deployment** — `envsubst` for easy entity customization

## Requirements

- Home Assistant 2024.1+
- [KachelmannWetter integration](https://github.com/meteotool/home-assistant-kachelmannwetter) (HACS)
- DIIVOO irrigation valves connected via MQTT (via [hassio-diivoo2mqtt](https://github.com/Technerd-SG/hassio-diivoo2mqtt))
- Ecowitt GW3000A gateway with soil moisture sensors (via [Ecowitt integration](https://www.home-assistant.io/integrations/ecowitt/))
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

### The Hybrid Approach: Model + Sensor Fusion

The system combines two signals for robust irrigation decisions:

1. **ET₀ Water Balance Model** (predictive) — estimates soil moisture from weather data
2. **Real Soil Moisture Sensors** (ground truth) — Ecowitt probes in the ground

Neither alone is perfect: the model can drift over time, and sensors can be noisy or positioned in non-representative spots. Together they provide reliable, adaptive irrigation.

### Decision Logic

```
IRRIGATE when:
  (Model says "dry" AND Sensor < wet_threshold)    → normal watering
  OR (Sensor < dry_threshold)                       → emergency override

DO NOT IRRIGATE when:
  Sensor ≥ wet_threshold                            → veto (soil is moist enough)
  (even if model says "dry")

FALLBACK when sensor unavailable:
  Use model-only decision                           → graceful degradation
```

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

ET₀ represents how much water a reference grass surface would lose on a given day:

```
IF solar radiation available:
  ET₀ = radiation × 0.0004 + (temp − 10) × 0.08 + wind × 0.01

ELSE (fallback to sunshine hours):
  ET₀ = sunshine_hours × 0.6 + (temp − 10) × 0.12 + wind × 0.015
```

This produces realistic values of **0–8 mm/day** for Central Europe.

### Daily Cycle

1. **04:45** — Sensor calibration: model balance is blended with real sensor readings
2. **05:00** (configurable) — Morning scheduler: checks each zone and waters those that need it
3. **Throughout the day** — Rain credits added to all zones in real-time
4. **20:00** (configurable) — Evening top-up for high-demand zones on hot days (ET₀ > threshold)
5. **23:55** — Daily ET deducted from each zone's balance
6. **Anytime** — Sensor emergency: immediate watering if any sensor drops critically low

### Sensor Calibration

Once daily (15 min before irrigation), the model balance is corrected using real sensor readings:

```
new_balance = (1 − weight) × model_balance + weight × sensor_estimate
```

Where `sensor_estimate = (sensor_percent / 100) × capacity`. The default weight of 0.3 means 30% sensor influence — enough to correct drift without overreacting to sensor noise.

### Skip Logic

Irrigation is skipped entirely when:
- Rain forecast ≥ threshold (default 5mm)
- Frost expected tonight
- Rain imminent (3h binary) AND forecast ≥ 60% of threshold

## Zone Configuration

| Zone | Name | Switch | Kc | Capacity | Trigger | Sensor | Description |
|------|------|--------|-----|----------|---------|--------|-------------|
| 1 | Terrasse Tropfer | `diivoo_..._ventil_2` | 1.2 | 10mm | 30% | `gw3000a_soil_moisture_terrasse` | South, full sun, container plants |
| 2 | Hecke Tropfer | `diivoo_..._ventil_3` | 0.8 | 25mm | 40% | `gw3000a_soil_moisture_hecke` | South, full sun, lawn + hedge |
| 3 | Vorgarten Tropfer | `diivoo_..._ventil_4` | 0.6 | 25mm | 40% | `gw3000a_soil_moisture_vorgarten` | North, morning sun, flowers |
| 4 | Seitliche Terrasse | `diivoo_..._ventil_1` | 0.9 | 15mm | 35% | `gw3000a_soil_moisture_hochbeet` | West, mostly shade, raised bed |

### Parameter Explanations

- **Kc (Crop Coefficient)**: How much more/less water than reference grass. Containers in full sun → 1.2+, shade groundcover → 0.5
- **Capacity (mm)**: How much water the soil/container can hold. Small pots → 8-12mm, in-ground → 20-30mm
- **Trigger (%)**: Water when balance drops below this % of capacity. Drought-tolerant → 40%+, thirsty plants → 25-30%
- **Duration per mm**: How long to run drippers to deliver 1mm equivalent. Depends on flow rate and coverage area.
- **Sensor wet threshold (%)**: Sensor reading above which irrigation is vetoed (default 50%)
- **Sensor dry threshold (%)**: Sensor reading below which emergency irrigation is triggered (default 15%)
- **Calibration weight**: How much the sensor corrects the model daily (default 0.3 = 30%)

## Sensors Created

### Template Sensors
| Entity | Description |
|--------|-------------|
| `sensor.irrigation_today_et0` | Reference evapotranspiration (mm/day) |
| `sensor.zone_X_daily_et` | Zone-specific ET (ET₀ × Kc) |
| `sensor.zone_X_balance_percent` | Model soil moisture as % of capacity |
| `sensor.zone_X_deficit` | Water deficit in mm |
| `sensor.zone_X_recommended_duration` | Suggested run time (min) |
| `sensor.zone_X_soil_moisture_sensor` | Real sensor reading (%) with model comparison |
| `sensor.irrigation_skip_reason` | Human-readable skip explanation |

### Binary Sensors
| Entity | Description |
|--------|-------------|
| `binary_sensor.zone_X_needs_water` | True when zone needs water (hybrid model+sensor logic) |
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
| `input_number.irrigation_evening_et_threshold` | ET₀ threshold for evening run (mm) |
| `input_number.irrigation_sensor_wet_threshold` | Sensor veto threshold (%) |
| `input_number.irrigation_sensor_dry_threshold` | Sensor emergency threshold (%) |
| `input_number.irrigation_sensor_calibration_weight` | Daily calibration blend factor |

## Automations

| Automation | Trigger | Description |
|-----------|---------|-------------|
| Daily ET deduction | 23:55 daily | Subtracts ET loss, adds rain to all zones |
| Rain credit | Rain sensor change | Credits actual rainfall in real-time |
| Sensor calibration | 15 min before start | Blends model with real sensor readings |
| Morning scheduler | Configured start hour | Main irrigation — hybrid decision, sequential zones |
| Evening top-up | Configured evening hour | Second run for high-Kc zones on hot days |
| Sensor emergency | Sensor < dry threshold for 30 min | Immediate watering, queued (max 4) |
| Safety shutoff | Valve on > 35 min | Emergency off + critical notification |
| Startup safety | HA start | All valves off after restart |
| Low battery warning | Battery < 20% | Push notification |
| Connection lost | Offline > 5–10 min | Push notification |
| Weekly summary | Sunday 20:00 | Model vs. sensor status report |

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
| `ZONE1_SENSOR` | ✅ | — | Entity ID of Zone 1 soil moisture sensor |
| `ZONE2_SENSOR` | ✅ | — | Entity ID of Zone 2 soil moisture sensor |
| `ZONE3_SENSOR` | ✅ | — | Entity ID of Zone 3 soil moisture sensor |
| `ZONE4_SENSOR` | ✅ | — | Entity ID of Zone 4 soil moisture sensor |
| `ZONE1_NAME` | — | Zone 1 | Friendly name for Zone 1 |
| `ZONE2_NAME` | — | Zone 2 | Friendly name for Zone 2 |
| `ZONE3_NAME` | — | Zone 3 | Friendly name for Zone 3 |
| `ZONE4_NAME` | — | Zone 4 | Friendly name for Zone 4 |
| `IPHONE_DEVICE` | ✅ | — | iPhone device name for notifications |
| `ZONE1_DEVICE_ID` | ✅ | — | DIIVOO device ID for Zone 1 (battery/connection) |
| `ZONE4_DEVICE_ID` | ✅ | — | DIIVOO device ID for Zone 4 (battery/connection) |
| `GATEWAY_CONNECTION_ENTITY` | ✅ | — | Gateway connectivity binary sensor |
| `ZONE1_CONNECTION_ENTITY` | ✅ | — | Zone 1 valve connectivity sensor |
| `ZONE4_CONNECTION_ENTITY` | ✅ | — | Zone 4 valve connectivity sensor |
| `HA_CONFIG_MOUNT` | — | `/Volumes/config` | Mount point for HA config |
| `HA_CONFIG_SMB_URL` | — | — | SMB URL for auto-mount |
| `HA_URL` | — | — | HA base URL (enables API features) |
| `HA_TOKEN` | — | — | Long-lived access token |
| `HA_DASHBOARD_URL_PATH` | — | `smart-irrigation` | Dashboard URL path |

## Dashboard

The included dashboard uses the modern **sections** view type with two views:

### Overview View
- **System Status**: Master toggle, today's ET₀, rain skip status, frost warning, batteries
- **Zone Cards** (×4): Model gauge, real sensor reading, needs-water indicator, recommended duration, last watered, manual run button
- **Weather**: Temperature, sunshine, radiation, rain, wind from KachelmannWetter
- **History Charts** (7 days each):
  - Soil moisture sensors (real Ecowitt readings)
  - Model balance (calculated water level)
  - Daily ET₀ and per-zone ET
  - Rainfall and skip events
  - Weather drivers (temp, sun, wind)
  - Valve activity timeline

### Settings View
- **Schedule & Limits**: Start hour, max duration, rain threshold
- **Sensor Thresholds**: Wet threshold, dry threshold, calibration weight
- **Per-Zone Settings**: Kc, capacity, trigger, duration/mm, current balance

## Tuning Guide

### Sensor Threshold Tuning

The Ecowitt soil moisture sensors (WH51) use a **capacitive/dielectric measurement**. They don't measure actual volumetric water content — they measure how much the soil's electrical properties change between dry air (0%) and submerged in water (100%). Values are relative, not absolute.

**Typical reading ranges:**
| Condition | Sensor Reading |
|-----------|---------------|
| Freshly watered | 55–70% |
| Moist, no action needed | 40–55% |
| Getting dry, water soon | 30–40% |
| Dry, plants stressed | 20–30% |
| Critically dry | < 20% |

**Default thresholds (tuned for these sensors):**
- **Wet threshold (45%)**: Skip irrigation — soil still has enough moisture from recent watering
- **Dry threshold (25%)**: Emergency trigger — most plants are stressed at this level
- **Calibration weight (0.3)**: 30% sensor influence on the daily model correction

**Adjustment by soil type:**
| Soil Type | Wet Threshold | Dry Threshold | Notes |
|-----------|--------------|---------------|-------|
| Sandy | 40% | 20% | Drains fast, lower readings overall |
| Loamy (default) | 45% | 25% | Good baseline |
| Clay | 50% | 30% | Retains water, higher readings |
| Potting mix | 45% | 25% | Similar to loam |

**After 1–2 weeks of operation**, check:
1. Does the sensor veto prevent necessary watering? → Lower wet threshold
2. Does emergency trigger too often? → Lower dry threshold
3. Do model and sensor diverge significantly? → Increase calibration weight
4. Optional: calibrate sensors in Ecowitt app (dry reading → 0%, wet reading → 100%)

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

1. **Start with defaults** — run for 3–5 days and observe sensor readings
2. **Compare model vs. sensor** — the dashboard shows both side by side. If they diverge heavily, adjust calibration weight
3. **Watch for sensor vetoes** — if the notification says "Sensor skip" but plants look dry, lower the wet threshold
4. **Check balance values** — if a zone's balance frequently hits 0, increase capacity or decrease Kc
5. **Seasonal adjustment** — increase Kc by 0.1–0.2 in peak summer (Jul/Aug), decrease in spring/autumn
6. **Container vs. ground** — containers need higher Kc (1.0+) because they can't draw from deeper soil

## Troubleshooting

### Valves don't turn on
1. Check MQTT connection: verify DIIVOO entities exist and are `available`
2. Check `input_boolean.irrigation_enabled` is `on`
3. Check zone-specific enable: `input_boolean.irrigation_zone_X_enabled`
4. Check if rain skip is active: `binary_sensor.irrigation_rain_skip_active`
5. Check sensor veto: is the sensor reading ≥ wet threshold?
6. Manually run a script: `script.irrigation_run_zone_1`

### ET₀ shows 0 all day
- Verify KachelmannWetter sensors have valid values (not `unavailable`)
- Check `sensor.kachelmannwetter_globalstrahlung_heute` — should increase during the day
- Check `sensor.aussentemperatur_gerundet` — should be a reasonable number

### Balance never decreases
- The ET deduction runs at **23:55** — check automation logs
- Verify `sensor.zone_X_daily_et` shows a non-zero value during the day
- If ET₀ is 0, balance won't change (check weather sensors)

### Sensor reads 0% but soil is moist
- Ecowitt sensor batteries may be dead (check `sensor.gw3000a_soil_battery_X`)
- Sensor may have lost connection to gateway
- Check if sensor entity shows `unavailable` — the system falls back to model-only automatically

### Sensor veto prevents needed watering
- Lower `irrigation_sensor_wet_threshold` (e.g., from 50% to 40%)
- Check if sensor is in a representative position (not in a dry pocket or near a water source)

### Emergency irrigation triggers too often
- Raise `irrigation_sensor_dry_threshold` (e.g., from 15% to 20%)
- The 30-minute debounce prevents rapid re-triggering, but sustained low readings will trigger

### Watering too much / too little
- **Too much**: Increase `trigger` %, decrease `duration_per_mm`, decrease `Kc`, or lower `wet_threshold`
- **Too little**: Decrease `trigger` %, increase `duration_per_mm`, increase `Kc`, or raise `wet_threshold`
- Check the history graph — model and sensor should roughly track each other over time

### Rain credit not working
- Verify `sensor.kachelmannwetter_niederschlag_1h` updates during rain
- The rain credit automation triggers on **state change** of the rain sensor
- Check automation traces in Developer Tools → Automations

### After HA restart, entity IDs look wrong
- Template sensor entity IDs are generated from their `name` field (e.g., "Zone 1 daily ET" → `sensor.zone_1_daily_et`)
- If entity IDs don't match what automations expect, check the entity registry in `.storage/core.entity_registry`
- A fresh install will generate entity IDs from names; an existing install keeps previously registered IDs

## License

MIT
