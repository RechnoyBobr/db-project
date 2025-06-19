-- DML SQL запрос, находит самых невероятных участников, рейтинг которых только не убывает

INSERT INTO rating_history VALUES
    (1, 1, NOW() - INTERVAL '2 minute'),
    (1, 1, NOW() - INTERVAL '1 minute'),
    (1, 1, NOW()),
    (2, 1, NOW() - INTERVAL '2 minute'),
    (2, -1, NOW());

WITH incredible_contestants AS (
    SELECT
        user_id,
        updated_at,
        SUM(diff) OVER (PARTITION BY user_id ORDER BY updated_at) AS total_rating
    FROM rating_history
),
with_lag AS (
    SELECT
        user_id,
        updated_at,
        total_rating,
        LAG(total_rating) OVER (PARTITION BY user_id ORDER BY updated_at) AS prev_rating
    FROM incredible_contestants
),
violations AS (
    SELECT DISTINCT user_id
    FROM with_lag
    WHERE prev_rating IS NOT NULL AND total_rating < prev_rating
)
SELECT DISTINCT user_id
FROM rating_history
WHERE user_id NOT IN (SELECT user_id FROM violations);