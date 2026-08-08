create or replace function registry.remove_custom_item(p_item_id uuid)
returns boolean
language sql
security definer
set search_path = registry, pg_temp
as $$
    with removed as (
        update registry.items
        set is_enabled = false
        where id = p_item_id
          and category = 'Things we might have missed'
          and is_enabled
        returning id
    )
    select exists (select 1 from removed);
$$;

revoke all on function registry.remove_custom_item(uuid) from public;
grant execute on function registry.remove_custom_item(uuid) to registry_app;
