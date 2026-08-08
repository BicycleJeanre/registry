create extension if not exists pgcrypto;

create schema if not exists registry;

create role registry_app login password 'registry-app-local-only';

create type registry.claim_mode as enum ('single', 'multiple');

create table registry.items (
    id uuid primary key default gen_random_uuid(),
    title text not null check (length(title) between 1 and 120),
    description text not null default '',
    category text not null default 'Other',
    purchase_url text,
    claim_mode registry.claim_mode not null default 'single',
    display_order integer not null default 100,
    is_enabled boolean not null default true,
    created_at timestamptz not null default now(),
    check (purchase_url is null or purchase_url ~ '^https://')
);

create table registry.claims (
    id bigint generated always as identity primary key,
    item_id uuid not null references registry.items(id),
    undo_token_hash character(64) not null unique
        check (undo_token_hash ~ '^[0-9a-f]{64}$'),
    created_at timestamptz not null default now(),
    released_at timestamptz
);

create index claims_active_item_idx
    on registry.claims (item_id)
    where released_at is null;

create view registry.public_items as
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
        i.claim_mode = 'multiple'
        or count(c.id) = 0
    ) as is_available
from registry.items i
left join registry.claims c
    on c.item_id = i.id
    and c.released_at is null
where i.is_enabled
group by i.id;

create function registry.create_claim(
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
begin
    select i.claim_mode
    into v_claim_mode
    from registry.items i
    where i.id = p_item_id
      and i.is_enabled
    for update;

    if not found then
        return query select 'not_found'::text;
        return;
    end if;

    if v_claim_mode = 'single'
       and exists (
           select 1
           from registry.claims c
           where c.item_id = p_item_id
             and c.released_at is null
       ) then
        return query select 'already_claimed'::text;
        return;
    end if;

    insert into registry.claims (item_id, undo_token_hash)
    values (p_item_id, p_undo_token_hash);

    return query select 'claimed'::text;
end;
$$;

create function registry.release_claim(p_undo_token_hash text)
returns boolean
language sql
security definer
set search_path = registry, pg_temp
as $$
    with released as (
        update registry.claims
        set released_at = now()
        where undo_token_hash = p_undo_token_hash
          and released_at is null
        returning id
    )
    select exists (select 1 from released);
$$;

revoke all on schema registry from public;
revoke all on all tables in schema registry from public;
revoke all on all functions in schema registry from public;

grant usage on schema registry to registry_app;
grant select on registry.public_items to registry_app;
grant execute on function registry.create_claim(uuid, text) to registry_app;
grant execute on function registry.release_claim(text) to registry_app;

insert into registry.items (
    id,
    title,
    description,
    category,
    purchase_url,
    claim_mode,
    display_order
)
values
    (
        '11111111-1111-4111-8111-111111111111',
        'Pram',
        'A safe, everyday pram for walks and errands.',
        'Getting around',
        null,
        'single',
        10
    ),
    (
        '22222222-2222-4222-8222-222222222222',
        'Baby monitor',
        'A simple audio or video monitor.',
        'Nursery',
        null,
        'single',
        20
    ),
    (
        '33333333-3333-4333-8333-333333333333',
        'Nappies',
        'Any newborn or size-one nappies are useful. More than one person can help.',
        'Everyday essentials',
        null,
        'multiple',
        30
    ),
    (
        '44444444-4444-4444-8444-444444444444',
        'Baby wipes',
        'Fragrance-free wipes. More than one person can help.',
        'Everyday essentials',
        null,
        'multiple',
        40
    ),
    (
        '55555555-5555-4555-8555-555555555555',
        'Muslin cloths',
        'Soft cloths for feeding and everyday clean-up.',
        'Everyday essentials',
        null,
        'multiple',
        50
    );
