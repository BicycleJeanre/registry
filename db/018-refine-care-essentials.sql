update registry.items
set
    claim_mode = 'multiple',
    max_claims = 6
where id in (
    '00000000-0000-4000-8000-000000000086',
    '00000000-0000-4000-8000-000000000087',
    '00000000-0000-4000-8000-000000000088'
);

update registry.items
set
    claim_mode = 'single',
    max_claims = null,
    description = 'One gentle, baby-safe oil for skin care or massage.'
where id = '00000000-0000-4000-8000-000000000058';

update registry.items
set
    title = 'Non-fragranced baby wipes (pure water preferred)',
    description = 'Non-fragranced baby wipes, preferably made with pure water.'
where id = '44444444-4444-4444-8444-444444444444';

update registry.items
set
    title = 'Aqueous cream for baby (non-scented)',
    description = 'A gentle, non-scented aqueous cream for baby skin.'
where id = '00000000-0000-4000-8000-000000000047';

insert into registry.items (
    id,
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
    '00000000-0000-4000-8000-000000000092',
    'Baby wipe dispenser',
    'A practical baby wipe dispenser. Up to three are welcome.',
    'Care and bath',
    null,
    'multiple',
    203,
    true,
    3
)
on conflict (id) do update
set
    title = excluded.title,
    description = excluded.description,
    category = excluded.category,
    purchase_url = excluded.purchase_url,
    claim_mode = excluded.claim_mode,
    display_order = excluded.display_order,
    is_enabled = excluded.is_enabled,
    max_claims = excluded.max_claims;
