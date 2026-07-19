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

# --- Auto-discover the Home Assistant MQTT broker (Discovery + commands) ---
if bashio::services.available 'mqtt'; then
    bashio::log.info "Home Assistant MQTT service discovered — enabling MQTT Discovery."
    export DEPUTY_MQTT_USERNAME="$(bashio::services mqtt 'username')"
    export DEPUTY_MQTT_PASSWORD="$(bashio::services mqtt 'password')"
    ARGS+=(--mqtt-broker "tcp://$(bashio::services mqtt 'host'):$(bashio::services mqtt 'port')")
else
    bashio::log.warning "No internal MQTT service found — MQTT Discovery disabled. Install the Mosquitto broker add-on to enable it."
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
