begin;

do $$
declare
    v_item_id uuid;
begin
    select registry.add_custom_item('Synthetic custom item') into v_item_id;

    if v_item_id is null then
        raise exception 'Expected a valid custom item id';
    end if;

    if not exists (
        select 1
        from registry.items i
        where i.id = v_item_id
          and i.category = 'Things we might have missed'
          and i.claim_mode = 'single'
          and i.is_enabled
    ) then
        raise exception 'Custom item was not stored with the expected settings';
    end if;

    if registry.add_custom_item(' ') is not null then
        raise exception 'Expected a blank custom item to be rejected';
    end if;
end;
$$;

rollback;

\echo 'PASS: valid custom item stored and blank item rejected'
