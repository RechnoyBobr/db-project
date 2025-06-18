SELECT
    rh.user_id,
    u.login,
    rh.diff AS rating_change,
    rh.updated_at
FROM rating_history rh
         JOIN "user" u ON u.id = rh.user_id
WHERE rh.updated_at >= (
    SELECT start_time FROM contest WHERE id = 999 -- 999 заменяем на нужный контест
)
  AND rh.updated_at <= (
    SELECT end_time FROM contest WHERE id = 999 -- тут тоже
)
ORDER BY rh.diff DESC;
