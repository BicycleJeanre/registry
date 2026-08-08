update registry.items
set
    title = 'Extra bottle teats',
    description = 'Extra bottle teats that match the chosen bottle brand.'
where id = '00000000-0000-4000-8000-000000000025';

insert into registry.items (
    id,
    title,
    description,
    category,
    purchase_url,
    claim_mode,
    display_order,
    is_enabled
)
values (
    '00000000-0000-4000-8000-000000000052',
    'Extra slow-flow newborn bottle teats',
    'Extra newborn slow-flow teats that match the chosen bottle brand.',
    'Feeding',
    null,
    'multiple',
    265,
    true
)
on conflict (id) do update
set
    title = excluded.title,
    description = excluded.description,
    category = excluded.category,
    purchase_url = excluded.purchase_url,
    claim_mode = excluded.claim_mode,
    display_order = excluded.display_order,
    is_enabled = excluded.is_enabled;

update registry.items
set is_enabled = false
where id = '00000000-0000-4000-8000-000000000023';

update registry.items
set
    title = 'Waterproof cover for standard crib mattress',
    description = 'A flat, snug waterproof cover made for a standard crib mattress.'
where id = '00000000-0000-4000-8000-000000000008';

update registry.items
set
    title = 'Fitted sheets for standard crib mattress',
    description = 'Snug fitted sheets made for a standard crib mattress. Two to four are useful.'
where id = '00000000-0000-4000-8000-000000000009';
