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
        '00000000-0000-4000-8000-000000000038',
        'Bath toys',
        'Easy-to-clean bath toys without hard-to-dry cavities.',
        'Parents irritation',
        null,
        'multiple',
        460,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000039',
        'Soft plushies',
        'Soft, washable plush toys suitable for a baby.',
        'Parents irritation',
        null,
        'multiple',
        470,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000040',
        'Plastic toys',
        'Sturdy, baby-safe plastic toys that are easy to wipe clean.',
        'Parents irritation',
        null,
        'multiple',
        480,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000041',
        'Educational toys',
        'Age-appropriate toys for early learning, matching, stacking, and discovery.',
        'Parents irritation',
        null,
        'multiple',
        490,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000042',
        'Rattles and sensory toys',
        'Baby-safe rattles and textured sensory toys for supervised play.',
        'Parents irritation',
        null,
        'multiple',
        500,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000043',
        'Teething toys',
        'Easy-to-clean teething toys made for young babies.',
        'Parents irritation',
        null,
        'multiple',
        510,
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
