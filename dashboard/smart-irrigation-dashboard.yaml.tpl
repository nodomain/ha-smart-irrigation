###############################################################################
# Dashboard: Smart Irrigation
#
# Modern sections-based dashboard for the ET irrigation system.
# Redesigned for clarity: spacious layout, prominent gauges, battery status.
###############################################################################
views:
  - title: Irrigation
    path: overview
    icon: mdi:sprinkler-variant
    type: sections
    sections:
      - title: System
        cards:
          - type: tile
            entity: input_boolean.irrigation_enabled
            name: Master
            color: green
            tap_action:
              action: toggle
          - type: tile
            entity: sensor.irrigation_today_et0
            name: "ET₀ Today"
            icon: mdi:weather-sunny-alert
            color: orange
          - type: tile
            entity: binary_sensor.irrigation_rain_skip_active
            name: Rain Skip
            color: blue
          - type: tile
            entity: sensor.kachelmannwetter_niederschlag_vorhersage_heute
            name: Rain Today
            icon: mdi:weather-rainy
            color: blue
          - type: tile
            entity: binary_sensor.kachelmannwetter_frost_erwartet_heute_nacht
            name: Frost
            color: cyan
          - type: tile
            entity: sensor.diivoo_wt_13w_${ZONE1_DEVICE_ID}_batterie
            name: "Battery Terrasse"
            icon: mdi:battery
            color: green
          - type: tile
            entity: sensor.diivoo_wt_11w_1_${ZONE4_DEVICE_ID}_batterie
            name: "Battery Hochbeet"
            icon: mdi:battery
            color: green
          - type: button
            entity: script.irrigation_stop_all
            name: "STOP ALL"
            icon: mdi:stop-circle
            icon_height: 36px
            tap_action:
              action: perform-action
              perform_action: script.irrigation_stop_all

      - title: "${ZONE1_NAME}"
        cards:
          - type: gauge
            entity: sensor.zone_1_balance_percent
            name: Model Balance
            needle: true
            min: 0
            max: 100
            severity:
              green: 60
              yellow: 30
              red: 0
          - type: tile
            entity: ${ZONE1_SENSOR}
            name: "Sensor"
            icon: mdi:liquid-spot
            color: cyan
          - type: tile
            entity: input_boolean.irrigation_zone_1_enabled
            name: Enabled
            color: green
            tap_action:
              action: toggle
          - type: tile
            entity: binary_sensor.zone_1_needs_water
            name: Needs Water
            color: red
          - type: tile
            entity: sensor.zone_1_recommended_duration
            name: Next Run
            icon: mdi:timer-sand
            color: amber
          - type: tile
            entity: sensor.zone_1_daily_et
            name: "ET Today"
            icon: mdi:water-minus
            color: orange
          - type: tile
            entity: input_datetime.irrigation_zone_1_last_run
            name: Last Watered
            icon: mdi:history
          - type: button
            entity: script.irrigation_run_zone_1
            name: Run Now
            icon: mdi:play-circle
            icon_height: 30px
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_1

      - title: "${ZONE2_NAME}"
        cards:
          - type: gauge
            entity: sensor.zone_2_balance_percent
            name: Model Balance
            needle: true
            min: 0
            max: 100
            severity:
              green: 60
              yellow: 30
              red: 0
          - type: tile
            entity: ${ZONE2_SENSOR}
            name: "Sensor"
            icon: mdi:liquid-spot
            color: cyan
          - type: tile
            entity: input_boolean.irrigation_zone_2_enabled
            name: Enabled
            color: green
            tap_action:
              action: toggle
          - type: tile
            entity: binary_sensor.zone_2_needs_water
            name: Needs Water
            color: red
          - type: tile
            entity: sensor.zone_2_recommended_duration
            name: Next Run
            icon: mdi:timer-sand
            color: amber
          - type: tile
            entity: sensor.zone_2_daily_et
            name: "ET Today"
            icon: mdi:water-minus
            color: orange
          - type: tile
            entity: input_datetime.irrigation_zone_2_last_run
            name: Last Watered
            icon: mdi:history
          - type: button
            entity: script.irrigation_run_zone_2
            name: Run Now
            icon: mdi:play-circle
            icon_height: 30px
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_2

      - title: "${ZONE3_NAME}"
        cards:
          - type: gauge
            entity: sensor.zone_3_balance_percent
            name: Model Balance
            needle: true
            min: 0
            max: 100
            severity:
              green: 60
              yellow: 30
              red: 0
          - type: tile
            entity: ${ZONE3_SENSOR}
            name: "Sensor"
            icon: mdi:liquid-spot
            color: cyan
          - type: tile
            entity: input_boolean.irrigation_zone_3_enabled
            name: Enabled
            color: green
            tap_action:
              action: toggle
          - type: tile
            entity: binary_sensor.zone_3_needs_water
            name: Needs Water
            color: red
          - type: tile
            entity: sensor.zone_3_recommended_duration
            name: Next Run
            icon: mdi:timer-sand
            color: amber
          - type: tile
            entity: sensor.zone_3_daily_et
            name: "ET Today"
            icon: mdi:water-minus
            color: orange
          - type: tile
            entity: input_datetime.irrigation_zone_3_last_run
            name: Last Watered
            icon: mdi:history
          - type: button
            entity: script.irrigation_run_zone_3
            name: Run Now
            icon: mdi:play-circle
            icon_height: 30px
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_3

      - title: "${ZONE4_NAME}"
        cards:
          - type: gauge
            entity: sensor.zone_4_balance_percent
            name: Model Balance
            needle: true
            min: 0
            max: 100
            severity:
              green: 60
              yellow: 30
              red: 0
          - type: tile
            entity: ${ZONE4_SENSOR}
            name: "Sensor"
            icon: mdi:liquid-spot
            color: cyan
          - type: tile
            entity: input_boolean.irrigation_zone_4_enabled
            name: Enabled
            color: green
            tap_action:
              action: toggle
          - type: tile
            entity: binary_sensor.zone_4_needs_water
            name: Needs Water
            color: red
          - type: tile
            entity: sensor.zone_4_recommended_duration
            name: Next Run
            icon: mdi:timer-sand
            color: amber
          - type: tile
            entity: sensor.zone_4_daily_et
            name: "ET Today"
            icon: mdi:water-minus
            color: orange
          - type: tile
            entity: input_datetime.irrigation_zone_4_last_run
            name: Last Watered
            icon: mdi:history
          - type: button
            entity: script.irrigation_run_zone_4
            name: Run Now
            icon: mdi:play-circle
            icon_height: 30px
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_4

      - title: Weather
        cards:
          - type: tile
            entity: sensor.aussentemperatur_gerundet
            name: Temperature
            icon: mdi:thermometer
            color: orange
          - type: tile
            entity: sensor.kachelmannwetter_sonnenstunden_heute
            name: Sun Hours
            icon: mdi:weather-sunny
            color: amber
          - type: tile
            entity: sensor.kachelmannwetter_globalstrahlung_heute
            name: Radiation
            icon: mdi:solar-power
            color: amber
          - type: tile
            entity: sensor.kachelmannwetter_niederschlag_1h
            name: Rain (1h)
            icon: mdi:weather-rainy
            color: blue
          - type: tile
            entity: sensor.kachelmannwetter_niederschlag_vorhersage_morgen
            name: Rain Tomorrow
            icon: mdi:weather-pouring
            color: indigo
          - type: tile
            entity: sensor.kachelmannwetter_regenwahrscheinlichkeit_heute
            name: Rain Prob.
            icon: mdi:cloud-question-outline
            color: blue
          - type: tile
            entity: sensor.kachelmannwetter_windboen_maximum_heute
            name: Wind
            icon: mdi:weather-windy
            color: teal
          - type: tile
            entity: sensor.kachelmannwetter_sonnenschein_relativ_heute
            name: Rel. Sunshine
            icon: mdi:white-balance-sunny
            color: amber

      - title: History
        cards:
          - type: history-graph
            title: "Soil Moisture Sensors (7d)"
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
          - type: history-graph
            title: "Model Balance (7d)"
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
          - type: history-graph
            title: "ET₀ & Zone ET (7d)"
            hours_to_show: 168
            entities:
              - entity: sensor.irrigation_today_et0
                name: "Reference ET₀"
              - entity: sensor.zone_1_daily_et
                name: "${ZONE1_NAME}"
              - entity: sensor.zone_2_daily_et
                name: "${ZONE2_NAME}"
              - entity: sensor.zone_3_daily_et
                name: "${ZONE3_NAME}"
              - entity: sensor.zone_4_daily_et
                name: "${ZONE4_NAME}"
          - type: history-graph
            title: Rain & Skips (7d)
            hours_to_show: 168
            entities:
              - entity: sensor.kachelmannwetter_niederschlag_1h
                name: "Rain mm/h"
              - entity: binary_sensor.irrigation_rain_skip_active
                name: "Skip Active"
              - entity: sensor.kachelmannwetter_niederschlag_vorhersage_heute
                name: "Forecast"
          - type: history-graph
            title: Weather Drivers (7d)
            hours_to_show: 168
            entities:
              - entity: sensor.aussentemperatur_gerundet
                name: "Temp °C"
              - entity: sensor.kachelmannwetter_sonnenstunden_heute
                name: "Sun h"
              - entity: sensor.kachelmannwetter_windboen_maximum_heute
                name: "Wind km/h"
          - type: history-graph
            title: Valve Activity (7d)
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

  - title: Settings
    path: settings
    icon: mdi:cog
    type: sections
    sections:
      - title: Schedule & Limits
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_start_hour
              - entity: input_number.irrigation_evening_hour
              - entity: input_number.irrigation_evening_et_threshold
              - entity: input_number.irrigation_max_duration
              - entity: input_number.irrigation_rain_skip_threshold

      - title: Sensor Thresholds
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
              - entity: input_number.irrigation_zone_1_kc
              - entity: input_number.irrigation_zone_1_capacity
              - entity: input_number.irrigation_zone_1_trigger
              - entity: input_number.irrigation_zone_1_duration_per_mm
              - entity: input_number.irrigation_zone_1_balance

      - title: "${ZONE2_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_zone_2_kc
              - entity: input_number.irrigation_zone_2_capacity
              - entity: input_number.irrigation_zone_2_trigger
              - entity: input_number.irrigation_zone_2_duration_per_mm
              - entity: input_number.irrigation_zone_2_balance

      - title: "${ZONE3_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_zone_3_kc
              - entity: input_number.irrigation_zone_3_capacity
              - entity: input_number.irrigation_zone_3_trigger
              - entity: input_number.irrigation_zone_3_duration_per_mm
              - entity: input_number.irrigation_zone_3_balance

      - title: "${ZONE4_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_zone_4_kc
              - entity: input_number.irrigation_zone_4_capacity
              - entity: input_number.irrigation_zone_4_trigger
              - entity: input_number.irrigation_zone_4_duration_per_mm
              - entity: input_number.irrigation_zone_4_balance
