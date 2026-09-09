# Changelog

## 0.12.0 (2026-09-09)

### Build

- Tracks Deputy v0.12.0.

## 0.11.0 (2026-08-29)

### Build

- Tracks Deputy v0.11.0.

## 0.10.0 (2026-08-26)

### Added

- A wapp entry may set `preinstalled: true` where the device already holds the
  image; a layerless entry is refused without it.
- Device and wapp lifecycle controls, in the REST API, the CLI and the web UI:
  restart the device, reload the agent, and restart one wapp. Each queues a
  signed command the device runs on its next poll, and answers `202` with its
  sequence rather than reporting the act done. The device must run an agent
  that polls for commands; against an older one a command stays queued until
  it expires.
- `GET /api/v1/devices/{id}/commands` and `deputy device commands` show what is
  queued but not yet run, so a command to an offline device is visible.
- A queued command expires if the device does not poll within the command TTL,
  30 minutes by default.
- `stop` and `start` hold one wapp down and release it. They set the wapp's
  `stopped` desired-state flag rather than queueing a command, because an
  imperative stop would be undone by the device's next reconcile pass. A
  stopped wapp keeps its slot and its exit code, unlike a removed one.
- The device page carries the lifecycle controls, a pending-command table, and
  an "update agent" link that opens the deploy form on the supervisor entry.

### Changed

- Firmware is pushed by OCI ref: `device firmware push --image <host/name:tag>`
  and `{"firmware":{"image":"…"}}`.
- The tag names the version; the layer descriptor gives the digest and size.
  `--version`, `--digest`, `--source` and `--size` are gone, as are the
  matching fields of a `firmware` push body and a manifest `firmware:` block.
- A firmware image must be one uncompressed layer. A packaged layer and a ref
  pinned by digest alone are both refused with `400`.
- A manifest deployment may declare `wapps`, `firmware`, or both, and governs
  only the axes it declares. One declaring neither is refused.
- Desired state is derived from manifests: an imperative change is recorded as
  the device's own manifest, stored under the reserved name `device:<id>`.
- `device wapp create|remove`, over new per-wapp device routes, set or drop one
  wapp and leave the rest of a device's state alone.
- `apply --name` refuses the `device:` prefix, and a device's own manifest is
  left out of `manifest list`.
- The MQTT command topic goes through the same path as the REST routes, so it
  writes a device manifest and honours the governed-axis refusal.
- The web UI's deploy form sets one wapp instead of replacing a device's whole
  wapp set, and names what it leaves alone.
- `manifest show` prints the document as YAML, the form it is written and
  re-applied in; `--json` prints the stored record. The manifest route serves
  the same YAML under `?format=yaml`, and the web UI editor reads it.
- A wapp's policy (caps, drivers, sockets) and restart policy are shown on the
  device page, and `GET /api/v1/wapps` carries both.

### Removed

- `device desired-state push`. Its `--file` took a JSON document of a second
  shape, next to a manifest's; a manifest is now the one document format.
  Use `device wapp create` for one wapp and `apply -f` for a whole deployment.
- `wapp rm --from` no longer rewrites a device's whole desired state from the
  client; it drops the one wapp over the per-wapp route.

### Fixed

- A desired-state push onto an axis a registered manifest governs returns `409`
  naming that manifest, instead of being accepted and reverted moments later.
- Applying a firmware-only deployment leaves the device's wapps as they are.
- `GET /api/v1/devices/{id}` carries a `Governor` object when a manifest
  governs the device.
- A firmware version refusal ignores a leading `v` and a `-`/`+` suffix,
  matching the device's own comparison.

### Build

- Requires sheriff-proto v0.16.1, which publishes the command channel.

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
