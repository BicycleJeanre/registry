-- Merge and translate the two Afrikaans baby wish lists into the registry.
-- Earlier, explicit exclusions remain excluded: newborn nappies, the breast
-- pump, infant formula, the car seat, and the pram/stroller.

update registry.items
set
    title = 'Baby blankets (for supervised use)',
    description = 'Soft blankets for cuddles, floor time, or outings; not for unattended cot sleep.',
    category = 'Sleep',
    display_order = 440
where id = '00000000-0000-4000-8000-000000000011';

update registry.items
set category = 'Out and about', display_order = 510
where id = '00000000-0000-4000-8000-000000000012';

update registry.items
set category = 'Out and about', display_order = 500
where id = '00000000-0000-4000-8000-000000000014';

update registry.items
set category = 'Out and about', display_order = 520
where id = '00000000-0000-4000-8000-000000000018';

update registry.items
set category = 'For Mom', display_order = 710
where id in (
    '00000000-0000-4000-8000-000000000019',
    '00000000-0000-4000-8000-000000000021'
);

update registry.items
set category = 'Care and bath', display_order = 220
where id = '00000000-0000-4000-8000-000000000029';

update registry.items
set category = 'Care and bath', display_order = 230
where id = '00000000-0000-4000-8000-000000000030';

update registry.items
set category = 'Care and bath'
where id in (
    '44444444-4444-4444-8444-444444444444',
    '00000000-0000-4000-8000-000000000031',
    '00000000-0000-4000-8000-000000000047',
    '00000000-0000-4000-8000-000000000048',
    '00000000-0000-4000-8000-000000000049'
);

update registry.items
set
    title = 'Baby comb and brush set',
    description = 'A soft baby brush and gentle comb for scalp and hair care.',
    category = 'Care and bath',
    display_order = 290
where id = '00000000-0000-4000-8000-000000000017';

update registry.items
set
    title = '0–3 month summer clothes',
    description = 'Light everyday clothing and sleepwear in 0–3 month sizes.',
    display_order = 310
where id = '00000000-0000-4000-8000-000000000033';

update registry.items
set
    title = '3–6 month autumn clothes',
    description = 'Layerable everyday clothing and sleepwear in 3–6 month sizes.',
    display_order = 320
where id = '00000000-0000-4000-8000-000000000034';

update registry.items
set
    title = '6–12 month winter and spring clothes',
    description = 'Warm and layerable clothing in 6–12 month sizes for winter and spring.',
    display_order = 330
where id = '00000000-0000-4000-8000-000000000035';

update registry.items
set category = 'Play and other'
where category = 'Parents irritation';

