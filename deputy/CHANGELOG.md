# Changelog

## 0.4.0 (2026-08-09)

- tracks Deputy v0.4.0: REST API authentication and wapp configuration.
- `api_token` option guarding the REST API; generated into `/data/api.token`
  and logged when unset. The sidebar never needs it; a CLI or CI does.
- port `8080` is declared and left unmapped, so publishing the REST API is an
  opt-in in the Network panel.
- the build clones Deputy at the tag this add-on's version names, rather than
  whatever `main` held at build time.

## 0.3.0 (2026-08-03)

- expose MQTT broker settings (`mqtt_broker`, `mqtt_username`, `mqtt_password`,
  `mqtt_client_id`, `mqtt_ca_cert`, `mqtt_insecure`) for self-hosted brokers

## 0.2.0 (2026-08-03)

- first versioned release
