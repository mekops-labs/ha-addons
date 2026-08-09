# Changelog

## 0.5.0 (2026-08-09)

- A layer past 24 KiB is delivered as frames following its delivery message.
  A device with no registry socket can receive a layer of any size.
- A device id must be `[A-Za-z0-9_-]` and at most 64 bytes, refused at the
  device port and on every push. One under another id stops reporting.

## 0.4.1 (2026-08-09)

- bumped sheriff-proro to v0.5.1

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
