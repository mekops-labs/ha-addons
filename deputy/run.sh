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

# --- API token: configured, or generate once and persist in /data ---
# Deputy refuses to serve its API on a published address without one, and the
# add-on must publish :8080 for ingress to reach it. The sidebar never needs
# the token (the Supervisor authenticates the user); a CLI or CI does.
TOKEN_FILE=/data/api.token
if bashio::config.has_value 'api_token'; then
    export DEPUTY_TOKEN="$(bashio::config 'api_token')"
else
    if [ ! -f "${TOKEN_FILE}" ]; then
        bashio::log.warning "No api_token configured — generating one into ${TOKEN_FILE}."
        head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > "${TOKEN_FILE}"
        chmod 600 "${TOKEN_FILE}"
    fi
    export DEPUTY_TOKEN="$(cat "${TOKEN_FILE}")"
    bashio::log.info "API token: ${DEPUTY_TOKEN} — needed only to reach the API from outside the sidebar."
fi

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
if bashio::config.has_value 'manager_address'; then
    ARGS+=(--manager-address "$(bashio::config 'manager_address')")
fi
if bashio::config.has_value 'registry_address'; then
    ARGS+=(--registry-address "$(bashio::config 'registry_address')")
fi

bashio::log.info "Launching Deputy (REST + UI on :8080, Sheriff device protocol on :8081)..."
exec /usr/bin/deputy "${ARGS[@]}"
