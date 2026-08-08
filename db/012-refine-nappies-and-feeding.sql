update registry.items
set
    title = 'Newborn nappies (1–3 packs)',
    description = 'Only one to three packs are needed. Please check the claim count before buying.',
    category = 'Everyday essentials',
    claim_mode = 'multiple',
    display_order = 400,
    is_enabled = true
where id = '33333333-3333-4333-8333-333333333333';

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
        '00000000-0000-4000-8000-000000000053',
        'Size 1 nappies',
        'Packs of size 1 nappies. More than one person can help.',
        'Everyday essentials',
        null,
        'multiple',
        405,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000054',
        'Microwave bottle sterilizer',
        'A microwave-safe sterilizer for bottles, teats, and feeding parts.',
        'Feeding',
        null,
        'single',
        275,
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
where id = '00000000-0000-4000-8000-000000000046';
