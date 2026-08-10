\set ON_ERROR_STOP on

do $$
declare
    v_enabled_count integer;
begin
    select count(*)
    into v_enabled_count
    from registry.items
    where id in (
        '00000000-0000-4000-8000-000000000078',
        '00000000-0000-4000-8000-000000000079',
        '00000000-0000-4000-8000-000000000080',
        '00000000-0000-4000-8000-000000000081',
        '00000000-0000-4000-8000-000000000084'
    )
      and is_enabled;

    if v_enabled_count <> 0 then
        raise exception 'One or more removed For Mom items remain enabled';
    end if;
end;
$$;

\echo PASS: requested For Mom items are disabled
