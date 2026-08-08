update registry.items
set is_enabled = false
where id in (
    '00000000-0000-4000-8000-000000000032',
    '00000000-0000-4000-8000-000000000022'
);
