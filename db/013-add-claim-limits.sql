alter table registry.items
add column if not exists max_claims integer
    check (max_claims is null or max_claims > 0);

update registry.items
set max_claims = 3
where id = '33333333-3333-4333-8333-333333333333';

create or replace view registry.public_items as
select
    i.id,
    i.title,
    i.description,
    i.category,
    i.purchase_url,
    i.claim_mode,
    i.display_order,
    count(c.id)::integer as claim_count,
    (
        case
            when i.max_claims is not null
                then count(c.id) < i.max_claims
            when i.claim_mode = 'multiple'
                then true
            else count(c.id) = 0
        end
    ) as is_available,
    i.max_claims
from registry.items i
left join registry.claims c
    on c.item_id = i.id
    and c.released_at is null
where i.is_enabled
group by i.id;

create or replace function registry.create_claim(
    p_item_id uuid,
    p_undo_token_hash text
)
returns table (result text)
language plpgsql
security definer
set search_path = registry, pg_temp
as $$
declare
    v_claim_mode registry.claim_mode;
    v_max_claims integer;
    v_active_claims integer;
begin
    select i.claim_mode, i.max_claims
    into v_claim_mode, v_max_claims
    from registry.items i
    where i.id = p_item_id
      and i.is_enabled
    for update;

    if not found then
        return query select 'not_found'::text;
        return;
    end if;

    select count(*)::integer
    into v_active_claims
    from registry.claims c
    where c.item_id = p_item_id
      and c.released_at is null;

    if v_claim_mode = 'single' and v_active_claims > 0 then
        return query select 'already_claimed'::text;
        return;
    end if;

    if v_max_claims is not null and v_active_claims >= v_max_claims then
        return query select 'claim_limit_reached'::text;
        return;
    end if;

    insert into registry.claims (item_id, undo_token_hash)
    values (p_item_id, p_undo_token_hash);

    return query select 'claimed'::text;
end;
$$;

revoke all on function registry.create_claim(uuid, text) from public;
grant execute on function registry.create_claim(uuid, text) to registry_app;
