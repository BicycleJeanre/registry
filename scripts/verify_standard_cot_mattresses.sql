\set ON_ERROR_STOP on

do $$
declare
    v_count integer;
begin
    select count(*)
    into v_count
    from registry.items
    where (
        id = '00000000-0000-4000-8000-000000000007'
        and title = 'Standard cot mattress (approximately 118 × 56 cm)'
        and display_order = 410
    ) or (
        id = '00000000-0000-4000-8000-000000000093'
        and title = 'Standard camp-cot mattress (approximately 970 × 670 mm)'
        and display_order = 420
    );

    if v_count <> 2 then
        raise exception 'Standard cot mattress entries are incomplete';
    end if;

    select count(*)
    into v_count
    from registry.items
    where id in (
        '00000000-0000-4000-8000-000000000007',
        '00000000-0000-4000-8000-000000000093'
    )
      and category = 'Sleep'
      and claim_mode = 'single'
      and max_claims is null
      and is_enabled;

    if v_count <> 2 then
        raise exception 'Standard cot mattresses are not enabled single-claim Sleep items';
    end if;
end;
$$;

\echo PASS: standard cot mattresses are configured in the Sleep section
