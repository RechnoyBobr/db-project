-- DML SQL запрос, который определяет, входит ли пользователь в число призёров(верхние 25% контеста)
WITH scores AS (
    SELECT
        user_id,
        calculate_contest_score(user_id, 999) AS score
    FROM contestants
    WHERE contest_id = 999
),
ranked_scores AS (
    SELECT
        score,
        ROW_NUMBER() OVER (ORDER BY score DESC) AS row_number,
        COUNT(*) OVER () AS total
    FROM scores
),
prize_line AS (
    SELECT score
    FROM ranked_scores
    WHERE row_number = FLOOR(total * 0.25)
)
SELECT score FROM prize_line;