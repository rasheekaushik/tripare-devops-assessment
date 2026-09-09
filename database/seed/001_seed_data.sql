INSERT INTO hotel_bookings (
    id,
    org_id,
    hotel_id,
    city,
    checkin_date,
    checkout_date,
    amount,
    status,
    created_at
)
SELECT
    gen_random_uuid(),
    (
        ARRAY[
            '11111111-1111-1111-1111-111111111111'::uuid,
            '22222222-2222-2222-2222-222222222222'::uuid,
            '33333333-3333-3333-3333-333333333333'::uuid,
            '44444444-4444-4444-4444-444444444444'::uuid,
            '55555555-5555-5555-5555-555555555555'::uuid
        ]
    )[1 + floor(random() * 5)::int],
    'HOTEL-' || lpad((1 + floor(random() * 100))::int::text, 4, '0'),
    (
        ARRAY[
            'delhi',
            'mumbai',
            'bangalore',
            'hyderabad',
            'pune',
            'chennai',
            'kolkata',
            'jaipur'
        ]
    )[1 + floor(random() * 8)::int],
    CURRENT_DATE + floor(random() * 60)::int,
    CURRENT_DATE + floor(random() * 60)::int + 1,
    round((1000 + random() * 49000)::numeric, 2),
    (
        ARRAY[
            'confirmed',
            'cancelled',
            'pending',
            'completed'
        ]
    )[1 + floor(random() * 4)::int],
    NOW() - (floor(random() * 90)::int || ' days')::interval
FROM generate_series(1, 10000);

INSERT INTO booking_events (
    booking_id,
    event_type,
    payload,
    created_at
)
SELECT
    id,
    (
        ARRAY[
            'booking_created',
            'booking_confirmed',
            'payment_completed',
            'booking_cancelled'
        ]
    )[1 + floor(random() * 4)::int],
    jsonb_build_object(
        'source', 'seed',
        'booking_id', id::text
    ),
    created_at + interval '5 minutes'
FROM (
    SELECT id, created_at
    FROM hotel_bookings
    ORDER BY created_at
    LIMIT 3000
) bookings;
