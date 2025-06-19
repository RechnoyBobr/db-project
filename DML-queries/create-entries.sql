-- Создаёт данные для теста процедур и запросов
INSERT INTO "user" (id, login, password, rating, icon, description, is_admin)
SELECT
    gs AS id,
    'user_' || gs AS login,
    'hashed_password_' || gs AS password,
    (random() * 2000)::int AS rating,
    'icon_' || gs || '.png' AS icon,
    'User description #' || gs AS description,
    false AS is_admin
FROM generate_series(1, 100) AS gs;
INSERT INTO "task" (id, name, source, tests_amount)
SELECT
    gs AS id,
    'Task #' || gs AS name,
    'tasks/task_' || gs || '.zip' AS source,
    (5 + (random() * 15))::int AS tests_amount
FROM generate_series(1, 100) AS gs;
INSERT INTO lang (id, name) VALUES (1, 'C++');
INSERT INTO contest_diff (id, name) VALUES (1, 'Div. 1');
INSERT INTO contest (id, name, start_time, end_time, difficulty_id)
VALUES (999, 'Test Contest', now() - interval '2 hours', now() + interval '1 hour', 1);

INSERT INTO task (id, name, source, tests_amount)
VALUES
    (101, 'Task A', 'tasks/task_a.zip', 10),
    (102, 'Task B', 'tasks/task_b.zip', 15);

INSERT INTO task_constraints (task_id, lang_id, time_constraint, memory_constraint)
VALUES
    (101, 1, 2000, 256),
    (102, 1, 2000, 256);

INSERT INTO contestants (user_id, contest_id)
VALUES
    (1, 999),
    (2, 999);

INSERT INTO solution (
    id, source, time_used, memory_used, sent_at,
    user_id, contest_id, task_id, lang_id, verdict_id
)
VALUES
    (1001, 'submissions/u1_task_a.cpp', 1500, 128, now() - interval '90 minutes',
     1, 999, 101, 1, 1),
    (1002, 'submissions/u1_task_b.cpp', 1400, 130, now() - interval '80 minutes',
     1, 999, 102, 1, 1);

INSERT INTO solution (
    id, source, time_used, memory_used, sent_at,
    user_id, contest_id, task_id, lang_id, verdict_id
)
VALUES
    (1003, 'submissions/u2_task_a.cpp', 1800, 120, now() - interval '70 minutes',
     2, 999, 101, 1, 2),
    (1004, 'submissions/u2_task_b.cpp', 1800, 120, now() - interval '70 minutes',
     2, 999, 102, 1, 1);
