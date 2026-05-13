###############################################################################
# Dashboard: Smart Irrigation
#
# Clean, scannable dashboard with soil moisture sensors front and center.
# Three views: Overview (at-a-glance), History (all graphs), Settings (tuning).
###############################################################################
views:
  # ===========================================================================
  # VIEW 1: OVERVIEW — everything at a glance, minimal scrolling
  # ===========================================================================
  - title: Overview
    path: overview
    icon: mdi:sprinkler-variant
    type: sections
    sections:
      - title: "Status"
        cards:
          - type: tile
            entity: input_boolean.irrigation_enabled
            name: Bewässerung
            color: green
            tap_action:
              action: toggle
          - type: tile
            entity: sensor.irrigation_today_et0
            name: "Verdunstung heute"
            icon: mdi:weather-sunny-alert
            color: orange
          - type: tile
            entity: binary_sensor.irrigation_rain_skip_active
            name: Regen-Pause
            icon: mdi:weather-pouring
            color: blue

      - title: "Bodenfeuchte"
        cards:
          - type: tile
            entity: ${ZONE1_SENSOR}
            name: "${ZONE1_NAME}"
            icon: mdi:liquid-spot
            color: cyan
          - type: tile
            entity: ${ZONE2_SENSOR}
            name: "${ZONE2_NAME}"
            icon: mdi:liquid-spot
            color: cyan
          - type: tile
            entity: ${ZONE3_SENSOR}
            name: "${ZONE3_NAME}"
            icon: mdi:liquid-spot
            color: cyan
          - type: tile
            entity: ${ZONE4_SENSOR}
            name: "${ZONE4_NAME}"
            icon: mdi:liquid-spot
            color: cyan
          - type: history-graph
            title: "Letzte 7 Tage"
            hours_to_show: 168
            entities:
              - entity: ${ZONE1_SENSOR}
                name: "${ZONE1_NAME}"
              - entity: ${ZONE2_SENSOR}
                name: "${ZONE2_NAME}"
              - entity: ${ZONE3_SENSOR}
                name: "${ZONE3_NAME}"
              - entity: ${ZONE4_SENSOR}
                name: "${ZONE4_NAME}"

      - title: "Bewässerungsbedarf"
        cards:
          - type: entities
            entities:
              - entity: binary_sensor.zone_1_needs_water
                name: "${ZONE1_NAME}"
                secondary_info: last-changed
              - entity: binary_sensor.zone_2_needs_water
                name: "${ZONE2_NAME}"
                secondary_info: last-changed
              - entity: binary_sensor.zone_3_needs_water
                name: "${ZONE3_NAME}"
                secondary_info: last-changed
              - entity: binary_sensor.zone_4_needs_water
                name: "${ZONE4_NAME}"
                secondary_info: last-changed
          - type: entities
            entities:
              - entity: sensor.zone_1_recommended_duration
                name: "${ZONE1_NAME}"
                icon: mdi:timer-sand
              - entity: sensor.zone_2_recommended_duration
                name: "${ZONE2_NAME}"
                icon: mdi:timer-sand
              - entity: sensor.zone_3_recommended_duration
                name: "${ZONE3_NAME}"
                icon: mdi:timer-sand
              - entity: sensor.zone_4_recommended_duration
                name: "${ZONE4_NAME}"
                icon: mdi:timer-sand
          - type: button
            entity: script.irrigation_run_zone_1
            name: "${ZONE1_NAME}"
            icon: mdi:sprinkler
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_1
          - type: button
            entity: script.irrigation_run_zone_2
            name: "${ZONE2_NAME}"
            icon: mdi:sprinkler
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_2
          - type: button
            entity: script.irrigation_run_zone_3
            name: "${ZONE3_NAME}"
            icon: mdi:sprinkler
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_3
          - type: button
            entity: script.irrigation_run_zone_4
            name: "${ZONE4_NAME}"
            icon: mdi:sprinkler
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_4
          - type: button
            entity: script.irrigation_stop_all
            name: "STOP"
            icon: mdi:stop-circle
            tap_action:
              action: perform-action
              perform_action: script.irrigation_stop_all

  # ===========================================================================
  # VIEW 2: HISTORY — all graphs, for deep-dives
  # ===========================================================================
  - title: History
    path: history
    icon: mdi:chart-line
    type: sections
    sections:
      - title: "Bodenfeuchte Sensoren"
        cards:
          - type: history-graph
            hours_to_show: 168
            entities:
              - entity: ${ZONE1_SENSOR}
                name: "${ZONE1_NAME}"
              - entity: ${ZONE2_SENSOR}
                name: "${ZONE2_NAME}"
              - entity: ${ZONE3_SENSOR}
                name: "${ZONE3_NAME}"
              - entity: ${ZONE4_SENSOR}
                name: "${ZONE4_NAME}"

      - title: "Modell-Bilanz"
        cards:
          - type: history-graph
            hours_to_show: 168
            entities:
              - entity: input_number.irrigation_zone_1_balance
                name: "${ZONE1_NAME}"
              - entity: input_number.irrigation_zone_2_balance
                name: "${ZONE2_NAME}"
              - entity: input_number.irrigation_zone_3_balance
                name: "${ZONE3_NAME}"
              - entity: input_number.irrigation_zone_4_balance
                name: "${ZONE4_NAME}"

      - title: "Evapotranspiration"
        cards:
          - type: history-graph
            hours_to_show: 168
            entities:
              - entity: sensor.irrigation_today_et0
                name: "ET₀ Referenz"
              - entity: sensor.zone_1_daily_et
                name: "${ZONE1_NAME}"
              - entity: sensor.zone_2_daily_et
                name: "${ZONE2_NAME}"
              - entity: sensor.zone_3_daily_et
                name: "${ZONE3_NAME}"
              - entity: sensor.zone_4_daily_et
                name: "${ZONE4_NAME}"

      - title: "Regen & Skips"
        cards:
          - type: history-graph
            hours_to_show: 168
            entities:
              - entity: sensor.kachelmannwetter_niederschlag_1h
                name: "Regen mm/h"
              - entity: binary_sensor.irrigation_rain_skip_active
                name: "Skip aktiv"
              - entity: sensor.kachelmannwetter_niederschlag_vorhersage_heute
                name: "Vorhersage"

      - title: "Wetter"
        cards:
          - type: history-graph
            hours_to_show: 168
            entities:
              - entity: sensor.aussentemperatur_gerundet
                name: "Temperatur °C"
              - entity: sensor.kachelmannwetter_sonnenstunden_heute
                name: "Sonne h"
              - entity: sensor.kachelmannwetter_windboen_maximum_heute
                name: "Wind km/h"

      - title: "Ventile"
        cards:
          - type: history-graph
            hours_to_show: 168
            entities:
              - entity: ${ZONE1_SWITCH}
                name: "${ZONE1_NAME}"
              - entity: ${ZONE2_SWITCH}
                name: "${ZONE2_NAME}"
              - entity: ${ZONE3_SWITCH}
                name: "${ZONE3_NAME}"
              - entity: ${ZONE4_SWITCH}
                name: "${ZONE4_NAME}"

  # ===========================================================================
  # VIEW 3: SETTINGS — tuning parameters
  # ===========================================================================
  - title: Settings
    path: settings
    icon: mdi:cog
    type: sections
    sections:
      - title: "Zeitplan"
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_start_hour
              - entity: input_number.irrigation_evening_hour
              - entity: input_number.irrigation_evening_et_threshold
              - entity: input_number.irrigation_max_duration
              - entity: input_number.irrigation_rain_skip_threshold

      - title: "Sensor-Schwellwerte"
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_sensor_wet_threshold
              - entity: input_number.irrigation_sensor_dry_threshold
              - entity: input_number.irrigation_sensor_calibration_weight

      - title: "${ZONE1_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_boolean.irrigation_zone_1_enabled
              - entity: input_number.irrigation_zone_1_kc
              - entity: input_number.irrigation_zone_1_capacity
              - entity: input_number.irrigation_zone_1_trigger
              - entity: input_number.irrigation_zone_1_duration_per_mm
              - entity: input_number.irrigation_zone_1_balance

      - title: "${ZONE2_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_boolean.irrigation_zone_2_enabled
              - entity: input_number.irrigation_zone_2_kc
              - entity: input_number.irrigation_zone_2_capacity
              - entity: input_number.irrigation_zone_2_trigger
              - entity: input_number.irrigation_zone_2_duration_per_mm
              - entity: input_number.irrigation_zone_2_balance

      - title: "${ZONE3_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_boolean.irrigation_zone_3_enabled
              - entity: input_number.irrigation_zone_3_kc
              - entity: input_number.irrigation_zone_3_capacity
              - entity: input_number.irrigation_zone_3_trigger
              - entity: input_number.irrigation_zone_3_duration_per_mm
              - entity: input_number.irrigation_zone_3_balance

      - title: "${ZONE4_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_boolean.irrigation_zone_4_enabled
              - entity: input_number.irrigation_zone_4_kc
              - entity: input_number.irrigation_zone_4_capacity
              - entity: input_number.irrigation_zone_4_trigger
              - entity: input_number.irrigation_zone_4_duration_per_mm
              - entity: input_number.irrigation_zone_4_balance
