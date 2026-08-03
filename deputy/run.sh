#!/usr/bin/with-contenv bashio

bashio::log.info "Starting Deputy Add-on..."

ARGS=(server --listen ":8080" --sheriff-listen ":8081" --db /data/deputy.db --layer-cache /data/layers)

# --- Signing key: configured seed, or generate once and persist in /data ---
# The Ed25519 pubkey derived from this seed is provisioned into every Sheriff
# device (identity/marshal_pubkeys.cbor); it must survive add-on restarts.
SEED_FILE=/data/signing.seed
if bashio::config.has_value 'signing_seed'; then
    SEED="$(bashio::config 'signing_seed')"
else
    if [ ! -f "${SEED_FILE}" ]; then
        bashio::log.warning "No signing seed configured — generating one into ${SEED_FILE}."
        head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > "${SEED_FILE}"
        chmod 600 "${SEED_FILE}"
    fi
    SEED="$(cat "${SEED_FILE}")"
fi
ARGS+=(--signing-seed "${SEED}")

# --- MQTT broker: an explicit mqtt_broker option overrides the internal
# Home Assistant MQTT service auto-discovery (e.g. a self-hosted EMQX) ---
if bashio::config.has_value 'mqtt_broker'; then
    bashio::log.info "Custom MQTT broker configured — enabling MQTT Discovery."
    ARGS+=(--mqtt-broker "$(bashio::config 'mqtt_broker')")
    if bashio::config.has_value 'mqtt_username'; then
        export DEPUTY_MQTT_USERNAME="$(bashio::config 'mqtt_username')"
    fi
    if bashio::config.has_value 'mqtt_password'; then
        export DEPUTY_MQTT_PASSWORD="$(bashio::config 'mqtt_password')"
    fi
elif bashio::services.available 'mqtt'; then
    bashio::log.info "Home Assistant MQTT service discovered — enabling MQTT Discovery."
    export DEPUTY_MQTT_USERNAME="$(bashio::services mqtt 'username')"
    export DEPUTY_MQTT_PASSWORD="$(bashio::services mqtt 'password')"
    ARGS+=(--mqtt-broker "tcp://$(bashio::services mqtt 'host'):$(bashio::services mqtt 'port')")
else
    bashio::log.warning "No internal MQTT service found — MQTT Discovery disabled. Install the Mosquitto broker add-on to enable it."
fi

if bashio::config.has_value 'mqtt_client_id'; then
    ARGS+=(--mqtt-client-id "$(bashio::config 'mqtt_client_id')")
fi
if bashio::config.has_value 'mqtt_ca_cert'; then
    CA_FILE=/data/mqtt-ca.pem
    bashio::config 'mqtt_ca_cert' > "${CA_FILE}"
    chmod 600 "${CA_FILE}"
    ARGS+=(--mqtt-ca-file "${CA_FILE}")
fi
if bashio::config.true 'mqtt_insecure'; then
    ARGS+=(--mqtt-insecure)
fi

# --- Options ---
ARGS+=(--sync-interval "$(bashio::config 'sync_interval_s')")
if bashio::config.true 'oci_insecure'; then
    ARGS+=(--oci-insecure)
fi
if bashio::config.has_value 'oci_username'; then
    export DEPUTY_OCI_USERNAME="$(bashio::config 'oci_username')"
fi
if bashio::config.has_value 'oci_password'; then
    export DEPUTY_OCI_PASSWORD="$(bashio::config 'oci_password')"
fi
if bashio::config.has_value 'oci_bearer'; then
    export DEPUTY_OCI_BEARER="$(bashio::config 'oci_bearer')"
fi

bashio::log.info "Launching Deputy (REST + UI on :8080, Sheriff device protocol on :8081)..."
exec /usr/bin/deputy "${ARGS[@]}"
