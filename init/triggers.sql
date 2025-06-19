CREATE FUNCTION normalize_contest_times()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.start_time := NEW.start_time AT TIME ZONE 'UTC';
    NEW.end_time := NEW.end_time AT TIME ZONE 'UTC';
    IF NEW.start_time < NEW.end_time THEN
        RAISE EXCEPTION 'Контест не может закончиться раньше, чем начаться';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_normalize_times
    BEFORE INSERT OR UPDATE
    ON contest
    FOR EACH ROW
EXECUTE FUNCTION normalize_contest_times();

CREATE FUNCTION normalize_solution_sent_time()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.sent_at := NEW.sent_at AT TIME ZONE 'UTC';

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_normalize_solution_time
    BEFORE INSERT OR UPDATE
    ON solution
    FOR EACH ROW
EXECUTE FUNCTION normalize_solution_sent_time();


CREATE FUNCTION check_user()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (SELECT user_id FROM contestants WHERE user_id = NEW.user_id AND contest_id = NEW.contest_id) IS NULL THEN
        RAISE EXCEPTION 'Пользователь не зарегистрирован на контест';
    END IF;
    IF (SELECT contest.end_time FROM contest WHERE id = NEW.contest_id) < NEW.sent_at THEN
        RAISE EXCEPTION 'Задача уже не может быть отправлена, т.к. контест завершён';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_if_user_contestant
    BEFORE INSERT OR UPDATE
    ON solution
    FOR EACH ROW
EXECUTE FUNCTION check_user();


CREATE FUNCTION check_task()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.tests_amount < 1 THEN
        RAISE EXCEPTION 'У задачи должен быть как минимум 1 тест';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_task_tests
    BEFORE INSERT OR UPDATE ON task
    FOR EACH ROW
    EXECUTE FUNCTION check_task();