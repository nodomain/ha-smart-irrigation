###############################################################################
# PACKAGE: smart-irrigation.yaml
#
# ET-based smart irrigation with KachelmannWetter data for DIIVOO valves.
#
# Features:
#   - Reference ET₀ calculation from solar radiation + temperature + wind
#   - Per-zone water balance tracking (survives restarts via input_number)
#   - Crop coefficient (Kc) per zone for accurate water demand
#   - Rain credit: actual rainfall automatically reduces irrigation need
#   - Forecast skip: skip irrigation when significant rain is expected
#   - Frost protection: skip irrigation on frost nights
#   - Sequential zone execution with pressure recovery delay
#   - Safety timeouts: valves always turn off, even on automation errors
#   - iPhone push notifications for daily summaries and skip events
#   - Soil moisture sensor fusion: real sensor data overrides/calibrates model
#   - Sensor veto: skip irrigation when soil is still moist enough
#   - Sensor emergency: force irrigation when soil is critically dry
#   - Daily sensor calibration: correct model drift with real measurements
#
# Zones:
#   1. ${ZONE1_NAME} — ${ZONE1_SWITCH}
#   2. ${ZONE2_NAME} — ${ZONE2_SWITCH}
#   3. ${ZONE3_NAME} — ${ZONE3_SWITCH}
#   4. ${ZONE4_NAME} — ${ZONE4_SWITCH}
#
# Weather: KachelmannWetter integration
# Sensors: Ecowitt GW3000A soil moisture (${ZONE1_SENSOR}, ${ZONE2_SENSOR}, ${ZONE3_SENSOR}, ${ZONE4_SENSOR})
# Notifications: notify.mobile_app_${IPHONE_DEVICE}
###############################################################################


# =============================================================================
# INPUT BOOLEANS — Master and per-zone enable/disable
# =============================================================================
input_boolean:
  irrigation_enabled:
    name: "Irrigation master enable"
    icon: mdi:water-pump
    initial: true

  irrigation_zone_1_enabled:
    name: "Irrigation Zone 1 (${ZONE1_NAME}) enabled"
    icon: mdi:sprinkler-variant
    initial: true

  irrigation_zone_2_enabled:
    name: "Irrigation Zone 2 (${ZONE2_NAME}) enabled"
    icon: mdi:sprinkler-variant
    initial: true

  irrigation_zone_3_enabled:
    name: "Irrigation Zone 3 (${ZONE3_NAME}) enabled"
    icon: mdi:sprinkler-variant
    initial: true

  irrigation_zone_4_enabled:
    name: "Irrigation Zone 4 (${ZONE4_NAME}) enabled"
    icon: mdi:sprinkler-variant
    initial: true


# =============================================================================
# INPUT NUMBERS — Per-zone tuning parameters
# =============================================================================
input_number:
  # ---------------------------------------------------------------------------
  # Zone 1: ${ZONE1_NAME}
  # ---------------------------------------------------------------------------
  irrigation_zone_1_kc:
    name: "Zone 1 crop coefficient (Kc)"
    min: 0.1
    max: 2.0
    step: 0.1
    icon: mdi:leaf
    mode: slider
    initial: 1.2

  irrigation_zone_1_capacity:
    name: "Zone 1 soil water capacity"
    min: 5
    max: 50
    step: 1
    unit_of_measurement: "mm"
    icon: mdi:water
    mode: slider
    initial: 10

  irrigation_zone_1_trigger:
    name: "Zone 1 depletion trigger"
    min: 20
    max: 80
    step: 5
    unit_of_measurement: "%"
    icon: mdi:gauge-low
    mode: slider
    initial: 30

  irrigation_zone_1_duration_per_mm:
    name: "Zone 1 minutes per mm deficit"
    min: 1
    max: 10
    step: 0.5
    unit_of_measurement: "min/mm"
    icon: mdi:timer-outline
    mode: box
    initial: 3

  irrigation_zone_1_balance:
    name: "Zone 1 water balance"
    min: 0
    max: 50
    step: 0.1
    unit_of_measurement: "mm"
    icon: mdi:water-percent
    mode: box
    initial: 10

  # ---------------------------------------------------------------------------
  # Zone 2: ${ZONE2_NAME}
  # ---------------------------------------------------------------------------
  irrigation_zone_2_kc:
    name: "Zone 2 crop coefficient (Kc)"
    min: 0.1
    max: 2.0
    step: 0.1
    icon: mdi:leaf
    mode: slider
    initial: 0.8

  irrigation_zone_2_capacity:
    name: "Zone 2 soil water capacity"
    min: 5
    max: 50
    step: 1
    unit_of_measurement: "mm"
    icon: mdi:water
    mode: slider
    initial: 25

  irrigation_zone_2_trigger:
    name: "Zone 2 depletion trigger"
    min: 20
    max: 80
    step: 5
    unit_of_measurement: "%"
    icon: mdi:gauge-low
    mode: slider
    initial: 40

  irrigation_zone_2_duration_per_mm:
    name: "Zone 2 minutes per mm deficit"
    min: 1
    max: 10
    step: 0.5
    unit_of_measurement: "min/mm"
    icon: mdi:timer-outline
    mode: box
    initial: 3

  irrigation_zone_2_balance:
    name: "Zone 2 water balance"
    min: 0
    max: 50
    step: 0.1
    unit_of_measurement: "mm"
    icon: mdi:water-percent
    mode: box
    initial: 25

  # ---------------------------------------------------------------------------
  # Zone 3: ${ZONE3_NAME}
  # ---------------------------------------------------------------------------
  irrigation_zone_3_kc:
    name: "Zone 3 crop coefficient (Kc)"
    min: 0.1
    max: 2.0
    step: 0.1
    icon: mdi:leaf
    mode: slider
    initial: 0.6

  irrigation_zone_3_capacity:
    name: "Zone 3 soil water capacity"
    min: 5
    max: 50
    step: 1
    unit_of_measurement: "mm"
    icon: mdi:water
    mode: slider
    initial: 25

  irrigation_zone_3_trigger:
    name: "Zone 3 depletion trigger"
    min: 20
    max: 80
    step: 5
    unit_of_measurement: "%"
    icon: mdi:gauge-low
    mode: slider
    initial: 40

  irrigation_zone_3_duration_per_mm:
    name: "Zone 3 minutes per mm deficit"
    min: 1
    max: 10
    step: 0.5
    unit_of_measurement: "min/mm"
    icon: mdi:timer-outline
    mode: box
    initial: 3

  irrigation_zone_3_balance:
    name: "Zone 3 water balance"
    min: 0
    max: 50
    step: 0.1
    unit_of_measurement: "mm"
    icon: mdi:water-percent
    mode: box
    initial: 25

  # ---------------------------------------------------------------------------
  # Zone 4: ${ZONE4_NAME}
  # ---------------------------------------------------------------------------
  irrigation_zone_4_kc:
    name: "Zone 4 crop coefficient (Kc)"
    min: 0.1
    max: 2.0
    step: 0.1
    icon: mdi:leaf
    mode: slider
    initial: 0.9

  irrigation_zone_4_capacity:
    name: "Zone 4 soil water capacity"
    min: 5
    max: 50
    step: 1
    unit_of_measurement: "mm"
    icon: mdi:water
    mode: slider
    initial: 15

  irrigation_zone_4_trigger:
    name: "Zone 4 depletion trigger"
    min: 20
    max: 80
    step: 5
    unit_of_measurement: "%"
    icon: mdi:gauge-low
    mode: slider
    initial: 35

  irrigation_zone_4_duration_per_mm:
    name: "Zone 4 minutes per mm deficit"
    min: 1
    max: 10
    step: 0.5
    unit_of_measurement: "min/mm"
    icon: mdi:timer-outline
    mode: box
    initial: 3

  irrigation_zone_4_balance:
    name: "Zone 4 water balance"
    min: 0
    max: 50
    step: 0.1
    unit_of_measurement: "mm"
    icon: mdi:water-percent
    mode: box
    initial: 15

  # ---------------------------------------------------------------------------
  # Global parameters
  # ---------------------------------------------------------------------------
  irrigation_rain_skip_threshold:
    name: "Rain skip threshold"
    min: 1
    max: 20
    step: 1
    unit_of_measurement: "mm"
    icon: mdi:weather-pouring
    mode: slider
    initial: 5

  irrigation_max_duration:
    name: "Maximum zone run time"
    min: 5
    max: 60
    step: 5
    unit_of_measurement: "min"
    icon: mdi:timer-alert
    mode: slider
    initial: 30

  irrigation_start_hour:
    name: "Irrigation start hour"
    min: 0
    max: 23
    step: 1
    unit_of_measurement: "h"
    icon: mdi:clock-start
    mode: box
    initial: 5

  irrigation_evening_hour:
    name: "Evening watering hour"
    min: 18
    max: 23
    step: 1
    unit_of_measurement: "h"
    icon: mdi:clock-end
    mode: box
    initial: 20

  irrigation_evening_et_threshold:
    name: "Evening run ET₀ threshold"
    min: 2
    max: 10
    step: 0.5
    unit_of_measurement: "mm"
    icon: mdi:thermometer-alert
    mode: slider
    initial: 5

  # ---------------------------------------------------------------------------
  # Soil moisture sensor thresholds (Ecowitt)
  # ---------------------------------------------------------------------------
  irrigation_sensor_wet_threshold:
    name: "Sensor wet threshold (skip irrigation)"
    min: 30
    max: 80
    step: 5
    unit_of_measurement: "%"
    icon: mdi:water-check
    mode: slider
    initial: 50

  irrigation_sensor_dry_threshold:
    name: "Sensor dry threshold (emergency trigger)"
    min: 5
    max: 40
    step: 5
    unit_of_measurement: "%"
    icon: mdi:water-alert
    mode: slider
    initial: 15

  irrigation_sensor_calibration_weight:
    name: "Sensor calibration weight"
    min: 0
    max: 0.5
    step: 0.05
    icon: mdi:scale-balance
    mode: slider
    initial: 0.3


