update registry.items
set
    title = 'Extra slow-flow newborn bottle teats',
    description = 'Extra newborn slow-flow teats that match the chosen bottle brand.'
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
values
    (
        '00000000-0000-4000-8000-000000000044',
        'Swaddles',
        'Lightweight, breathable swaddles suitable for a newborn.',
        'Sleep',
        null,
        'multiple',
        55,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000045',
        'Baby beanies',
        'Soft baby beanies in early sizes for cool outings.',
        'Clothing',
        null,
        'multiple',
        445,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000046',
        'Bottle drying rack',
        'A compact drying rack for bottles, teats, and feeding parts.',
        'Feeding',
        null,
        'single',
        275,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000047',
        'Baby moisturizer (body cream)',
        'A gentle fragrance-free moisturizer or body cream for baby skin.',
        'Bath and care',
        null,
        'multiple',
        330,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000048',
        'Nasal aspirator',
        'A simple baby-safe nasal aspirator that is easy to clean.',
        'Health and care',
        null,
        'single',
        340,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000049',
        'Baby washcloths',
        'Soft washcloths for bath time and gentle clean-ups.',
        'Bath and care',
        null,
        'multiple',
        350,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000050',
        'Activity playmat',
        'A padded activity mat for supervised floor play and tummy time.',
        'Parents irritation',
        null,
        'single',
        520,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000051',
        'Nightlight',
        'A dim, warm nightlight for feeds and changes without bright overhead light.',
        'Sleep',
        null,
        'single',
        70,
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
