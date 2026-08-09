# Changelog

## Unreleased

- `api_token` option guarding Deputy's REST API; generated into `/data/api.token` and logged when unset. The sidebar
  never needs it — the Supervisor authenticates the user — and a CLI or CI pushing to a mapped `8080` does.
- port `8080` is now declared and left unmapped, so publishing the REST API is an opt-in in the Network panel.
  `ports_description` previously documented a port `ports:` did not map.

## 0.3.0 (2026-08-03)

- expose new MQTT broker settings (`mqtt_broker`, `mqtt_username`, `mqtt_password`, `mqtt_client_id`, `mqtt_ca_cert`, `mqtt_insecure`) for self-hosted brokers

## 0.2.0 (2026-08-03)

- first versioned release
