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
        '00000000-0000-4000-8000-000000000006',
        'Crib',
        'A safe crib with no gaps, sharp edges, loose hardware, or unsafe finishes.',
        'Sleep',
        null,
        'single',
        10,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000007',
        'Standard crib mattress',
        'A firm, flat mattress that fits the crib tightly with no gaps.',
        'Sleep',
        null,
        'single',
        20,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000008',
        'Waterproof mattress cover',
        'A flat, snug waterproof cover that fits underneath the fitted sheet.',
        'Sleep',
        null,
        'multiple',
        30,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000009',
        'Fitted crib sheets',
        'Snug fitted sheets made for the crib mattress. Two to four are useful.',
        'Sleep',
        null,
        'multiple',
        40,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000010',
        'Sleep sacks',
        'Wearable blankets for sleep instead of loose crib blankets.',
        'Sleep',
        null,
        'multiple',
        50,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000011',
        'Supervised-use blankets',
        'For awake cuddles, pram use, or floor time only—not for crib sleep.',
        'Sleep',
        null,
        'multiple',
        60,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000012',
        'Changing mat or station',
        'A safe, wipe-clean changing surface. A simple mat works well.',
        'Changing and travel',
        null,
        'single',
        100,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000013',
        'Rear-facing infant car seat',
        'A new or safety-checked, correctly installed, rear-facing car seat.',
        'Changing and travel',
        null,
        'single',
        110,
        true
    ),
    (
        '11111111-1111-4111-8111-111111111111',
        'Pram or stroller',
        'A newborn-safe pram with lie-flat, bassinet, or approved car-seat-compatible setup.',
        'Changing and travel',
        null,
        'single',
        120,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000014',
        'Nappy bag',
        'Any practical, organized bag for changes and outings.',
        'Changing and travel',
        null,
        'single',
        130,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000015',
        'Soft towels',
        'Three soft towels are useful; hoods are optional.',
        'Bath and care',
        null,
        'multiple',
        140,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000016',
        'Baby nail grooming kit',
        'A gentle nail file or newborn-safe grooming kit.',
        'Bath and care',
        null,
        'single',
        150,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000017',
        'Soft baby hair brush',
        'A soft brush for gentle scalp and hair care.',
        'Bath and care',
        null,
        'single',
        160,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000018',
        'Secure mosquito net',
        'Only if needed and able to stay secure, outside baby’s reach, without loose netting.',
        'Changing and travel',
        null,
        'multiple',
        170,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000019',
        'Nursing bras',
        'Comfortable nursing bras if breastfeeding.',
        'Feeding',
        null,
        'multiple',
        200,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000020',
        'Breast pads',
        'Disposable or washable breast pads if needed.',
        'Feeding',
        null,
        'multiple',
        210,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000021',
        'Nipple cream',
        'Baby-safe lanolin or another clinician-approved option.',
        'Feeding',
        null,
        'multiple',
        220,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000022',
        'Breast pump',
        'Useful if pumping; flange fit and easy cleaning matter.',
        'Feeding',
        null,
        'single',
        230,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000023',
        'Infant formula',
        'Commercial infant formula for formula, combination, or planned backup feeding.',
        'Feeding',
        null,
        'multiple',
        240,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000024',
        'Baby bottles',
        'Start with a small number until the baby’s bottle preference is clear.',
        'Feeding',
        null,
        'multiple',
        250,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000025',
        'Extra bottle teats',
        'Newborn or slow-flow teats that match the chosen bottle brand.',
        'Feeding',
        null,
        'multiple',
        260,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000026',
        'Bottle brush',
        'A dedicated brush used only for bottles and feeding equipment.',
        'Feeding',
        null,
        'single',
        270,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000027',
        'Dummies or pacifiers',
        'One-piece, age-appropriate dummies if the baby takes to them.',
        'Feeding',
        null,
        'multiple',
        280,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000028',
        'Bibs',
        'Useful for feeds, although burp cloths may be handier in the first month.',
        'Feeding',
        null,
        'multiple',
        290,
        true
    ),
    (
        '55555555-5555-4555-8555-555555555555',
        'Burp cloths or muslin cloths',
        'Soft cloths for feeds, spit-up, and everyday clean-up.',
        'Feeding',
        null,
        'multiple',
        300,
        true
    ),
    (
        '33333333-3333-4333-8333-333333333333',
        'Nappies',
        'Newborn or size-one nappies. Avoid overbuying one size; more than one person can help.',
        'Everyday essentials',
        null,
        'multiple',
        400,
        true
    ),
    (
        '44444444-4444-4444-8444-444444444444',
        'Baby wipes',
        'Fragrance-free or sensitive wipes. More than one person can help.',
        'Everyday essentials',
        null,
        'multiple',
        410,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000029',
        'Bum cream',
        'A simple barrier cream for redness and nappy changes.',
        'Everyday essentials',
        null,
        'multiple',
        420,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000030',
        'Fragrance-free detergent',
        'A gentle fragrance-free laundry detergent; special baby branding is optional.',
        'Everyday essentials',
        null,
        'multiple',
        430,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000031',
        'Mild baby wash',
        'A mild fragrance-free wash to use sparingly when plain water is not enough.',
        'Bath and care',
        null,
        'multiple',
        440,
        true
    ),
    (
        '00000000-0000-4000-8000-000000000032',
        'Digital thermometer',
        'A reliable digital thermometer for checking baby’s temperature.',
        'Health and care',
        null,
        'single',
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
