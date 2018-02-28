DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Arthur', 'Miller'),
  ('Eugene', 'O''Neil');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('Question1', 'BODY1', (SELECT id FROM users WHERE fname = 'Arthur' AND lname = 'Miller')),
  ('Question2', 'BODY2', (SELECT id FROM users WHERE fname = 'Eugene' AND lname = 'O''Neil'));

-- INSERT INTO
--   question_follows
INSERT INTO
  replies(body, user_id, question_id)
VALUES
  ('Answer1', (SELECT id FROM users WHERE fname = 'Arthur' AND lname = 'Miller'),
              (SELECT id FROM questions WHERE title = 'Question1')),
  ('Answer2', (SELECT id FROM users WHERE fname = 'Eugene' AND lname = 'O''Neil'),
              (SELECT id FROM questions WHERE title = 'Question2'));

INSERT INTO
  question_likes(user_id, question_id)
VALUES
((SELECT id FROM users WHERE fname = 'Arthur' AND lname = 'Miller'),
            (SELECT id FROM questions WHERE title = 'Question1')),
((SELECT id FROM users WHERE fname = 'Eugene' AND lname = 'O''Neil'),
            (SELECT id FROM questions WHERE title = 'Question2'));

INSERT INTO
  question_follows(user_id, question_id)
VALUES
((SELECT id FROM users WHERE fname = 'Arthur' AND lname = 'Miller'),
            (SELECT id FROM questions WHERE title = 'Question1')),
((SELECT id FROM users WHERE fname = 'Eugene' AND lname = 'O''Neil'),
            (SELECT id FROM questions WHERE title = 'Question2'));
