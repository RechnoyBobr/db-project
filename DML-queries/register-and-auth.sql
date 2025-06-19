CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION register_user(
    p_login VARCHAR,
    p_password VARCHAR,
    p_icon VARCHAR DEFAULT 'icon.png',
    p_description VARCHAR DEFAULT NULL,
    p_is_admin BOOLEAN DEFAULT FALSE
) RETURNS TEXT AS $$
DECLARE
    existing_user_count INT;
    new_id BIGINT;
BEGIN
    SELECT COUNT(*) INTO existing_user_count
    FROM "user"
    WHERE login = p_login;

    IF existing_user_count > 0 THEN
        RETURN 'Login already exists';
    END IF;

    SELECT COALESCE(MAX(id), 0) + 1 INTO new_id
    FROM "user";

    INSERT INTO "user" (id, login, password, icon, description, is_admin)
    VALUES (new_id, p_login, crypt(p_password, gen_salt('bf')), p_icon, p_description, p_is_admin);

    RETURN 'Registration successful';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION auth(
    p_login VARCHAR,
    p_password VARCHAR
) RETURNS TEXT AS $$
DECLARE
    stored_password VARCHAR;
BEGIN
    SELECT password INTO stored_password
    FROM "user"
    WHERE login = p_login;

    IF stored_password IS NULL THEN
        RETURN 'Invalid login or password';
    END IF;

    IF crypt(p_password, stored_password) = stored_password THEN
        RETURN 'Login successful';
    ELSE
        RETURN 'Invalid login or password';
    END IF;
END;
$$ LANGUAGE plpgsql;


SELECT register_user('logyxa', 'passwordyxa');

SELECT * FROM "user" where login = 'logyxa';

SELECT auth('logyxa', 'passwordyxa');
SELECT auth('logyxa', 'passwordyxa_wrong');