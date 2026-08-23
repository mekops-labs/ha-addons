# Changelog

## 0.9.1 (2026-08-23)

### Fixed

- The five device status entities (wapps running, RAM free, last seen,
  firmware version, firmware update) publish `entity_category: diagnostic`
  in the MQTT discovery config.

## 0.9.0 (2026-08-21)

### Added

- Fleet manifests (`internal/manifest`): a YAML/JSON document of deployments,
  each matched to devices by id or a label selector.
- `deputy apply -f=<manifest.yaml>` / `POST /api/v1/apply` compile and push
  each match's desired state, skipping a push that would change nothing.
- `--dry-run`/`?dry_run=1` reports the per-device diff without pushing;
  `--require-match`/`?require_match=1` fails a deployment matching no device.
- `apply --name=<name>` persists a manifest; it re-evaluates on every device
  registration and label change, so a governed device recovers on its own.
- `manifest list|show|delete [--prune]` and the matching REST routes.
- Device labels (`key=value`, grammar-checked, `internal/labels`):
  `PUT`/`GET /api/v1/devices/{id}/labels`, `GET /api/v1/labels`, a
  `?selector=k=v[,k2=v2]` filter on the device list, and matching CLI.
- Wapp catalogue (`internal/catalog`): `POST /api/v1/wapps` / `deputy wapp
  register` resolves an image once and pre-caches its layers.
- A push or manifest wapp entry may set `catalog: true` to reference a
  catalogued wapp instead of naming an image ref inline.
- `DELETE /api/v1/wapps/{name}/{version}` / `deputy wapp rm` refuses (409)
  while a device still desires the entry, naming them.
- Device enrolment: `POST`/`GET /api/v1/devices/enrol` issues a one-use
  `(device_id, join_token)` pair; `deputy device enrol`.
- Device decommission: `POST /api/v1/devices/{id}/decommission` pushes the
  signed wipe instruction; `deputy device decommission`.
- Web UI: a Manifests view, label editing and a selector filter on the
  device views, an Enrol view, a wapp catalogue view, and a device Remove
  section (decommission, then delete).
- `layercache.FS.Delete`, pinning sheriff-proto v0.13.0.

### Changed

- `DELETE /api/v1/devices/{id}` now revokes the device's secret, and warns
  in its response when the device was never decommissioned first.
- `push.Pusher.Push` split into `Compile` (resolve and validate) and
  `SetDesired`, so `apply` reuses the same compilation path as a push.

### Removed

- The `device revoke` CLI stub — no REST route or protocol message backed
  it.

## 0.8.0 (2026-08-18)

### Added

- The device twin carries the capacity a device settled on at boot, in the REST
  twin, the web UI and the retained MQTT state document.
- The deploy form checks a desired state against the target's reported limits
  and names the bound that blocks it.
- A device running reduced is marked in the web device list and in a STATE
  column of `deputy device list`.
- A wapps view at `#/wapps`, listing the wapp versions desired across the fleet
  and the devices desiring each.
- The web device page shows the engine's error-channel tail and the output of
  each wapp that has failed.
- `deputy device log <id>` prints the same two, sorted by wapp name. It
  replaces a stub; there is no follow.

### Changed

- `PUT /api/v1/devices/{id}/desired` returns 409 when the desired state exceeds
  what the target device reported it can hold.
- sheriff-proto v0.11.0

## 0.7.0 (2026-08-13)

### Added

- The twin carries the output of each wapp that has failed, published as
  `wapp_logs` in the retained MQTT state document.

### Changed

- sheriff-proto v0.10.0

## 0.6.0 (2026-08-10)

### Added

- `deputy device delete <id>` and `deputy server version`.
- The twin carries `registry_images` and `registry_image_slots`, published in
  the retained MQTT state document.
- The twin carries the device's engine-log tail as `engine_log`, sent only when
  the device reports a change.

### Changed

- `deputy` with no arguments prints the commands. Serving is `deputy server`.
- Requires sheriff-proto 0.9.0.

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
