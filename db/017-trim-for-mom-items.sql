-- Keep historical claims intact while removing these items from the public list.
update registry.items
set is_enabled = false
where id in (
    '00000000-0000-4000-8000-000000000078',
    '00000000-0000-4000-8000-000000000079',
    '00000000-0000-4000-8000-000000000080',
    '00000000-0000-4000-8000-000000000081',
    '00000000-0000-4000-8000-000000000084'
);
