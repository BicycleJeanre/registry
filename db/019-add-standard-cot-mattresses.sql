-- Add the two standard-size mattresses requested for the Sleep section.

update registry.items
set
    title = 'Standard cot mattress (approximately 118 × 56 cm)',
    description = 'A firm, flat mattress in the common standard cot size. Please confirm the cot’s exact internal dimensions before buying.',
    category = 'Sleep',
    purchase_url = null,
    claim_mode = 'single',
    display_order = 410,
    is_enabled = true,
    max_claims = null
where id = '00000000-0000-4000-8000-000000000007';

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
    '00000000-0000-4000-8000-000000000093',
    'Standard camp-cot mattress (approximately 970 × 670 mm)',
    'A firm, flat mattress made for a standard camp cot. Please confirm that the mattress is approved for the exact camp-cot model before buying.',
    'Sleep',
    null,
    'single',
    420,
    true,
    null
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
