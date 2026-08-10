\set ON_ERROR_STOP on

do $$
declare
    v_count integer;
begin
    select count(*)
    into v_count
    from registry.items
    where id in (
        '00000000-0000-4000-8000-000000000007',
        '00000000-0000-4000-8000-000000000093'
    )
      and not is_enabled;

    if v_count <> 2 then
        raise exception 'Cot mattress entries are still enabled';
    end if;

    select count(*)
    into v_count
    from registry.items
    where (
        id = '00000000-0000-4000-8000-000000000008'
        and title = 'Waterproof cover for standard cot mattress (approximately 118 × 56 cm)'
        and display_order = 401
    ) or (
        id = '00000000-0000-4000-8000-000000000009'
        and title = 'Fitted sheets for standard cot mattress (approximately 118 × 56 cm)'
        and display_order = 402
    ) or (
        id = '00000000-0000-4000-8000-000000000094'
        and title = 'Waterproof cover for standard camp-cot mattress (approximately 970 × 670 mm)'
        and display_order = 403
    ) or (
        id = '00000000-0000-4000-8000-000000000095'
        and title = 'Fitted sheets for standard camp-cot mattress (approximately 970 × 670 mm)'
        and display_order = 404
    );

    if v_count <> 4 then
        raise exception 'Cot linen entries are incomplete';
    end if;

    select count(*)
    into v_count
    from registry.items
    where id in (
        '00000000-0000-4000-8000-000000000008',
        '00000000-0000-4000-8000-000000000009',
        '00000000-0000-4000-8000-000000000094',
        '00000000-0000-4000-8000-000000000095'
    )
      and category = 'Sleep'
      and claim_mode = 'multiple'
      and max_claims is null
      and is_enabled;

    if v_count <> 4 then
        raise exception 'Cot linen items are not enabled multiple-claim Sleep items';
    end if;
end;
$$;

\echo PASS: cot mattress entries are hidden and cot linen is configured
