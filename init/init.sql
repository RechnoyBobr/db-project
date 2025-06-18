CREATE TABLE "user" (
                        "id" bigint PRIMARY KEY,
                        "login" varchar(100) NOT NULL,
                        "password" varchar(100) NOT NULL,
                        "rating" int DEFAULT 0,
                        "icon" varchar(100) DEFAULT 'icon.png',
                        "description" varchar(500),
                        "is_admin" bool DEFAULT false
);

CREATE TABLE "contest" (
                           "id" bigint PRIMARY KEY,
                           "name" varchar(100) NOT NULL,
                           "start_time" timestamp NOT NULL,
                           "end_time" timestamp NOT NULL,
                           "difficulty_id" bigint
);

CREATE TABLE "task" (
                        "id" bigint PRIMARY KEY,
                        "name" varchar(100) NOT NULL,
                        "source" varchar(100) NOT NULL,
                        "tests_amount" int NOT NULL
);

CREATE TABLE "rating_history" (
                                  "user_id" bigint,
                                  "diff" int NOT NULL,
                                  "updated_at" timestamp,
                                  PRIMARY KEY ("user_id", "updated_at")
);

CREATE TABLE "lang" (
                        "id" bigint PRIMARY KEY,
                        "name" varchar(100) NOT NULL
);

CREATE TABLE "contest_lang" (
                                "contest_id" bigint,
                                "lang_id" bigint
);

CREATE TABLE "task_constraints" (
                                    "time_constraint" int NOT NULL,
                                    "memory_constraint" int NOT NULL,
                                    "task_id" bigint,
                                    "lang_id" bigint,
                                    PRIMARY KEY ("task_id", "lang_id")
);

CREATE TABLE "solution" (
                            "id" bigint PRIMARY KEY,
                            "source" varchar(100) NOT NULL,
                            "time_used" int NOT NULL,
                            "memory_used" int NOT NULL,
                            "sent_at" timestamp NOT NULL,
                            "user_id" bigint,
                            "contest_id" bigint,
                            "task_id" bigint,
                            "lang_id" bigint,
                            "verdict_id" bigint
);

CREATE TABLE "contestants" (
                               "user_id" bigint,
                               "contest_id" bigint,
                               PRIMARY KEY ("user_id", "contest_id")
);

CREATE TABLE "verdict" (
                           "id" bigint PRIMARY KEY,
                           "description" varchar(100) NOT NULL
);

CREATE TABLE "contest_diff" (
                                "id" bigint PRIMARY KEY,
                                "name" varchar(100) NOT NULL
);

ALTER TABLE "contest" ADD FOREIGN KEY ("difficulty_id") REFERENCES "contest_diff" ("id");

ALTER TABLE "rating_history" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "contest_lang" ADD FOREIGN KEY ("contest_id") REFERENCES "contest" ("id");

ALTER TABLE "contest_lang" ADD FOREIGN KEY ("lang_id") REFERENCES "lang" ("id");

ALTER TABLE "task_constraints" ADD FOREIGN KEY ("task_id") REFERENCES "task" ("id");

ALTER TABLE "task_constraints" ADD FOREIGN KEY ("lang_id") REFERENCES "lang" ("id");

ALTER TABLE "solution" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "solution" ADD FOREIGN KEY ("contest_id") REFERENCES "contest" ("id");

ALTER TABLE "solution" ADD FOREIGN KEY ("task_id") REFERENCES "task" ("id");

ALTER TABLE "solution" ADD FOREIGN KEY ("lang_id") REFERENCES "lang" ("id");

ALTER TABLE "solution" ADD FOREIGN KEY ("verdict_id") REFERENCES "verdict" ("id");

ALTER TABLE "contestants" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "contestants" ADD FOREIGN KEY ("contest_id") REFERENCES "contest" ("id");
