create or replace function registry.release_one_claim_for_item(p_item_id uuid)
returns boolean
language sql
security definer
set search_path = registry, pg_temp
as $$
    with target as (
        select c.id
        from registry.claims c
        where c.item_id = p_item_id
          and c.released_at is null
        order by c.created_at desc, c.id desc
        limit 1
        for update
    ),
    released as (
        update registry.claims c
        set released_at = now()
        where c.id = (select target.id from target)
        returning c.id
    )
    select exists (select 1 from released);
$$;

revoke all on function registry.release_one_claim_for_item(uuid) from public;
grant execute on function registry.release_one_claim_for_item(uuid) to registry_app;
