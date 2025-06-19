-- Процедура для расчёта рейтинга
CREATE FUNCTION calculate_contest_score(
    p_user_id BIGINT,
    p_contest_id BIGINT
) RETURNS INT AS
$$
DECLARE
    total_score      INT := 0;
    task_rec         RECORD;
    contest_start    TIMESTAMP;
    contest_end      TIMESTAMP;
    task_score       NUMERIC;
    duration_seconds NUMERIC;
BEGIN
    SELECT start_time, end_time
    INTO contest_start, contest_end
    FROM contest
    WHERE id = p_contest_id;

    duration_seconds := EXTRACT(EPOCH FROM contest_end - contest_start);

    FOR task_rec IN
        SELECT task_id, MIN(sent_at) AS first_accepted_time
        FROM solution
        WHERE user_id = p_user_id
          AND contest_id = p_contest_id
          AND verdict_id = 1
        GROUP BY task_id
        LOOP
            task_score := 1000 - (
                (EXTRACT(EPOCH FROM task_rec.first_accepted_time - contest_start) / duration_seconds) * 500
                );
            IF task_score < 500 THEN
                task_score := 500;
            END IF;
            total_score := total_score + task_score::INT;
        END LOOP;

    RETURN total_score;
END;
$$ LANGUAGE plpgsql;

-- Процедура для расчёта рейтинга всех участников контеста
CREATE FUNCTION calculate_contest_rating(p_contest_id BIGINT)
    RETURNS VOID AS
$$
DECLARE
    rec         RECORD;
    score_map   RECORD;
    total_score INT := 0;
    user_count  INT := 0;
    avg_score   NUMERIC;
    user_score  INT;
    diff        INT;
BEGIN
    FOR rec IN
        SELECT user_id FROM contestants WHERE contest_id = p_contest_id
        LOOP
            user_score := calculate_contest_score(rec.user_id, p_contest_id);
            total_score := total_score + user_score;
            user_count := user_count + 1;
        END LOOP;

    IF user_count = 0 THEN
        RAISE NOTICE 'Нет участников в контесте %', p_contest_id;
        RETURN;
    END IF;

    avg_score := total_score::NUMERIC / user_count;

    FOR rec IN
        SELECT user_id FROM contestants WHERE contest_id = p_contest_id
        LOOP
            user_score := calculate_contest_score(rec.user_id, p_contest_id);
            diff := FLOOR((user_score - avg_score) / 10);

            IF (SELECT rating FROM "user" WHERE id = rec.user_id) + diff < 0 THEN
                diff := - (SELECT rating FROM "user" WHERE id = rec.user_id);
            END IF;

            INSERT INTO rating_history (user_id, diff, updated_at)
            VALUES (rec.user_id, diff, now());

            UPDATE "user"
            SET rating = rating + diff
            WHERE id = rec.user_id;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Создание контеста
CREATE FUNCTION create_contest(
    user_id bigint,
    contest_name varchar(100),
    start_time timestamp with time zone,
    end_time timestamp with time zone,
    difficulty bigint
) RETURNS VOID AS
$$
DECLARE
    has_rights bool;
BEGIN
    SELECT "user".is_admin INTO has_rights FROM "user" WHERE user_id = id;
    IF NOT has_rights THEN
        RAISE NOTICE 'У вас нет прав для создания контеста';
        RETURN;
    END IF;
    INSERT INTO contest (id, name, start_time, end_time, difficulty_id)
    VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM contest),
            contest_name, start_time, end_time, difficulty);
    RAISE INFO 'Контест успешно создан';
END;
$$ LANGUAGE plpgsql;

-- Регистрация участника на контест
CREATE FUNCTION register_on_contest(
    user_id bigint,
    contest_id bigint
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO contestants (user_id, contest_id) VALUES (user_id, contest_id);
END;
$$ language plpgsql;