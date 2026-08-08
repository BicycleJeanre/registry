create or replace function registry.add_custom_item(p_title text)
returns uuid
language plpgsql
security definer
set search_path = registry, pg_temp
as $$
declare
    v_title text;
    v_item_id uuid;
begin
    v_title := btrim(regexp_replace(coalesce(p_title, ''), '\s+', ' ', 'g'));

    if length(v_title) not between 2 and 120 then
        return null;
    end if;

    insert into registry.items (
        title,
        description,
        category,
        purchase_url,
        claim_mode,
        display_order,
        is_enabled,
        max_claims
    )
    values (
        v_title,
        'Suggested by a registry visitor.',
        'Things we might have missed',
        null,
        'single',
        1000,
        true,
        null
    )
    returning id into v_item_id;

    return v_item_id;
end;
$$;

revoke all on function registry.add_custom_item(text) from public;
grant execute on function registry.add_custom_item(text) to registry_app;
