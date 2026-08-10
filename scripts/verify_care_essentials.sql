\set ON_ERROR_STOP on

do $$
declare
    v_count integer;
begin
    select count(*)
    into v_count
    from registry.items
    where id in (
        '00000000-0000-4000-8000-000000000086',
        '00000000-0000-4000-8000-000000000087',
        '00000000-0000-4000-8000-000000000088'
    )
      and claim_mode = 'multiple'
      and max_claims = 6
      and is_enabled;

    if v_count <> 3 then
        raise exception 'One or more nappy limits are not six';
    end if;

    select count(*)
    into v_count
    from registry.items
    where id = '00000000-0000-4000-8000-000000000058'
      and claim_mode = 'single'
      and max_claims is null
      and is_enabled;

    if v_count <> 1 then
        raise exception 'Baby oil is not configured as a single-claim item';
    end if;

    select count(*)
    into v_count
    from registry.items
    where (
        id = '44444444-4444-4444-8444-444444444444'
        and title = 'Non-fragranced baby wipes (pure water preferred)'
    ) or (
        id = '00000000-0000-4000-8000-000000000047'
        and title = 'Aqueous cream for baby (non-scented)'
    );

    if v_count <> 2 then
        raise exception 'Care item names are incomplete';
    end if;

    select count(*)
    into v_count
    from registry.items
    where id = '00000000-0000-4000-8000-000000000092'
      and title = 'Baby wipe dispenser'
      and category = 'Care and bath'
      and claim_mode = 'multiple'
      and max_claims = 3
      and is_enabled;

    if v_count <> 1 then
        raise exception 'Baby wipe dispenser configuration is incomplete';
    end if;
end;
$$;

\echo PASS: care essentials and claim limits are configured
