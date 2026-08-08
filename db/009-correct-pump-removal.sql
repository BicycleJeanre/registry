update registry.items
set is_enabled = true
where id = '00000000-0000-4000-8000-000000000023';

update registry.items
set is_enabled = false
where id = '00000000-0000-4000-8000-000000000022';
