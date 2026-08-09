# Deputy — Home Assistant Add-on

**Deputy** is the standalone control plane of the WANTED ecosystem: it manages
Sheriff edge devices (desired-state reconciliation, signed deployments, layer
delivery) and integrates them into Home Assistant via MQTT Discovery.

## What it does

- **Sheriff device protocol** (port `8081`, direct-CBOR framing) — devices on
  your LAN reconcile against this add-on; the REST API for tooling is on port
  `8080`.
- **Web UI in the sidebar** (ingress) — device list, observed-vs-desired state,
  wapp deployment with OCI image resolution.
- **MQTT Discovery** — every managed device appears as an HA device with
  sensors (wapps running, RAM free, last seen); HA automations can push
  deployments via the `deputy/devices/<id>/set` command topic. Credentials for
  the MQTT broker add-on are injected automatically.
- **Persistent state in `/data`** — twin database (SQLite), layer cache, the
  Ed25519 signing seed, and the API token.

## Reaching the API from outside the sidebar

The sidebar needs no credential: the Supervisor authenticates you and Deputy
honours that. Everything else does.

Port `8080` is **declared but unmapped**. Map it in the add-on's Network panel
to drive this Deputy from a workstation CLI or a CI job — that publishes the
whole control plane, so it is deliberately a decision you make rather than a
default.

The token comes from the `api_token` option, or is generated once into
`/data/api.token` and logged at startup. Set your own with any 32+ character
secret:

```sh
head -c 32 /dev/urandom | base32   # paste the result into the api_token option
```

Use it as:

```sh
export DEPUTY_SERVER=http://homeassistant.local:8080
export DEPUTY_TOKEN=<the token from the add-on log>
deputy device list
```

## Provisioning devices

The add-on logs its signing public key at startup:

```
signing key — provision this into Sheriff identity/marshal_pubkeys.cbor ...
```

Provision that key into each Sheriff device's identity store. The seed is
generated once and persisted (or set `signing_seed` explicitly); the derived
public key must stay stable or provisioned devices reject every desired state.

## Options

| Option                                         | Default       | Description
|------------------------------------------------|---------------|----------------------
| `api_token`                                    | *(generated)* | Bearer token for the REST API; generated into `/data/api.token` and logged when unset
| `sync_interval_s`                              | `60`          | Device reconciliation cadence pushed in desired state
| `oci_insecure`                                 | `false`       | Allow plain-HTTP OCI registries
| `signing_seed`                                 | *(generated)* | Hex Ed25519 seed (64 chars)
| `oci_username` / `oci_password` / `oci_bearer` | —             | OCI registry credentials
| `mqtt_broker`                                  | —             | Self-hosted MQTT broker URL (e.g. `tcp://host:1883`), overriding the internal Home Assistant MQTT service
| `mqtt_username` / `mqtt_password`              | —             | Credentials for `mqtt_broker` (the internal service's credentials are injected automatically instead)
| `mqtt_client_id`                                | `deputy`      | MQTT client id — give each Deputy its own when several share a broker
| `mqtt_ca_cert`                                  | —             | PEM bundle verifying the broker certificate, for a broker behind a private CA
| `mqtt_insecure`                                 | `false`       | Accept any broker certificate (lab use only)
