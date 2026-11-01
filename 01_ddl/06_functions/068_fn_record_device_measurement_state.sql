CREATE OR REPLACE FUNCTION device.fn_record_device_measurement_state(
    p_device_code VARCHAR(100),
    p_measurement_enabled BOOLEAN,
    p_event_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE (
    device_id UUID,
    measurement_enabled BOOLEAN,
    measurement_updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, device, public, pg_temp
AS $$
BEGIN
    IF p_device_code IS NULL OR btrim(p_device_code) = '' THEN
        RAISE EXCEPTION 'El codigo del dispositivo es obligatorio';
    END IF;

    IF p_measurement_enabled IS NULL THEN
        RAISE EXCEPTION 'El estado de medicion es obligatorio';
    END IF;

    RETURN QUERY
    UPDATE device.device AS d
       SET measurement_enabled = p_measurement_enabled,
           measurement_updated_at = COALESCE(p_event_at, now()),
           updated_at = now()
     WHERE d.code = btrim(p_device_code)
       AND (d.measurement_updated_at IS NULL
            OR COALESCE(p_event_at, now()) >= d.measurement_updated_at)
    RETURNING d.device_id, d.measurement_enabled, d.measurement_updated_at;
END;
$$;

REVOKE ALL ON FUNCTION device.fn_record_device_measurement_state(VARCHAR, BOOLEAN, TIMESTAMPTZ) FROM PUBLIC;