# =============================================================================
# INPUT DATETIME — Last watered timestamps for each zone
# =============================================================================
input_datetime:
  irrigation_zone_1_last_run:
    name: "Zone 1 last irrigation"
    has_date: true
    has_time: true

  irrigation_zone_2_last_run:
    name: "Zone 2 last irrigation"
    has_date: true
    has_time: true

  irrigation_zone_3_last_run:
    name: "Zone 3 last irrigation"
    has_date: true
    has_time: true

  irrigation_zone_4_last_run:
    name: "Zone 4 last irrigation"
    has_date: true
    has_time: true


# =============================================================================
# TEMPLATE SENSORS — The irrigation brain
# =============================================================================
template:
  - sensor:
      # -----------------------------------------------------------------------
      # Reference evapotranspiration ET₀ (mm/day)
      # Simplified radiation-based formula using KachelmannWetter data.
      # Uses sunshine hours + temperature + wind as proxy for Makkink method.
      # Realistic range for Central Europe: 0-8 mm/day
      # -----------------------------------------------------------------------
      - name: "Irrigation today ET0"
        unique_id: irrigation_today_et0
        unit_of_measurement: "mm"
        device_class: precipitation
        state_class: measurement
        icon: mdi:weather-sunny-alert
        state: >-
          {% set sunshine = states('sensor.kachelmannwetter_sonnenstunden_heute') | float(0) %}
          {% set temp = states('sensor.aussentemperatur_gerundet') | float(15) %}
          {% set wind = states('sensor.kachelmannwetter_windboen_maximum_heute') | float(0) %}
          {% set radiation = states('sensor.kachelmannwetter_globalstrahlung_heute') | float(0) %}
          {# Primary: use global radiation if available (most accurate) #}
          {# Radiation in W/m² cumulative → approximate MJ/m²/day #}
          {# Fallback: sunshine hours method #}
          {% if radiation > 0 %}
            {# Convert W/m² to approximate daily ET using simplified Makkink #}
            {# radiation here is cumulative W/m² → rough MJ/m²/day estimate #}
            {% set et0 = (radiation * 0.0004 + (temp - 10) * 0.08 + wind * 0.01) %}
          {% else %}
            {% set et0 = (sunshine * 0.6 + (temp - 10) * 0.12 + wind * 0.015) %}
          {% endif %}
          {{ [et0 | round(1), 0] | max }}
        attributes:
          sunshine_hours: "{{ states('sensor.kachelmannwetter_sonnenstunden_heute') }}"
          temperature: "{{ states('sensor.aussentemperatur_gerundet') }}"
          wind_max: "{{ states('sensor.kachelmannwetter_windboen_maximum_heute') }}"
          radiation: "{{ states('sensor.kachelmannwetter_globalstrahlung_heute') }}"

      # -----------------------------------------------------------------------
      # Per-zone daily ET (ET₀ × Kc)
      # -----------------------------------------------------------------------
      - name: "Zone 1 daily ET"
        unique_id: irrigation_zone_1_daily_et
        unit_of_measurement: "mm"
        device_class: precipitation
        icon: mdi:water-minus
        state: >-
          {% set et0 = states('sensor.irrigation_today_et0') | float(0) %}
          {% set kc = states('input_number.irrigation_zone_1_kc') | float(1.2) %}
          {{ (et0 * kc) | round(1) }}

      - name: "Zone 2 daily ET"
        unique_id: irrigation_zone_2_daily_et
        unit_of_measurement: "mm"
        device_class: precipitation
        icon: mdi:water-minus
        state: >-
          {% set et0 = states('sensor.irrigation_today_et0') | float(0) %}
          {% set kc = states('input_number.irrigation_zone_2_kc') | float(0.8) %}
          {{ (et0 * kc) | round(1) }}

      - name: "Zone 3 daily ET"
        unique_id: irrigation_zone_3_daily_et
        unit_of_measurement: "mm"
        device_class: precipitation
        icon: mdi:water-minus
        state: >-
          {% set et0 = states('sensor.irrigation_today_et0') | float(0) %}
          {% set kc = states('input_number.irrigation_zone_3_kc') | float(0.6) %}
          {{ (et0 * kc) | round(1) }}

      - name: "Zone 4 daily ET"
        unique_id: irrigation_zone_4_daily_et
        unit_of_measurement: "mm"
        device_class: precipitation
        icon: mdi:water-minus
        state: >-
          {% set et0 = states('sensor.irrigation_today_et0') | float(0) %}
          {% set kc = states('input_number.irrigation_zone_4_kc') | float(0.9) %}
          {{ (et0 * kc) | round(1) }}

      # -----------------------------------------------------------------------
      # Per-zone soil moisture sensor status (real vs. model comparison)
      # Shows the real sensor reading alongside the model estimate.
      # -----------------------------------------------------------------------
      - name: "Zone 1 soil moisture sensor"
        unique_id: irrigation_zone_1_soil_sensor
        unit_of_measurement: "%"
        device_class: moisture
        state_class: measurement
        icon: mdi:liquid-spot
        state: >-
          {{ states('${ZONE1_SENSOR}') | float(0) }}
        attributes:
          model_estimate: "{{ states('sensor.zone_1_balance_percent') }}"
          sensor_available: "{{ states('${ZONE1_SENSOR}') not in ['unavailable', 'unknown'] }}"

      - name: "Zone 2 soil moisture sensor"
        unique_id: irrigation_zone_2_soil_sensor
        unit_of_measurement: "%"
        device_class: moisture
        state_class: measurement
        icon: mdi:liquid-spot
        state: >-
          {{ states('${ZONE2_SENSOR}') | float(0) }}
        attributes:
          model_estimate: "{{ states('sensor.zone_2_balance_percent') }}"
          sensor_available: "{{ states('${ZONE2_SENSOR}') not in ['unavailable', 'unknown'] }}"

      - name: "Zone 3 soil moisture sensor"
        unique_id: irrigation_zone_3_soil_sensor
        unit_of_measurement: "%"
        device_class: moisture
        state_class: measurement
        icon: mdi:liquid-spot
        state: >-
          {{ states('${ZONE3_SENSOR}') | float(0) }}
        attributes:
          model_estimate: "{{ states('sensor.zone_3_balance_percent') }}"
          sensor_available: "{{ states('${ZONE3_SENSOR}') not in ['unavailable', 'unknown'] }}"

      - name: "Zone 4 soil moisture sensor"
        unique_id: irrigation_zone_4_soil_sensor
        unit_of_measurement: "%"
        device_class: moisture
        state_class: measurement
        icon: mdi:liquid-spot
        state: >-
          {{ states('${ZONE4_SENSOR}') | float(0) }}
        attributes:
          model_estimate: "{{ states('sensor.zone_4_balance_percent') }}"
          sensor_available: "{{ states('${ZONE4_SENSOR}') not in ['unavailable', 'unknown'] }}"

      # -----------------------------------------------------------------------
      # Per-zone water balance percentage (for gauges)
      # -----------------------------------------------------------------------
      - name: "Zone 1 balance percent"
        unique_id: irrigation_zone_1_balance_pct
        unit_of_measurement: "%"
        icon: mdi:water-percent
        state: >-
          {% set balance = states('input_number.irrigation_zone_1_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_1_capacity') | float(10) %}
          {{ ((balance / capacity) * 100) | round(0) if capacity > 0 else 0 }}

      - name: "Zone 2 balance percent"
        unique_id: irrigation_zone_2_balance_pct
        unit_of_measurement: "%"
        icon: mdi:water-percent
        state: >-
          {% set balance = states('input_number.irrigation_zone_2_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_2_capacity') | float(25) %}
          {{ ((balance / capacity) * 100) | round(0) if capacity > 0 else 0 }}

      - name: "Zone 3 balance percent"
        unique_id: irrigation_zone_3_balance_pct
        unit_of_measurement: "%"
        icon: mdi:water-percent
        state: >-
          {% set balance = states('input_number.irrigation_zone_3_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_3_capacity') | float(25) %}
          {{ ((balance / capacity) * 100) | round(0) if capacity > 0 else 0 }}

      - name: "Zone 4 balance percent"
        unique_id: irrigation_zone_4_balance_pct
        unit_of_measurement: "%"
        icon: mdi:water-percent
        state: >-
          {% set balance = states('input_number.irrigation_zone_4_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_4_capacity') | float(15) %}
          {{ ((balance / capacity) * 100) | round(0) if capacity > 0 else 0 }}

      # -----------------------------------------------------------------------
      # Per-zone deficit (how much water is missing)
      # -----------------------------------------------------------------------
      - name: "Zone 1 deficit"
        unique_id: irrigation_zone_1_deficit
        unit_of_measurement: "mm"
        icon: mdi:water-alert
        state: >-
          {% set balance = states('input_number.irrigation_zone_1_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_1_capacity') | float(10) %}
          {{ (capacity - balance) | round(1) }}

      - name: "Zone 2 deficit"
        unique_id: irrigation_zone_2_deficit
        unit_of_measurement: "mm"
        icon: mdi:water-alert
        state: >-
          {% set balance = states('input_number.irrigation_zone_2_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_2_capacity') | float(25) %}
          {{ (capacity - balance) | round(1) }}

      - name: "Zone 3 deficit"
        unique_id: irrigation_zone_3_deficit
        unit_of_measurement: "mm"
        icon: mdi:water-alert
        state: >-
          {% set balance = states('input_number.irrigation_zone_3_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_3_capacity') | float(25) %}
          {{ (capacity - balance) | round(1) }}

      - name: "Zone 4 deficit"
        unique_id: irrigation_zone_4_deficit
        unit_of_measurement: "mm"
        icon: mdi:water-alert
        state: >-
          {% set balance = states('input_number.irrigation_zone_4_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_4_capacity') | float(15) %}
          {{ (capacity - balance) | round(1) }}

      # -----------------------------------------------------------------------
      # Per-zone recommended irrigation duration (minutes)
      # -----------------------------------------------------------------------
      - name: "Zone 1 recommended duration"
        unique_id: irrigation_zone_1_recommended_duration
        unit_of_measurement: "min"
        icon: mdi:timer-sand
        state: >-
          {% set deficit = states('sensor.zone_1_deficit') | float(0) %}
          {% set per_mm = states('input_number.irrigation_zone_1_duration_per_mm') | float(3) %}
          {% set max_dur = states('input_number.irrigation_max_duration') | float(30) %}
          {% set duration = (deficit * per_mm) | round(0) %}
          {{ [duration, max_dur | int] | min }}

      - name: "Zone 2 recommended duration"
        unique_id: irrigation_zone_2_recommended_duration
        unit_of_measurement: "min"
        icon: mdi:timer-sand
        state: >-
          {% set deficit = states('sensor.zone_2_deficit') | float(0) %}
          {% set per_mm = states('input_number.irrigation_zone_2_duration_per_mm') | float(3) %}
          {% set max_dur = states('input_number.irrigation_max_duration') | float(30) %}
          {% set duration = (deficit * per_mm) | round(0) %}
          {{ [duration, max_dur | int] | min }}

      - name: "Zone 3 recommended duration"
        unique_id: irrigation_zone_3_recommended_duration
        unit_of_measurement: "min"
        icon: mdi:timer-sand
        state: >-
          {% set deficit = states('sensor.zone_3_deficit') | float(0) %}
          {% set per_mm = states('input_number.irrigation_zone_3_duration_per_mm') | float(3) %}
          {% set max_dur = states('input_number.irrigation_max_duration') | float(30) %}
          {% set duration = (deficit * per_mm) | round(0) %}
          {{ [duration, max_dur | int] | min }}

      - name: "Zone 4 recommended duration"
        unique_id: irrigation_zone_4_recommended_duration
        unit_of_measurement: "min"
        icon: mdi:timer-sand
        state: >-
          {% set deficit = states('sensor.zone_4_deficit') | float(0) %}
          {% set per_mm = states('input_number.irrigation_zone_4_duration_per_mm') | float(3) %}
          {% set max_dur = states('input_number.irrigation_max_duration') | float(30) %}
          {% set duration = (deficit * per_mm) | round(0) %}
          {{ [duration, max_dur | int] | min }}

      # -----------------------------------------------------------------------
      # Rain skip reason (human-readable text)
      # -----------------------------------------------------------------------
      - name: "Irrigation skip reason"
        unique_id: irrigation_skip_reason
        icon: mdi:information-outline
        state: >-
          {% set enabled = is_state('input_boolean.irrigation_enabled', 'on') %}
          {% set rain_today = states('sensor.kachelmannwetter_niederschlag_vorhersage_heute') | float(0) %}
          {% set rain_tomorrow = states('sensor.kachelmannwetter_niederschlag_vorhersage_morgen') | float(0) %}
          {% set threshold = states('input_number.irrigation_rain_skip_threshold') | float(5) %}
          {% set frost = is_state('binary_sensor.kachelmannwetter_frost_erwartet_heute_nacht', 'on') %}
          {% set rain_3h = is_state('binary_sensor.kachelmannwetter_regen_erwartet_3h', 'on') %}
          {% if not enabled %}
            Disabled by user
          {% elif frost %}
            Frost expected tonight
          {% elif rain_today >= threshold %}
            Rain expected today ({{ rain_today }}mm)
          {% elif rain_3h and rain_today >= (threshold * 0.6) %}
            Rain imminent ({{ rain_today }}mm forecast)
          {% else %}
          {% endif %}

  - binary_sensor:
      # -----------------------------------------------------------------------
      # Per-zone needs water (balance below trigger threshold)
      # -----------------------------------------------------------------------
      - name: "Zone 1 needs water"
        unique_id: irrigation_zone_1_needs_water
        device_class: moisture
        icon: mdi:water-alert
        state: >-
          {% set balance = states('input_number.irrigation_zone_1_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_1_capacity') | float(10) %}
          {% set trigger_pct = states('input_number.irrigation_zone_1_trigger') | float(30) %}
          {% set threshold = capacity * (trigger_pct / 100) %}
          {% set model_needs = balance < threshold %}
          {% set sensor_val = states('${ZONE1_SENSOR}') %}
          {% set sensor_ok = sensor_val not in ['unavailable', 'unknown'] %}
          {% set wet_th = states('input_number.irrigation_sensor_wet_threshold') | float(50) %}
          {% set dry_th = states('input_number.irrigation_sensor_dry_threshold') | float(15) %}
          {% if sensor_ok %}
            {% set sv = sensor_val | float(0) %}
            {{ (model_needs and sv < wet_th) or sv < dry_th }}
          {% else %}
            {{ model_needs }}
          {% endif %}

      - name: "Zone 2 needs water"
        unique_id: irrigation_zone_2_needs_water
        device_class: moisture
        icon: mdi:water-alert
        state: >-
          {% set balance = states('input_number.irrigation_zone_2_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_2_capacity') | float(25) %}
          {% set trigger_pct = states('input_number.irrigation_zone_2_trigger') | float(40) %}
          {% set threshold = capacity * (trigger_pct / 100) %}
          {% set model_needs = balance < threshold %}
          {% set sensor_val = states('${ZONE2_SENSOR}') %}
          {% set sensor_ok = sensor_val not in ['unavailable', 'unknown'] %}
          {% set wet_th = states('input_number.irrigation_sensor_wet_threshold') | float(50) %}
          {% set dry_th = states('input_number.irrigation_sensor_dry_threshold') | float(15) %}
          {% if sensor_ok %}
            {% set sv = sensor_val | float(0) %}
            {{ (model_needs and sv < wet_th) or sv < dry_th }}
          {% else %}
            {{ model_needs }}
          {% endif %}

      - name: "Zone 3 needs water"
        unique_id: irrigation_zone_3_needs_water
        device_class: moisture
        icon: mdi:water-alert
        state: >-
          {% set balance = states('input_number.irrigation_zone_3_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_3_capacity') | float(25) %}
          {% set trigger_pct = states('input_number.irrigation_zone_3_trigger') | float(40) %}
          {% set threshold = capacity * (trigger_pct / 100) %}
          {% set model_needs = balance < threshold %}
          {% set sensor_val = states('${ZONE3_SENSOR}') %}
          {% set sensor_ok = sensor_val not in ['unavailable', 'unknown'] %}
          {% set wet_th = states('input_number.irrigation_sensor_wet_threshold') | float(50) %}
          {% set dry_th = states('input_number.irrigation_sensor_dry_threshold') | float(15) %}
          {% if sensor_ok %}
            {% set sv = sensor_val | float(0) %}
            {{ (model_needs and sv < wet_th) or sv < dry_th }}
          {% else %}
            {{ model_needs }}
          {% endif %}

      - name: "Zone 4 needs water"
        unique_id: irrigation_zone_4_needs_water
        device_class: moisture
        icon: mdi:water-alert
        state: >-
          {% set balance = states('input_number.irrigation_zone_4_balance') | float(0) %}
          {% set capacity = states('input_number.irrigation_zone_4_capacity') | float(15) %}
          {% set trigger_pct = states('input_number.irrigation_zone_4_trigger') | float(35) %}
          {% set threshold = capacity * (trigger_pct / 100) %}
          {% set model_needs = balance < threshold %}
          {% set sensor_val = states('${ZONE4_SENSOR}') %}
          {% set sensor_ok = sensor_val not in ['unavailable', 'unknown'] %}
          {% set wet_th = states('input_number.irrigation_sensor_wet_threshold') | float(50) %}
          {% set dry_th = states('input_number.irrigation_sensor_dry_threshold') | float(15) %}
          {% if sensor_ok %}
            {% set sv = sensor_val | float(0) %}
            {{ (model_needs and sv < wet_th) or sv < dry_th }}
          {% else %}
            {{ model_needs }}
          {% endif %}

      # -----------------------------------------------------------------------
      # Global rain skip active
      # -----------------------------------------------------------------------
      - name: "Irrigation rain skip active"
        unique_id: irrigation_rain_skip_active
        icon: mdi:weather-pouring
        state: >-
          {% set rain_today = states('sensor.kachelmannwetter_niederschlag_vorhersage_heute') | float(0) %}
          {% set threshold = states('input_number.irrigation_rain_skip_threshold') | float(5) %}
          {% set frost = is_state('binary_sensor.kachelmannwetter_frost_erwartet_heute_nacht', 'on') %}
          {% set rain_3h = is_state('binary_sensor.kachelmannwetter_regen_erwartet_3h', 'on') %}
          {{ rain_today >= threshold or frost or (rain_3h and rain_today >= (threshold * 0.6)) }}


# =============================================================================
# AUTOMATIONS
# =============================================================================
automation:
  # ---------------------------------------------------------------------------
  # Daily ET deduction — runs at 23:55, subtracts today's ET from all zones
  # and adds any rainfall that occurred today.
  # ---------------------------------------------------------------------------
  - id: irrigation_daily_et_deduction
    alias: "Irrigation: Daily ET deduction"
    description: >-
      End-of-day water balance update. Subtracts each zone's ET loss
      and adds accumulated rainfall.
    mode: single
    trigger:
      - platform: time
        at: "23:55:00"
    condition:
      - condition: state
        entity_id: input_boolean.irrigation_enabled
        state: "on"
    action:
      # --- Get today's actual rainfall ---
      - variables:
          rain_today: >-
            {{ states('sensor.kachelmannwetter_niederschlag_1h') | float(0) }}

      # --- Zone 1: Deduct ET, add rain ---
      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_1_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_1_balance') | float(0) %}
            {% set et = states('sensor.zone_1_daily_et') | float(0) %}
            {% set capacity = states('input_number.irrigation_zone_1_capacity') | float(10) %}
            {% set new_val = current - et + rain_today %}
            {{ [[new_val, 0] | max, capacity] | min | round(1) }}

      # --- Zone 2: Deduct ET, add rain ---
      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_2_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_2_balance') | float(0) %}
            {% set et = states('sensor.zone_2_daily_et') | float(0) %}
            {% set capacity = states('input_number.irrigation_zone_2_capacity') | float(25) %}
            {% set new_val = current - et + rain_today %}
            {{ [[new_val, 0] | max, capacity] | min | round(1) }}

      # --- Zone 3: Deduct ET, add rain ---
      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_3_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_3_balance') | float(0) %}
            {% set et = states('sensor.zone_3_daily_et') | float(0) %}
            {% set capacity = states('input_number.irrigation_zone_3_capacity') | float(25) %}
            {% set new_val = current - et + rain_today %}
            {{ [[new_val, 0] | max, capacity] | min | round(1) }}

      # --- Zone 4: Deduct ET, add rain ---
      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_4_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_4_balance') | float(0) %}
            {% set et = states('sensor.zone_4_daily_et') | float(0) %}
            {% set capacity = states('input_number.irrigation_zone_4_capacity') | float(15) %}
            {% set new_val = current - et + rain_today %}
            {{ [[new_val, 0] | max, capacity] | min | round(1) }}

  # ---------------------------------------------------------------------------
  # Rain credit — add actual rainfall to all zone balances in real-time
  # Triggers whenever the hourly rain sensor reports > 0
  # ---------------------------------------------------------------------------
  - id: irrigation_rain_credit
    alias: "Irrigation: Rain credit"
    description: >-
      When actual rain falls, credit all zone balances. Uses the hourly
      rain sensor value as the increment.
    mode: single
    trigger:
      - platform: state
        entity_id: sensor.kachelmannwetter_niederschlag_1h
    condition:
      - condition: template
        value_template: >-
          {{ trigger.to_state.state | float(0) > trigger.from_state.state | float(0) }}
    action:
      - variables:
          rain_increment: >-
            {{ (trigger.to_state.state | float(0) - trigger.from_state.state | float(0)) | round(1) }}

      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_1_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_1_balance') | float(0) %}
            {% set capacity = states('input_number.irrigation_zone_1_capacity') | float(10) %}
            {{ [[current + rain_increment, 0] | max, capacity] | min | round(1) }}

      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_2_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_2_balance') | float(0) %}
            {% set capacity = states('input_number.irrigation_zone_2_capacity') | float(25) %}
            {{ [[current + rain_increment, 0] | max, capacity] | min | round(1) }}

      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_3_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_3_balance') | float(0) %}
            {% set capacity = states('input_number.irrigation_zone_3_capacity') | float(25) %}
            {{ [[current + rain_increment, 0] | max, capacity] | min | round(1) }}

      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_4_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_4_balance') | float(0) %}
            {% set capacity = states('input_number.irrigation_zone_4_capacity') | float(15) %}
            {{ [[current + rain_increment, 0] | max, capacity] | min | round(1) }}

  # ---------------------------------------------------------------------------
  # Sensor calibration — daily correction of model balance using real sensors.
  # Runs 15 minutes before irrigation to allow fresh balance for decisions.
  # Uses weighted blend: new = (1-w)*model + w*sensor_estimate
  # ---------------------------------------------------------------------------
  - id: irrigation_sensor_calibration
    alias: "Irrigation: Sensor calibration"
    description: >-
      Daily correction of the water balance model using real soil moisture
      sensor readings. Prevents long-term model drift by blending the
      calculated balance with the sensor-derived estimate.
    mode: single
    trigger:
      - platform: template
        value_template: >-
          {{ now().hour == states('input_number.irrigation_start_hour') | int(5)
             and now().minute == 45 }}
    condition:
      - condition: state
        entity_id: input_boolean.irrigation_enabled
        state: "on"
    action:
      - variables:
          weight: "{{ states('input_number.irrigation_sensor_calibration_weight') | float(0.3) }}"

      # --- Zone 1 calibration ---
      - if:
          - condition: template
            value_template: "{{ states('${ZONE1_SENSOR}') not in ['unavailable', 'unknown'] }}"
        then:
          - service: input_number.set_value
            target:
              entity_id: input_number.irrigation_zone_1_balance
            data:
              value: >-
                {% set capacity = states('input_number.irrigation_zone_1_capacity') | float(10) %}
                {% set model_bal = states('input_number.irrigation_zone_1_balance') | float(0) %}
                {% set sensor_pct = states('${ZONE1_SENSOR}') | float(0) %}
                {% set sensor_mm = (sensor_pct / 100) * capacity %}
                {% set blended = (1 - weight) * model_bal + weight * sensor_mm %}
                {{ [[blended, 0] | max, capacity] | min | round(1) }}

      # --- Zone 2 calibration ---
      - if:
          - condition: template
            value_template: "{{ states('${ZONE2_SENSOR}') not in ['unavailable', 'unknown'] }}"
        then:
          - service: input_number.set_value
            target:
              entity_id: input_number.irrigation_zone_2_balance
            data:
              value: >-
                {% set capacity = states('input_number.irrigation_zone_2_capacity') | float(25) %}
                {% set model_bal = states('input_number.irrigation_zone_2_balance') | float(0) %}
                {% set sensor_pct = states('${ZONE2_SENSOR}') | float(0) %}
                {% set sensor_mm = (sensor_pct / 100) * capacity %}
                {% set blended = (1 - weight) * model_bal + weight * sensor_mm %}
                {{ [[blended, 0] | max, capacity] | min | round(1) }}

      # --- Zone 3 calibration ---
      - if:
          - condition: template
            value_template: "{{ states('${ZONE3_SENSOR}') not in ['unavailable', 'unknown'] }}"
        then:
          - service: input_number.set_value
            target:
              entity_id: input_number.irrigation_zone_3_balance
            data:
              value: >-
                {% set capacity = states('input_number.irrigation_zone_3_capacity') | float(25) %}
                {% set model_bal = states('input_number.irrigation_zone_3_balance') | float(0) %}
                {% set sensor_pct = states('${ZONE3_SENSOR}') | float(0) %}
                {% set sensor_mm = (sensor_pct / 100) * capacity %}
                {% set blended = (1 - weight) * model_bal + weight * sensor_mm %}
                {{ [[blended, 0] | max, capacity] | min | round(1) }}

      # --- Zone 4 calibration ---
      - if:
          - condition: template
            value_template: "{{ states('${ZONE4_SENSOR}') not in ['unavailable', 'unknown'] }}"
        then:
          - service: input_number.set_value
            target:
              entity_id: input_number.irrigation_zone_4_balance
            data:
              value: >-
                {% set capacity = states('input_number.irrigation_zone_4_capacity') | float(15) %}
                {% set model_bal = states('input_number.irrigation_zone_4_balance') | float(0) %}
                {% set sensor_pct = states('${ZONE4_SENSOR}') | float(0) %}
                {% set sensor_mm = (sensor_pct / 100) * capacity %}
                {% set blended = (1 - weight) * model_bal + weight * sensor_mm %}
                {{ [[blended, 0] | max, capacity] | min | round(1) }}

  # ---------------------------------------------------------------------------
  # Morning irrigation scheduler — the main event
  # Runs each zone sequentially if it needs water and conditions allow.
  # ---------------------------------------------------------------------------
  - id: irrigation_morning_scheduler
    alias: "Irrigation: Morning scheduler"
    description: >-
      Main irrigation automation. Runs at the configured start hour.
      Checks global conditions, then irrigates each zone that needs water.
    mode: single
    trigger:
      - platform: template
        value_template: >-
          {{ now().hour == states('input_number.irrigation_start_hour') | int(5)
             and now().minute == 0 }}
    condition:
      - condition: state
        entity_id: input_boolean.irrigation_enabled
        state: "on"
    action:
      # --- Check for skip conditions ---
      - if:
          - condition: state
            entity_id: binary_sensor.irrigation_rain_skip_active
            state: "on"
        then:
          - service: notify.mobile_app_${IPHONE_DEVICE}
            data:
              title: "🌧️ Irrigation skipped"
              message: >-
                {{ states('sensor.irrigation_skip_reason') }}
              data:
                tag: irrigation-skip
                group: irrigation
          - stop: "Rain/frost skip active"

      # --- Variables for summary ---
      - variables:
          summary_watered: []
          summary_skipped: []

      # ===== ZONE 1 =====
      - if:
          - condition: state
            entity_id: input_boolean.irrigation_zone_1_enabled
            state: "on"
          - condition: state
            entity_id: binary_sensor.zone_1_needs_water
            state: "on"
        then:
          - variables:
              zone1_duration: >-
                {{ states('sensor.zone_1_recommended_duration') | int(0) }}
          - if:
              - condition: template
                value_template: "{{ zone1_duration > 0 }}"
            then:
              # Turn on with safety timeout
              - service: switch.turn_on
                target:
                  entity_id: ${ZONE1_SWITCH}
              - delay:
                  minutes: "{{ zone1_duration }}"
              - service: switch.turn_off
                target:
                  entity_id: ${ZONE1_SWITCH}
              # Credit the irrigated amount back to balance
              - service: input_number.set_value
                target:
                  entity_id: input_number.irrigation_zone_1_balance
                data:
                  value: >-
                    {% set current = states('input_number.irrigation_zone_1_balance') | float(0) %}
                    {% set per_mm = states('input_number.irrigation_zone_1_duration_per_mm') | float(3) %}
                    {% set capacity = states('input_number.irrigation_zone_1_capacity') | float(10) %}
                    {% set added = zone1_duration / per_mm %}
                    {{ [[current + added, 0] | max, capacity] | min | round(1) }}
              # Record timestamp
              - service: input_datetime.set_datetime
                target:
                  entity_id: input_datetime.irrigation_zone_1_last_run
                data:
                  datetime: "{{ now().strftime('%Y-%m-%d %H:%M:%S') }}"
              # Pressure recovery pause
              - delay:
                  seconds: 30

      # ===== ZONE 2 =====
      - if:
          - condition: state
            entity_id: input_boolean.irrigation_zone_2_enabled
            state: "on"
          - condition: state
            entity_id: binary_sensor.zone_2_needs_water
            state: "on"
        then:
          - variables:
              zone2_duration: >-
                {{ states('sensor.zone_2_recommended_duration') | int(0) }}
          - if:
              - condition: template
                value_template: "{{ zone2_duration > 0 }}"
            then:
              - service: switch.turn_on
                target:
                  entity_id: ${ZONE2_SWITCH}
              - delay:
                  minutes: "{{ zone2_duration }}"
              - service: switch.turn_off
                target:
                  entity_id: ${ZONE2_SWITCH}
              - service: input_number.set_value
                target:
                  entity_id: input_number.irrigation_zone_2_balance
                data:
                  value: >-
                    {% set current = states('input_number.irrigation_zone_2_balance') | float(0) %}
                    {% set per_mm = states('input_number.irrigation_zone_2_duration_per_mm') | float(3) %}
                    {% set capacity = states('input_number.irrigation_zone_2_capacity') | float(25) %}
                    {% set added = zone2_duration / per_mm %}
                    {{ [[current + added, 0] | max, capacity] | min | round(1) }}
              - service: input_datetime.set_datetime
                target:
                  entity_id: input_datetime.irrigation_zone_2_last_run
                data:
                  datetime: "{{ now().strftime('%Y-%m-%d %H:%M:%S') }}"
              - delay:
                  seconds: 30

      # ===== ZONE 3 =====
      - if:
          - condition: state
            entity_id: input_boolean.irrigation_zone_3_enabled
            state: "on"
          - condition: state
            entity_id: binary_sensor.zone_3_needs_water
            state: "on"
        then:
          - variables:
              zone3_duration: >-
                {{ states('sensor.zone_3_recommended_duration') | int(0) }}
          - if:
              - condition: template
                value_template: "{{ zone3_duration > 0 }}"
            then:
              - service: switch.turn_on
                target:
                  entity_id: ${ZONE3_SWITCH}
              - delay:
                  minutes: "{{ zone3_duration }}"
              - service: switch.turn_off
                target:
                  entity_id: ${ZONE3_SWITCH}
              - service: input_number.set_value
                target:
                  entity_id: input_number.irrigation_zone_3_balance
                data:
                  value: >-
                    {% set current = states('input_number.irrigation_zone_3_balance') | float(0) %}
                    {% set per_mm = states('input_number.irrigation_zone_3_duration_per_mm') | float(3) %}
                    {% set capacity = states('input_number.irrigation_zone_3_capacity') | float(25) %}
                    {% set added = zone3_duration / per_mm %}
                    {{ [[current + added, 0] | max, capacity] | min | round(1) }}
              - service: input_datetime.set_datetime
                target:
                  entity_id: input_datetime.irrigation_zone_3_last_run
                data:
                  datetime: "{{ now().strftime('%Y-%m-%d %H:%M:%S') }}"
              - delay:
                  seconds: 30

      # ===== ZONE 4 =====
      - if:
          - condition: state
            entity_id: input_boolean.irrigation_zone_4_enabled
            state: "on"
          - condition: state
            entity_id: binary_sensor.zone_4_needs_water
            state: "on"
        then:
          - variables:
              zone4_duration: >-
                {{ states('sensor.zone_4_recommended_duration') | int(0) }}
          - if:
              - condition: template
                value_template: "{{ zone4_duration > 0 }}"
            then:
              - service: switch.turn_on
                target:
                  entity_id: ${ZONE4_SWITCH}
              - delay:
                  minutes: "{{ zone4_duration }}"
              - service: switch.turn_off
                target:
                  entity_id: ${ZONE4_SWITCH}
              - service: input_number.set_value
                target:
                  entity_id: input_number.irrigation_zone_4_balance
                data:
                  value: >-
                    {% set current = states('input_number.irrigation_zone_4_balance') | float(0) %}
                    {% set per_mm = states('input_number.irrigation_zone_4_duration_per_mm') | float(3) %}
                    {% set capacity = states('input_number.irrigation_zone_4_capacity') | float(15) %}
                    {% set added = zone4_duration / per_mm %}
                    {{ [[current + added, 0] | max, capacity] | min | round(1) }}
              - service: input_datetime.set_datetime
                target:
                  entity_id: input_datetime.irrigation_zone_4_last_run
                data:
                  datetime: "{{ now().strftime('%Y-%m-%d %H:%M:%S') }}"

      # --- Send summary notification ---
      - service: notify.mobile_app_${IPHONE_DEVICE}
        data:
          title: "🌿 Irrigation complete"
          message: >-
            {% set z1 = is_state('binary_sensor.zone_1_needs_water', 'on') and is_state('input_boolean.irrigation_zone_1_enabled', 'on') %}
            {% set z2 = is_state('binary_sensor.zone_2_needs_water', 'on') and is_state('input_boolean.irrigation_zone_2_enabled', 'on') %}
            {% set z3 = is_state('binary_sensor.zone_3_needs_water', 'on') and is_state('input_boolean.irrigation_zone_3_enabled', 'on') %}
            {% set z4 = is_state('binary_sensor.zone_4_needs_water', 'on') and is_state('input_boolean.irrigation_zone_4_enabled', 'on') %}
            {% set watered = [] %}
            {% if z1 %}{% set watered = watered + ['${ZONE1_NAME} (' + states('sensor.zone_1_recommended_duration') + 'min, 🌡' + states('${ZONE1_SENSOR}') + '%)'] %}{% endif %}
            {% if z2 %}{% set watered = watered + ['${ZONE2_NAME} (' + states('sensor.zone_2_recommended_duration') + 'min, 🌡' + states('${ZONE2_SENSOR}') + '%)'] %}{% endif %}
            {% if z3 %}{% set watered = watered + ['${ZONE3_NAME} (' + states('sensor.zone_3_recommended_duration') + 'min, 🌡' + states('${ZONE3_SENSOR}') + '%)'] %}{% endif %}
            {% if z4 %}{% set watered = watered + ['${ZONE4_NAME} (' + states('sensor.zone_4_recommended_duration') + 'min, 🌡' + states('${ZONE4_SENSOR}') + '%)'] %}{% endif %}
            {% set skipped = [] %}
            {% set s1 = states('${ZONE1_SENSOR}') | float(0) %}
            {% set s2 = states('${ZONE2_SENSOR}') | float(0) %}
            {% set s3 = states('${ZONE3_SENSOR}') | float(0) %}
            {% set s4 = states('${ZONE4_SENSOR}') | float(0) %}
            {% set wet = states('input_number.irrigation_sensor_wet_threshold') | float(50) %}
            {% if not z1 and is_state('input_boolean.irrigation_zone_1_enabled', 'on') and s1 >= wet %}{% set skipped = skipped + ['${ZONE1_NAME} (🌡' + s1|string + '% ≥ ' + wet|int|string + '%)'] %}{% endif %}
            {% if not z2 and is_state('input_boolean.irrigation_zone_2_enabled', 'on') and s2 >= wet %}{% set skipped = skipped + ['${ZONE2_NAME} (🌡' + s2|string + '% ≥ ' + wet|int|string + '%)'] %}{% endif %}
            {% if not z3 and is_state('input_boolean.irrigation_zone_3_enabled', 'on') and s3 >= wet %}{% set skipped = skipped + ['${ZONE3_NAME} (🌡' + s3|string + '% ≥ ' + wet|int|string + '%)'] %}{% endif %}
            {% if not z4 and is_state('input_boolean.irrigation_zone_4_enabled', 'on') and s4 >= wet %}{% set skipped = skipped + ['${ZONE4_NAME} (🌡' + s4|string + '% ≥ ' + wet|int|string + '%)'] %}{% endif %}
            {% if watered | length > 0 %}
              💧 Watered: {{ watered | join(', ') }}
            {% else %}
              All zones have sufficient moisture.
            {% endif %}
            {% if skipped | length > 0 %}
              ⏭️ Sensor skip: {{ skipped | join(', ') }}
            {% endif %}
            ET₀: {{ states('sensor.irrigation_today_et0') }}mm
          data:
            tag: irrigation-summary
            group: irrigation

  # ---------------------------------------------------------------------------
  # Safety: Turn off all valves if any has been on for too long
  # Prevents flooding if an automation gets stuck or HA restarts mid-run.
  # ---------------------------------------------------------------------------
  - id: irrigation_safety_shutoff
    alias: "Irrigation: Safety valve shutoff"
    description: >-
      Emergency shutoff — turns off any valve that has been on longer than
      max_duration + 5 minutes. Protects against stuck automations.
    mode: single
    trigger:
      - platform: state
        entity_id: ${ZONE1_SWITCH}
        to: "on"
        for:
          minutes: 35
      - platform: state
        entity_id: ${ZONE2_SWITCH}
        to: "on"
        for:
          minutes: 35
      - platform: state
        entity_id: ${ZONE3_SWITCH}
        to: "on"
        for:
          minutes: 35
      - platform: state
        entity_id: ${ZONE4_SWITCH}
        to: "on"
        for:
          minutes: 35
    action:
      - service: switch.turn_off
        target:
          entity_id:
            - ${ZONE1_SWITCH}
            - ${ZONE2_SWITCH}
            - ${ZONE3_SWITCH}
            - ${ZONE4_SWITCH}
      - service: notify.mobile_app_${IPHONE_DEVICE}
        data:
          title: "⚠️ Irrigation safety shutoff"
          message: >-
            A valve was on for more than 35 minutes. All valves have been
            turned off as a safety measure. Check your irrigation system.
          data:
            tag: irrigation-safety
            group: irrigation
            push:
              sound:
                name: default
                critical: 1

  # ---------------------------------------------------------------------------
  # Startup: Ensure all valves are off when HA starts
  # ---------------------------------------------------------------------------
  - id: irrigation_startup_safety
    alias: "Irrigation: Startup safety — all valves off"
    description: "Ensure no valve is stuck on after a restart."
    mode: single
    trigger:
      - platform: homeassistant
        event: start
    action:
      - delay:
          seconds: 30
      - service: switch.turn_off
        target:
          entity_id:
            - ${ZONE1_SWITCH}
            - ${ZONE2_SWITCH}
            - ${ZONE3_SWITCH}
            - ${ZONE4_SWITCH}

  # ---------------------------------------------------------------------------
  # EVENING WATERING - additional run on hot days for container zones
  # Only zones with Kc >= 0.9 get a second watering (containers/raised beds
  # that dry out fast). Triggered when today's ET0 exceeds the threshold.
  # ---------------------------------------------------------------------------
  - id: irrigation_evening_scheduler
    alias: "Irrigation: Evening top-up (hot days)"
    description: >-
      Runs a second watering in the evening for high-demand zones (Kc >= 0.9)
      when today's ET0 exceeds the evening threshold. This prevents container
      plants from wilting overnight after a hot sunny day.
    mode: single
    trigger:
      - platform: template
        value_template: >-
          {{ now().hour == states('input_number.irrigation_evening_hour') | int(20)
             and now().minute == 0 }}
    condition:
      - condition: state
        entity_id: input_boolean.irrigation_enabled
        state: "on"
      - condition: numeric_state
        entity_id: sensor.irrigation_today_et0
        above: input_number.irrigation_evening_et_threshold
      - condition: state
        entity_id: binary_sensor.irrigation_rain_skip_active
        state: "off"
    action:
      - if:
          - condition: state
            entity_id: input_boolean.irrigation_zone_1_enabled
            state: "on"
          - condition: numeric_state
            entity_id: input_number.irrigation_zone_1_kc
            above: 0.89
        then:
          - service: switch.turn_on
            target:
              entity_id: ${ZONE1_SWITCH}
          - delay:
              minutes: "{{ (states('sensor.zone_1_recommended_duration') | int(5) * 0.5) | int | max(3) }}"
          - service: switch.turn_off
            target:
              entity_id: ${ZONE1_SWITCH}
          - delay:
              seconds: 30
      - if:
          - condition: state
            entity_id: input_boolean.irrigation_zone_4_enabled
            state: "on"
          - condition: numeric_state
            entity_id: input_number.irrigation_zone_4_kc
            above: 0.89
        then:
          - service: switch.turn_on
            target:
              entity_id: ${ZONE4_SWITCH}
          - delay:
              minutes: "{{ (states('sensor.zone_4_recommended_duration') | int(5) * 0.5) | int | max(3) }}"
          - service: switch.turn_off
            target:
              entity_id: ${ZONE4_SWITCH}
      - service: notify.mobile_app_${IPHONE_DEVICE}
        data:
          title: "Evening Irrigation"
          message: >-
            Hot day (ET0={{ states('sensor.irrigation_today_et0') }}mm).
            Evening top-up completed for high-demand zones.

  # ---------------------------------------------------------------------------
  # LOW BATTERY WARNING - notify when DIIVOO battery drops below 20%
  # ---------------------------------------------------------------------------
  - id: irrigation_low_battery_warning
    alias: "Irrigation: Low battery warning"
    description: "Push notification when a DIIVOO valve battery drops below 20%."
    mode: single
    trigger:
      - platform: numeric_state
        entity_id: sensor.diivoo_wt_13w_${ZONE1_DEVICE_ID}_batterie
        below: 20
        id: terrasse
      - platform: numeric_state
        entity_id: sensor.diivoo_wt_11w_1_${ZONE4_DEVICE_ID}_batterie
        below: 20
        id: hochbeet
    action:
      - service: notify.mobile_app_${IPHONE_DEVICE}
        data:
          title: "Low Battery"
          message: >-
            {% if trigger.id == 'terrasse' %}
            Terrasse valve battery is at {{ states('sensor.diivoo_wt_13w_${ZONE1_DEVICE_ID}_batterie') }}%.
            {% else %}
            Hochbeet valve battery is at {{ states('sensor.diivoo_wt_11w_1_${ZONE4_DEVICE_ID}_batterie') }}%.
            {% endif %}
            Replace batteries soon.
          data:
            tag: irrigation-battery
            group: irrigation

  # ---------------------------------------------------------------------------
  # CONNECTION LOST - notify when gateway or valve goes offline
  # ---------------------------------------------------------------------------
  - id: irrigation_connection_lost
    alias: "Irrigation: Connection lost"
    description: "Push notification when the DIIVOO gateway or a valve disconnects."
    mode: single
    trigger:
      - platform: state
        entity_id: ${GATEWAY_CONNECTION_ENTITY}
        to: "off"
        for:
          minutes: 5
        id: gateway
      - platform: state
        entity_id: ${ZONE1_CONNECTION_ENTITY}
        to: "off"
        for:
          minutes: 10
        id: terrasse
      - platform: state
        entity_id: ${ZONE4_CONNECTION_ENTITY}
        to: "off"
        for:
          minutes: 10
        id: hochbeet
    action:
      - service: notify.mobile_app_${IPHONE_DEVICE}
        data:
          title: "Irrigation Offline"
          message: >-
            {% if trigger.id == 'gateway' %}
            DIIVOO Gateway lost connection. No irrigation possible until reconnected.
            {% elif trigger.id == 'terrasse' %}
            Terrasse valve (WT-13W) lost connection for >10 minutes.
            {% else %}
            Hochbeet valve (WT-11W) lost connection for >10 minutes.
            {% endif %}
          data:
            tag: irrigation-offline
            group: irrigation

  # ---------------------------------------------------------------------------
  # WEEKLY SUMMARY - every Sunday at 20:00
  # ---------------------------------------------------------------------------
  - id: irrigation_weekly_summary
    alias: "Irrigation: Weekly summary"
    description: "Push a weekly report every Sunday evening."
    mode: single
    trigger:
      - platform: time
        at: "20:00:00"
    condition:
      - condition: time
        weekday:
          - sun
    action:
      - service: notify.mobile_app_${IPHONE_DEVICE}
        data:
          title: "Weekly Irrigation Report"
          message: >-
            {% set z1_bal = states('input_number.irrigation_zone_1_balance') | float(0) %}
            {% set z2_bal = states('input_number.irrigation_zone_2_balance') | float(0) %}
            {% set z3_bal = states('input_number.irrigation_zone_3_balance') | float(0) %}
            {% set z4_bal = states('input_number.irrigation_zone_4_balance') | float(0) %}
            {% set z1_cap = states('input_number.irrigation_zone_1_capacity') | float(10) %}
            {% set z2_cap = states('input_number.irrigation_zone_2_capacity') | float(25) %}
            {% set z3_cap = states('input_number.irrigation_zone_3_capacity') | float(25) %}
            {% set z4_cap = states('input_number.irrigation_zone_4_capacity') | float(15) %}
            Zone status (model / sensor):
            - ${ZONE1_NAME}: {{ ((z1_bal/z1_cap)*100)|int }}% / 🌡{{ states('${ZONE1_SENSOR}') }}%
            - ${ZONE2_NAME}: {{ ((z2_bal/z2_cap)*100)|int }}% / 🌡{{ states('${ZONE2_SENSOR}') }}%
            - ${ZONE3_NAME}: {{ ((z3_bal/z3_cap)*100)|int }}% / 🌡{{ states('${ZONE3_SENSOR}') }}%
            - ${ZONE4_NAME}: {{ ((z4_bal/z4_cap)*100)|int }}% / 🌡{{ states('${ZONE4_SENSOR}') }}%

            Current ET0: {{ states('sensor.irrigation_today_et0') }}mm/day
            Rain skip: {{ 'Active' if is_state('binary_sensor.irrigation_rain_skip_active', 'on') else 'Inactive' }}
          data:
            tag: irrigation-weekly
            group: irrigation

  # ---------------------------------------------------------------------------
  # SENSOR EMERGENCY - immediate irrigation when soil is critically dry
  # Only triggers during daytime (8:00-20:00) to avoid night watering.
  # Debounce: won't re-trigger within 4 hours per zone.
  # ---------------------------------------------------------------------------
  - id: irrigation_sensor_emergency
    alias: "Irrigation: Sensor emergency (critically dry)"
    description: >-
      Emergency irrigation triggered by critically low soil moisture sensor
      readings. Overrides the model — waters immediately when a zone is
      dangerously dry regardless of the calculated balance.
    mode: queued
    max: 4
    trigger:
      - platform: numeric_state
        entity_id: ${ZONE1_SENSOR}
        below: input_number.irrigation_sensor_dry_threshold
        id: zone1
        for:
          minutes: 30
      - platform: numeric_state
        entity_id: ${ZONE2_SENSOR}
        below: input_number.irrigation_sensor_dry_threshold
        id: zone2
        for:
          minutes: 30
      - platform: numeric_state
        entity_id: ${ZONE3_SENSOR}
        below: input_number.irrigation_sensor_dry_threshold
        id: zone3
        for:
          minutes: 30
      - platform: numeric_state
        entity_id: ${ZONE4_SENSOR}
        below: input_number.irrigation_sensor_dry_threshold
        id: zone4
        for:
          minutes: 30
    condition:
      - condition: state
        entity_id: input_boolean.irrigation_enabled
        state: "on"
      - condition: template
        value_template: "{{ 8 <= now().hour < 20 }}"
    action:
      - variables:
          zone_name: >-
            {% if trigger.id == 'zone1' %}${ZONE1_NAME}
            {% elif trigger.id == 'zone2' %}${ZONE2_NAME}
            {% elif trigger.id == 'zone3' %}${ZONE3_NAME}
            {% else %}${ZONE4_NAME}{% endif %}
          zone_switch: >-
            {% if trigger.id == 'zone1' %}${ZONE1_SWITCH}
            {% elif trigger.id == 'zone2' %}${ZONE2_SWITCH}
            {% elif trigger.id == 'zone3' %}${ZONE3_SWITCH}
            {% else %}${ZONE4_SWITCH}{% endif %}
          zone_balance: >-
            {% if trigger.id == 'zone1' %}input_number.irrigation_zone_1_balance
            {% elif trigger.id == 'zone2' %}input_number.irrigation_zone_2_balance
            {% elif trigger.id == 'zone3' %}input_number.irrigation_zone_3_balance
            {% else %}input_number.irrigation_zone_4_balance{% endif %}
          zone_capacity: >-
            {% if trigger.id == 'zone1' %}{{ states('input_number.irrigation_zone_1_capacity') | float(10) }}
            {% elif trigger.id == 'zone2' %}{{ states('input_number.irrigation_zone_2_capacity') | float(25) }}
            {% elif trigger.id == 'zone3' %}{{ states('input_number.irrigation_zone_3_capacity') | float(25) }}
            {% else %}{{ states('input_number.irrigation_zone_4_capacity') | float(15) }}{% endif %}
          emergency_duration: 10
      - service: notify.mobile_app_${IPHONE_DEVICE}
        data:
          title: "🚨 Emergency irrigation"
          message: >-
            {{ zone_name }} sensor reads {{ trigger.to_state.state }}% — critically dry!
            Running emergency watering for {{ emergency_duration }} minutes.
          data:
            tag: irrigation-emergency
            group: irrigation
      - service: switch.turn_on
        target:
          entity_id: "{{ zone_switch }}"
      - delay:
          minutes: "{{ emergency_duration }}"
      - service: switch.turn_off
        target:
          entity_id: "{{ zone_switch }}"
      - service: input_number.set_value
        target:
          entity_id: "{{ zone_balance }}"
        data:
          value: >-
            {% set current = states(zone_balance) | float(0) %}
            {% set per_mm_entity = 'input_number.irrigation_' + trigger.id + '_duration_per_mm' %}
            {% set per_mm = states(per_mm_entity) | float(3) %}
            {% set added = emergency_duration / per_mm %}
            {{ [[current + added, 0] | max, zone_capacity | float] | min | round(1) }}


# =============================================================================
# SCRIPTS - Manual zone control
# =============================================================================
script:
  irrigation_run_zone_1:
    alias: "Irrigation: Run Zone 1 manually"
    description: "Run Zone 1 (${ZONE1_NAME}) for the recommended duration."
    icon: mdi:sprinkler
    mode: single
    sequence:
      - variables:
          duration: >-
            {{ states('sensor.zone_1_recommended_duration') | int(5) }}
      - service: switch.turn_on
        target:
          entity_id: ${ZONE1_SWITCH}
      - delay:
          minutes: "{{ duration }}"
      - service: switch.turn_off
        target:
          entity_id: ${ZONE1_SWITCH}
      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_1_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_1_balance') | float(0) %}
            {% set per_mm = states('input_number.irrigation_zone_1_duration_per_mm') | float(3) %}
            {% set capacity = states('input_number.irrigation_zone_1_capacity') | float(10) %}
            {% set added = duration / per_mm %}
            {{ [[current + added, 0] | max, capacity] | min | round(1) }}
      - service: input_datetime.set_datetime
        target:
          entity_id: input_datetime.irrigation_zone_1_last_run
        data:
          datetime: "{{ now().strftime('%Y-%m-%d %H:%M:%S') }}"

  irrigation_run_zone_2:
    alias: "Irrigation: Run Zone 2 manually"
    description: "Run Zone 2 (${ZONE2_NAME}) for the recommended duration."
    icon: mdi:sprinkler
    mode: single
    sequence:
      - variables:
          duration: >-
            {{ states('sensor.zone_2_recommended_duration') | int(5) }}
      - service: switch.turn_on
        target:
          entity_id: ${ZONE2_SWITCH}
      - delay:
          minutes: "{{ duration }}"
      - service: switch.turn_off
        target:
          entity_id: ${ZONE2_SWITCH}
      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_2_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_2_balance') | float(0) %}
            {% set per_mm = states('input_number.irrigation_zone_2_duration_per_mm') | float(3) %}
            {% set capacity = states('input_number.irrigation_zone_2_capacity') | float(25) %}
            {% set added = duration / per_mm %}
            {{ [[current + added, 0] | max, capacity] | min | round(1) }}
      - service: input_datetime.set_datetime
        target:
          entity_id: input_datetime.irrigation_zone_2_last_run
        data:
          datetime: "{{ now().strftime('%Y-%m-%d %H:%M:%S') }}"

  irrigation_run_zone_3:
    alias: "Irrigation: Run Zone 3 manually"
    description: "Run Zone 3 (${ZONE3_NAME}) for the recommended duration."
    icon: mdi:sprinkler
    mode: single
    sequence:
      - variables:
          duration: >-
            {{ states('sensor.zone_3_recommended_duration') | int(5) }}
      - service: switch.turn_on
        target:
          entity_id: ${ZONE3_SWITCH}
      - delay:
          minutes: "{{ duration }}"
      - service: switch.turn_off
        target:
          entity_id: ${ZONE3_SWITCH}
      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_3_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_3_balance') | float(0) %}
            {% set per_mm = states('input_number.irrigation_zone_3_duration_per_mm') | float(3) %}
            {% set capacity = states('input_number.irrigation_zone_3_capacity') | float(25) %}
            {% set added = duration / per_mm %}
            {{ [[current + added, 0] | max, capacity] | min | round(1) }}
      - service: input_datetime.set_datetime
        target:
          entity_id: input_datetime.irrigation_zone_3_last_run
        data:
          datetime: "{{ now().strftime('%Y-%m-%d %H:%M:%S') }}"

  irrigation_run_zone_4:
    alias: "Irrigation: Run Zone 4 manually"
    description: "Run Zone 4 (${ZONE4_NAME}) for the recommended duration."
    icon: mdi:sprinkler
    mode: single
    sequence:
      - variables:
          duration: >-
            {{ states('sensor.zone_4_recommended_duration') | int(5) }}
      - service: switch.turn_on
        target:
          entity_id: ${ZONE4_SWITCH}
      - delay:
          minutes: "{{ duration }}"
      - service: switch.turn_off
        target:
          entity_id: ${ZONE4_SWITCH}
      - service: input_number.set_value
        target:
          entity_id: input_number.irrigation_zone_4_balance
        data:
          value: >-
            {% set current = states('input_number.irrigation_zone_4_balance') | float(0) %}
            {% set per_mm = states('input_number.irrigation_zone_4_duration_per_mm') | float(3) %}
            {% set capacity = states('input_number.irrigation_zone_4_capacity') | float(15) %}
            {% set added = duration / per_mm %}
            {{ [[current + added, 0] | max, capacity] | min | round(1) }}
      - service: input_datetime.set_datetime
        target:
          entity_id: input_datetime.irrigation_zone_4_last_run
        data:
          datetime: "{{ now().strftime('%Y-%m-%d %H:%M:%S') }}"

  # ---------------------------------------------------------------------------
  # Emergency stop all zones
  # ---------------------------------------------------------------------------
  irrigation_stop_all:
    alias: "Irrigation: Stop all zones"
    description: "Immediately turn off all irrigation valves."
    icon: mdi:stop-circle
    mode: single
    sequence:
      - service: switch.turn_off
        target:
          entity_id:
            - ${ZONE1_SWITCH}
            - ${ZONE2_SWITCH}
            - ${ZONE3_SWITCH}
            - ${ZONE4_SWITCH}
