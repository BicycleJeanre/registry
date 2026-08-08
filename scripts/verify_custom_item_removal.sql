begin;

do $$
declare
    v_item_id uuid;
begin
    select registry.add_custom_item('Synthetic removable item') into v_item_id;

    if not registry.remove_custom_item(v_item_id) then
        raise exception 'Expected the custom item to be removable';
    end if;

    if exists (
        select 1
        from registry.items i
        where i.id = v_item_id
          and i.is_enabled
    ) then
        raise exception 'Expected the removed custom item to be disabled';
    end if;

    if registry.remove_custom_item('00000000-0000-4000-8000-000000000012') then
        raise exception 'Expected a built-in item to be protected';
    end if;
end;
$$;

rollback;

\echo 'PASS: custom item hidden and built-in item protected'
