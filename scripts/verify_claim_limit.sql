begin;

insert into registry.items (
    id,
    title,
    description,
    category,
    claim_mode,
    display_order,
    is_enabled,
    max_claims
)
values (
    '00000000-0000-4000-8000-ffffffffffff',
    'Claim limit verification item',
    'Synthetic item used only inside a rolled-back validation transaction.',
    'Verification',
    'multiple',
    9999,
    true,
    3
);

do $$
declare
    v_result text;
    v_attempt integer;
begin
    for v_attempt in 1..3 loop
        select result
        into v_result
        from registry.create_claim(
            '00000000-0000-4000-8000-ffffffffffff',
            encode(digest('claim-limit-' || v_attempt::text, 'sha256'), 'hex')
        );

        if v_result <> 'claimed' then
            raise exception 'Expected claim % to succeed', v_attempt;
        end if;
    end loop;

    select result
    into v_result
    from registry.create_claim(
        '00000000-0000-4000-8000-ffffffffffff',
        encode(digest('claim-limit-4', 'sha256'), 'hex')
    );

    if v_result <> 'claim_limit_reached' then
        raise exception 'Expected fourth claim to reach the limit';
    end if;
end;
$$;

rollback;

\echo 'PASS: three claims accepted and the fourth rejected'
