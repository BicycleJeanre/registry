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
values
    (
        '00000000-0000-4000-8000-000000000032',
        'Newborn clothing',
        'Newborn-size vests, babygrows, leggings, cardigans, or similar basics.',
        'Clothing',
        null,
        'multiple',
        400,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000033',
        'Clothing (0–3 months)',
        'Everyday clothing and sleepwear in 0–3 month sizes.',
        'Clothing',
        null,
        'multiple',
        410,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000034',
        'Clothing (3–6 months)',
        'Everyday clothing and sleepwear in 3–6 month sizes.',
        'Clothing',
        null,
        'multiple',
        420,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000035',
        'Clothing (6–12 months)',
        'Everyday clothing and sleepwear in 6–12 month sizes.',
        'Clothing',
        null,
        'multiple',
        430,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000036',
        'Baby socks',
        'Soft baby socks in a mix of early sizes.',
        'Clothing',
        null,
        'multiple',
        440,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000037',
        'Soft-soled baby shoes',
        'Comfortable, non-restrictive soft-soled shoes for when they are useful.',
        'Clothing',
        null,
        'multiple',
        450,
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
