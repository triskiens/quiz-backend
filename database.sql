DROP TABLE IF EXISTS user_answers_history CASCADE;
DROP TABLE IF EXISTS attempt CASCADE;
DROP TABLE IF EXISTS options CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS quizzes CASCADE;
DROP TABLE IF EXISTS users CASCADE;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255),
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    difficulty VARCHAR(10),
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
    content TEXT,
    explanation TEXT
);

CREATE TABLE options (
    id SERIAL PRIMARY KEY,
    question_id INT REFERENCES questions(id) ON DELETE CASCADE,
    content TEXT,
    is_correct BOOLEAN
);

CREATE TABLE attempt (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    quiz_id UUID REFERENCES quizzes(id),
    score INT,
    starting_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(20)
);

CREATE TABLE user_answers_history (
    id SERIAL PRIMARY KEY,
    attempt_id UUID REFERENCES attempt(id),
    question_id INT REFERENCES questions(id),
    option_id INT REFERENCES options(id)
);
-- Tạo user
INSERT INTO users (email)
VALUES ('test@gmail.com');

-- Tạo quiz
INSERT INTO quizzes (user_id, title, difficulty)
VALUES (
    (SELECT id FROM users LIMIT 1),
    'Math Quiz',
    'easy'
);

-- Tạo question
INSERT INTO questions (quiz_id, content)
VALUES (
    (SELECT id FROM quizzes LIMIT 1),
    '2 + 2 = ?'
);

-- Tạo options
INSERT INTO options (question_id, content, is_correct)
VALUES
(1, '3', false),
(1, '4', true),
(1, '5', false),
(1, '6', false);
INSERT INTO attempt (user_id, quiz_id, starting_time, status)
VALUES (
    (SELECT id FROM users LIMIT 1),
    (SELECT id FROM quizzes LIMIT 1),
    NOW(),
    'in_progress'
);
INSERT INTO user_answers_history (attempt_id, question_id, option_id)
VALUES (
    (SELECT id FROM attempt LIMIT 1),
    1,
    2
);
SELECT COUNT(*) AS score
FROM user_answers_history uah
JOIN options o ON uah.option_id = o.id
WHERE uah.attempt_id = (SELECT id FROM attempt LIMIT 1)
AND o.is_correct = true;
UPDATE attempt
SET score = (
    SELECT COUNT(*)
    FROM user_answers_history uah
    JOIN options o ON uah.option_id = o.id
    WHERE uah.attempt_id = attempt.id
    AND o.is_correct = true
),
status = 'finished',
end_time = NOW();
