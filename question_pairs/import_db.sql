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
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  body TEXT NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
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
  ('Foo', 'Bar'),
  ('Hang', 'Man'),
  ('Java','Script'),
  ('Reuben','Rails');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('How 2 SQel', 'I cannot select name - what is Foreign Key to me', (SELECT id FROM users WHERE fname = 'Foo' AND lname = 'Bar')),
  ('Can''t guess the word', 'running out of limbs, not passing specs yo', (SELECT id FROM users WHERE fname = 'Hang' AND lname = 'Man')),
  ('When r u done w/ ruby??', 'ruby sux', (SELECT id FROM users WHERE fname = 'Java' AND lname = 'Script')),
  ('Who uses Java anymore?', 'srsly want 2 know', (SELECT id FROM users WHERE fname = 'Reuben' AND lname = 'Rails'));

  INSERT INTO
    question_follows(question_id, user_id)
  VALUES
    ((SELECT id FROM questions WHERE title = 'How 2 SQel'),(SELECT id FROM users WHERE fname = 'Java' AND lname = 'Script')),
    ((SELECT id FROM questions WHERE title = 'Can''t guess the word'),(SELECT id FROM users WHERE fname = 'Reuben' AND lname = 'Rails')),
    ((SELECT id FROM questions WHERE title = 'Can''t guess the word'),(SELECT id FROM users WHERE fname = 'Hang' AND lname = 'Man'));

INSERT INTO
  replies(question_id, user_id, parent_reply_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'How 2 SQel'),(SELECT id FROM users WHERE fname = 'Reuben' AND lname = 'Rails'), NULL, 'It''s easy. R u dumb? Google it man.');

INSERT INTO
  replies(question_id, user_id, parent_reply_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'Who uses Java anymore?'),(SELECT id FROM users WHERE fname = 'Reuben' AND lname = 'Rails'), NULL, 'This is my second reply');

INSERT INTO
  replies(question_id, user_id, parent_reply_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'How 2 SQel'),(SELECT id FROM users WHERE fname = 'Hang' AND lname = 'Man'), (SELECT id FROM replies WHERE body = 'It''s easy. R u dumb? Google it man.' ), 'I am the child reply.');

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Java' AND lname = 'Script'),(SELECT id FROM questions WHERE title = 'How 2 SQel')),
  ((SELECT id FROM users WHERE fname = 'Hang' AND lname = 'Man'),(SELECT id FROM questions WHERE title = 'How 2 SQel'));