-- Both supplied lists specifically ask for sizes 2, 3, and 4 and exclude
-- newborn nappies. Size 1 remains excluded as well.
update registry.items
set is_enabled = false
where id in (
    '33333333-3333-4333-8333-333333333333',
    '00000000-0000-4000-8000-000000000053'
);

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
        '00000000-0000-4000-8000-000000000055',
        'Breastfeeding cover',
        'A light, breathable cover for feeding when wanted.',
        'Feeding', null, 'single', 100, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000056',
        'Milk collectors',
        'Comfortable milk collectors or catchers for breastfeeding.',
        'Feeding', null, 'multiple', 110, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000057',
        'Breast milk freezer bags',
        'Leak-resistant bags made for freezing and labelling expressed milk.',
        'Feeding', null, 'multiple', 120, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000083',
        'Nursing pillow',
        'A supportive feeding pillow with a washable cover.',
        'Feeding', null, 'single', 130, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000086',
        'Size 2 nappies (approximately 3–8 kg)',
        'Please check the brand sizing. Up to three claims are welcome.',
        'Care and bath', null, 'multiple', 200, true, 3
    ),
    (
        '00000000-0000-4000-8000-000000000087',
        'Size 3 nappies (approximately 7–13 kg)',
        'Please check the brand sizing. Up to three claims are welcome.',
        'Care and bath', null, 'multiple', 201, true, 3
    ),
    (
        '00000000-0000-4000-8000-000000000088',
        'Size 4 nappies (approximately 9–14 kg)',
        'Please check the brand sizing. Up to three claims are welcome.',
        'Care and bath', null, 'multiple', 202, true, 3
    ),
    (
        '00000000-0000-4000-8000-000000000058',
        'Baby oil',
        'A gentle, baby-safe oil for skin care or massage.',
        'Care and bath', null, 'multiple', 240, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000059',
        'Baby bath or bath seat',
        'A stable baby bath or age-appropriate bathing support.',
        'Care and bath', null, 'single', 250, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000060',
        'Digital thermometer',
        'A reliable digital thermometer suitable for babies.',
        'Care and bath', null, 'single', 260, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000062',
        'Cotton pads or buds (external use only)',
        'For gentle external clean-up only; never insert into baby’s ears or nose.',
        'Care and bath', null, 'multiple', 280, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000076',
        'Nappy organiser',
        'A simple basket or caddy for nappies and changing supplies.',
        'Care and bath', null, 'single', 295, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000091',
        'Mild baby shampoo',
        'A mild, fragrance-free shampoo and hair wash.',
        'Care and bath', null, 'multiple', 296, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000063',
        'Babygrows',
        'Soft babygrows in useful sizes beyond newborn.',
        'Clothing', null, 'multiple', 300, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000064',
        'Baby mittens',
        'Soft mittens for cool weather, if needed.',
        'Clothing', null, 'multiple', 360, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000065',
        'Jerseys, cardigans or jackets',
        'Warm, easy-to-layer outerwear in useful baby sizes.',
        'Clothing', null, 'multiple', 370, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000066',
        'Bedding for bassinet or cot',
        'Safe, snug bedding made for the bassinet or cot; no loose sleep accessories.',
        'Sleep', null, 'multiple', 400, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000067',
        'Pacifier holders',
        'Short, baby-safe pacifier holders for supervised use.',
        'Play and other', null, 'multiple', 620, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000068',
        'Baby books',
        'Board books, cloth books, or gentle story books for baby.',
        'Play and other', null, 'multiple', 630, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000069',
        'Baby clothes hangers',
        'Small hangers for organising baby clothing.',
        'Play and other', null, 'multiple', 640, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000070',
        'Storage baskets',
        'Useful baskets for organising baby essentials.',
        'Play and other', null, 'multiple', 650, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000071',
        'Baby-store gift vouchers',
        'A flexible option for later needs or anything the registry missed.',
        'Play and other', null, 'multiple', 660, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000072',
        'My First Year photo album',
        'A baby memory or photo book for the first year.',
        'Play and other', null, 'single', 670, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000073',
        'Milestone cards',
        'Cards for recording baby milestones and monthly photos.',
        'Play and other', null, 'single', 680, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000074',
        'Music box or cot mobile',
        'A gentle music box or securely fitted cot mobile for supervised enjoyment.',
        'Play and other', null, 'single', 690, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000084',
        'Reusable water bottle for Mom',
        'A practical water bottle for feeding and everyday use.',
        'For Mom', null, 'single', 700, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000077',
        'Comfortable home clothes',
        'Soft, comfortable clothing for the early days at home.',
        'For Mom', null, 'multiple', 720, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000078',
        'Warm pyjamas or robe',
        'Comfortable warm sleepwear or a soft robe.',
        'For Mom', null, 'multiple', 730, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000079',
        'Comfortable slippers',
        'Soft, easy-to-wear slippers for home.',
        'For Mom', null, 'single', 740, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000080',
        'Warm socks or hot-water bottle',
        'A cosy comfort gift for Mom.',
        'For Mom', null, 'multiple', 750, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000081',
        'Magnesium or vitamins for Mom',
        'Only products Mom already uses or has approved with her healthcare professional.',
        'For Mom', null, 'multiple', 760, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000082',
        'A little relaxation gift for Mom',
        'A thoughtful comfort or relaxation gift for the early weeks.',
        'For Mom', null, 'multiple', 770, true, null
    ),
    (
        '00000000-0000-4000-8000-000000000085',
        'Sunscreen for Mom',
        'A practical sunscreen Mom already likes for outings.',
        'For Mom', null, 'multiple', 780, true, null
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
