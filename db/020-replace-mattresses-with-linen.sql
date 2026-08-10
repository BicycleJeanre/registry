-- The cot mattresses are already owned. Keep only size-specific waterproof
-- covers and fitted sheets in the Sleep section.

update registry.items
set is_enabled = false
where id in (
    '00000000-0000-4000-8000-000000000007',
    '00000000-0000-4000-8000-000000000093'
);

update registry.items
set
    title = 'Waterproof cover for standard cot mattress (approximately 118 × 56 cm)',
    description = 'A snug waterproof cover for the common standard cot mattress size. Please confirm the exact mattress dimensions before buying.',
    category = 'Sleep',
    purchase_url = null,
    claim_mode = 'multiple',
    display_order = 401,
    is_enabled = true,
    max_claims = null
where id = '00000000-0000-4000-8000-000000000008';

update registry.items
set
    title = 'Fitted sheets for standard cot mattress (approximately 118 × 56 cm)',
    description = 'Snug fitted sheets for the common standard cot mattress size. Please confirm the exact mattress dimensions before buying.',
    category = 'Sleep',
    purchase_url = null,
    claim_mode = 'multiple',
    display_order = 402,
    is_enabled = true,
    max_claims = null
where id = '00000000-0000-4000-8000-000000000009';

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
values
    (
        '00000000-0000-4000-8000-000000000094',
        'Waterproof cover for standard camp-cot mattress (approximately 970 × 670 mm)',
        'A snug waterproof cover for the standard camp-cot mattress size. Please confirm the exact mattress dimensions before buying.',
        'Sleep', null, 'multiple', 403, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000095',
        'Fitted sheets for standard camp-cot mattress (approximately 970 × 670 mm)',
        'Snug fitted sheets for the standard camp-cot mattress size. Please confirm the exact mattress dimensions before buying.',
        'Sleep', null, 'multiple', 404, true, null
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
