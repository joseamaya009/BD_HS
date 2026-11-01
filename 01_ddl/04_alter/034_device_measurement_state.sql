-- Estado de medicion del dispositivo, consultado por la API y reportado por MQTT.
ALTER TABLE device.device
    ADD COLUMN IF NOT EXISTS measurement_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS measurement_updated_at TIMESTAMPTZ NULL;
