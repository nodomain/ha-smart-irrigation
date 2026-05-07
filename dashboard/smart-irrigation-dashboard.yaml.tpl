###############################################################################
# Dashboard: Smart Irrigation
#
# Modern sections-based dashboard for the ET irrigation system.
#
# Views:
#   1. Overview — Status, zones, weather at a glance
#   2. Settings — All tunable parameters
###############################################################################
views:
  # ===========================================================================
  # VIEW 1: OVERVIEW
  # ===========================================================================
  - title: Irrigation
    path: overview
    icon: mdi:sprinkler-variant
    type: sections
    sections:
      # --- System Status ---
      - title: System Status
        cards:
          - type: tile
            entity: input_boolean.irrigation_enabled
            name: Master Enable
            color: green
            tap_action:
              action: toggle

          - type: tile
            entity: sensor.irrigation_today_et0
            name: "Today's ET₀"
            icon: mdi:weather-sunny-alert
            color: orange

          - type: tile
            entity: binary_sensor.irrigation_rain_skip_active
            name: Rain Skip
            color: blue

          - type: tile
            entity: sensor.irrigation_skip_reason
            name: Skip Reason
            icon: mdi:information-outline
            visibility:
              - condition: state
                entity: binary_sensor.irrigation_rain_skip_active
                state: "on"

          - type: tile
            entity: sensor.kachelmannwetter_niederschlag_vorhersage_heute
            name: Rain Forecast Today
            icon: mdi:weather-rainy
            color: blue

          - type: tile
            entity: binary_sensor.kachelmannwetter_frost_erwartet_heute_nacht
            name: Frost Tonight
            color: cyan

      # --- Zone 1: ${ZONE1_NAME} ---
      - title: "${ZONE1_NAME}"
        cards:
          - type: tile
            entity: input_boolean.irrigation_zone_1_enabled
            name: Enabled
            color: green
            tap_action:
              action: toggle

          - type: gauge
            entity: sensor.zone_1_balance_percent
            name: Soil Moisture
            needle: true
            min: 0
            max: 100
            severity:
              green: 60
              yellow: 30
              red: 0

          - type: tile
            entity: binary_sensor.zone_1_needs_water
            name: Needs Water
            color: red

          - type: tile
            entity: sensor.zone_1_recommended_duration
            name: Next Run
            icon: mdi:timer-sand

          - type: tile
            entity: sensor.zone_1_daily_et
            name: "Today's ET"
            icon: mdi:water-minus

          - type: tile
            entity: input_datetime.irrigation_zone_1_last_run
            name: Last Watered
            icon: mdi:history

          - type: button
            entity: script.irrigation_run_zone_1
            name: Run Now
            icon: mdi:play
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_1

      # --- Zone 2: ${ZONE2_NAME} ---
      - title: "${ZONE2_NAME}"
        cards:
          - type: tile
            entity: input_boolean.irrigation_zone_2_enabled
            name: Enabled
            color: green
            tap_action:
              action: toggle

          - type: gauge
            entity: sensor.zone_2_balance_percent
            name: Soil Moisture
            needle: true
            min: 0
            max: 100
            severity:
              green: 60
              yellow: 30
              red: 0

          - type: tile
            entity: binary_sensor.zone_2_needs_water
            name: Needs Water
            color: red

          - type: tile
            entity: sensor.zone_2_recommended_duration
            name: Next Run
            icon: mdi:timer-sand

          - type: tile
            entity: sensor.zone_2_daily_et
            name: "Today's ET"
            icon: mdi:water-minus

          - type: tile
            entity: input_datetime.irrigation_zone_2_last_run
            name: Last Watered
            icon: mdi:history

          - type: button
            entity: script.irrigation_run_zone_2
            name: Run Now
            icon: mdi:play
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_2

      # --- Zone 3: ${ZONE3_NAME} ---
      - title: "${ZONE3_NAME}"
        cards:
          - type: tile
            entity: input_boolean.irrigation_zone_3_enabled
            name: Enabled
            color: green
            tap_action:
              action: toggle

          - type: gauge
            entity: sensor.zone_3_balance_percent
            name: Soil Moisture
            needle: true
            min: 0
            max: 100
            severity:
              green: 60
              yellow: 30
              red: 0

          - type: tile
            entity: binary_sensor.zone_3_needs_water
            name: Needs Water
            color: red

          - type: tile
            entity: sensor.zone_3_recommended_duration
            name: Next Run
            icon: mdi:timer-sand

          - type: tile
            entity: sensor.zone_3_daily_et
            name: "Today's ET"
            icon: mdi:water-minus

          - type: tile
            entity: input_datetime.irrigation_zone_3_last_run
            name: Last Watered
            icon: mdi:history

          - type: button
            entity: script.irrigation_run_zone_3
            name: Run Now
            icon: mdi:play
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_3

      # --- Zone 4: ${ZONE4_NAME} ---
      - title: "${ZONE4_NAME}"
        cards:
          - type: tile
            entity: input_boolean.irrigation_zone_4_enabled
            name: Enabled
            color: green
            tap_action:
              action: toggle

          - type: gauge
            entity: sensor.zone_4_balance_percent
            name: Soil Moisture
            needle: true
            min: 0
            max: 100
            severity:
              green: 60
              yellow: 30
              red: 0

          - type: tile
            entity: binary_sensor.zone_4_needs_water
            name: Needs Water
            color: red

          - type: tile
            entity: sensor.zone_4_recommended_duration
            name: Next Run
            icon: mdi:timer-sand

          - type: tile
            entity: sensor.zone_4_daily_et
            name: "Today's ET"
            icon: mdi:water-minus

          - type: tile
            entity: input_datetime.irrigation_zone_4_last_run
            name: Last Watered
            icon: mdi:history

          - type: button
            entity: script.irrigation_run_zone_4
            name: Run Now
            icon: mdi:play
            tap_action:
              action: perform-action
              perform_action: script.irrigation_run_zone_4

      # --- Weather ---
      - title: Weather Data
        cards:
          - type: tile
            entity: sensor.aussentemperatur_gerundet
            name: Temperature
            color: orange

          - type: tile
            entity: sensor.kachelmannwetter_sonnenstunden_heute
            name: Sunshine Hours
            icon: mdi:weather-sunny
            color: amber

          - type: tile
            entity: sensor.kachelmannwetter_globalstrahlung_heute
            name: Solar Radiation
            icon: mdi:solar-power
            color: amber

          - type: tile
            entity: sensor.kachelmannwetter_niederschlag_1h
            name: Rain (last hour)
            icon: mdi:weather-rainy
            color: blue

          - type: tile
            entity: sensor.kachelmannwetter_niederschlag_vorhersage_heute
            name: Rain Forecast Today
            icon: mdi:weather-pouring
            color: blue

          - type: tile
            entity: sensor.kachelmannwetter_niederschlag_vorhersage_morgen
            name: Rain Forecast Tomorrow
            icon: mdi:weather-pouring
            color: indigo

          - type: tile
            entity: sensor.kachelmannwetter_regenwahrscheinlichkeit_heute
            name: Rain Probability
            icon: mdi:cloud-question
            color: blue

          - type: tile
            entity: sensor.kachelmannwetter_windboen_maximum_heute
            name: Wind Gusts
            icon: mdi:weather-windy
            color: teal

          - type: tile
            entity: sensor.kachelmannwetter_sonnenschein_relativ_heute
            name: Relative Sunshine
            icon: mdi:white-balance-sunny
            color: amber

      # --- History ---
      - title: Water Balance History
        cards:
          - type: history-graph
            title: Soil Moisture Balances (7 days)
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
            title: Daily ET₀ & Zone ET (7 days)
            hours_to_show: 168
            entities:
              - entity: sensor.irrigation_today_et0
                name: "Reference ET₀"
              - entity: sensor.zone_1_daily_et
                name: "${ZONE1_NAME} ET"
              - entity: sensor.zone_2_daily_et
                name: "${ZONE2_NAME} ET"
              - entity: sensor.zone_3_daily_et
                name: "${ZONE3_NAME} ET"
              - entity: sensor.zone_4_daily_et
                name: "${ZONE4_NAME} ET"

          - type: history-graph
            title: Rain & Skip Events (7 days)
            hours_to_show: 168
            entities:
              - entity: sensor.kachelmannwetter_niederschlag_1h
                name: "Rainfall (mm/h)"
              - entity: binary_sensor.irrigation_rain_skip_active
                name: "Rain Skip Active"
              - entity: sensor.kachelmannwetter_niederschlag_vorhersage_heute
                name: "Rain Forecast"

          - type: history-graph
            title: Weather Drivers (7 days)
            hours_to_show: 168
            entities:
              - entity: sensor.aussentemperatur_gerundet
                name: "Temperature °C"
              - entity: sensor.kachelmannwetter_sonnenstunden_heute
                name: "Sunshine Hours"
              - entity: sensor.kachelmannwetter_windboen_maximum_heute
                name: "Wind Gusts km/h"
              - entity: sensor.kachelmannwetter_globalstrahlung_heute
                name: "Solar Radiation W/m²"

          - type: history-graph
            title: Valve Activity (7 days)
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

      # --- Emergency ---
      - title: Quick Actions
        cards:
          - type: button
            entity: script.irrigation_stop_all
            name: "🛑 STOP ALL"
            icon: mdi:stop-circle
            icon_height: 40px
            tap_action:
              action: perform-action
              perform_action: script.irrigation_stop_all

  # ===========================================================================
  # VIEW 2: SETTINGS
  # ===========================================================================
  - title: Settings
    path: settings
    icon: mdi:cog
    type: sections
    sections:
      # --- Global Settings ---
      - title: Global Parameters
        cards:
          - type: entities
            title: Scheduling
            entities:
              - entity: input_number.irrigation_start_hour
              - entity: input_number.irrigation_max_duration
              - entity: input_number.irrigation_rain_skip_threshold

      # --- Zone 1 Settings ---
      - title: "Zone 1: ${ZONE1_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_zone_1_kc
              - entity: input_number.irrigation_zone_1_capacity
              - entity: input_number.irrigation_zone_1_trigger
              - entity: input_number.irrigation_zone_1_duration_per_mm
              - entity: input_number.irrigation_zone_1_balance

      # --- Zone 2 Settings ---
      - title: "Zone 2: ${ZONE2_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_zone_2_kc
              - entity: input_number.irrigation_zone_2_capacity
              - entity: input_number.irrigation_zone_2_trigger
              - entity: input_number.irrigation_zone_2_duration_per_mm
              - entity: input_number.irrigation_zone_2_balance

      # --- Zone 3 Settings ---
      - title: "Zone 3: ${ZONE3_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_zone_3_kc
              - entity: input_number.irrigation_zone_3_capacity
              - entity: input_number.irrigation_zone_3_trigger
              - entity: input_number.irrigation_zone_3_duration_per_mm
              - entity: input_number.irrigation_zone_3_balance

      # --- Zone 4 Settings ---
      - title: "Zone 4: ${ZONE4_NAME}"
        cards:
          - type: entities
            entities:
              - entity: input_number.irrigation_zone_4_kc
              - entity: input_number.irrigation_zone_4_capacity
              - entity: input_number.irrigation_zone_4_trigger
              - entity: input_number.irrigation_zone_4_duration_per_mm
              - entity: input_number.irrigation_zone_4_balance
