-- Code to run before analyzing dataset
CREATE INDEX ix_Title ON python_posts(Title);
CREATE INDEX ix_ParentId ON python_posts(ParentId);

UPDATE python_posts
SET type = ‘question’
WHERE Title IS NOT MISSING;

UPDATE python_posts
SET type = ‘question’
WHERE ParentId IS NOT MISSING;

-- INDICES

--Indices used for queries
CREATE INDEX ix_id_type 
ON python_posts(Id, Type);

CREATE INDEX ix_parentId_type 
ON python_posts(ParentId, Type);

CREATE INDEX ix_tagId
ON python_posts_tags(Id);

CREATE INDEX ix_numScore_type 
ON python_posts(TONUMBER(Score), type);

CREATE INDEX ix_parentId_id_numScore_type 
ON python_posts(ParentId, Id, TONUMBER(Score), type);

CREATE INDEX ix_id_title_creationDate_milisCreationDate 
ON python_posts(Id, Title, CreationDate, MILLIS(CreationDate), type);

CREATE INDEX ix_tagId_tag 
ON python_posts_tags(Id, Tag);

CREATE INDEX ix_tag 
ON python_posts_tags(Tag);

CREATE INDEX ix_yearCreationDate_id_type 
ON python_posts(DATE_PART_STR(CreationDate, 'year'), Id, type);

CREATE INDEX ix_title_type 
ON python_posts(Title, type);

-- QUERIES

-- Add answers within the document of the questions (Limit to 100 questions ordered by Id, and no modification to the documents)

SELECT p.*, a AS answers
FROM python_posts AS p
NEST python_posts AS a ON p.Id = a.ParentId AND a.type = 'answer'
WHERE p.type = 'question'
ORDER BY p.Id
LIMIT 100;

-- Add tags within the document of the questions (Limit to 100 questions ordered by Id, and no modification to the documents)

SELECT p.*, t AS tags
FROM python_posts AS p
NEST python_posts_tags AS t ON p.Id = t.Id
WHERE p.type = 'question'
ORDER BY p.Id
LIMIT 100;

-- Obtain the question with the highest score

SELECT p1.*
FROM python_posts AS p1
WHERE p1.type = 'question'
    AND TONUMBER(p1.Score) IN (
    SELECT RAW MAX(TONUMBER(p2.Score))
    FROM python_posts AS p2
    WHERE p2.type = 'question');

-- Obtain the question which contains an answer with the highest score

SELECT p.*
FROM python_posts AS p
LET top_answer_id = (SELECT RAW p1.ParentId
FROM python_posts AS p1
WHERE p1.type = 'answer'
    AND TONUMBER(p1.Score) IN (
    SELECT RAW MAX(TONUMBER(p2.Score))
    FROM python_posts AS p2
    WHERE p2.type = 'answer')
ORDER BY p1.Id
LIMIT 1)
WHERE p.Id IN top_answer_id AND p.type = 'question';

-- For the top 10 oldest questions, obtain their id, title, creation date and tags

SELECT p.Id, p.Title, p.CreationDate, t AS tags
FROM python_posts AS p
NEST python_posts_tags AS t ON t.Id = p.Id
WHERE p.type = 'question'
ORDER BY MILLIS(p.CreationDate) ASC
LIMIT 10;

-- Obtain the questions with the most popular tag (Limit to 100 questions ordered by Id)

SELECT p.*
FROM python_posts p
WHERE p.Id IN (SELECT RAW t1.Id
	FROM python_posts_tags AS t1
	WHERE t1.Tag IN (SELECT RAW t2.Tag
		FROM (SELECT t3.Tag, COUNT(DISTINCT Id) AS tag_count
			FROM python_posts_tags AS t3
			WHERE Id IS NOT MISSING AND Tag <> 'python'
			GROUP BY t3.Tag
			ORDER BY tag_count DESC
			LIMIT 1) AS t2)
	ORDER BY t1.Id
	LIMIT 100)
AND p.type = 'question' 
ORDER BY p.Id;

-- Obtain the total number of question made in 2011

SELECT DATE_PART_STR(p.CreationDate, 'year') AS year, COUNT(DISTINCT p.Id) AS num_questions
FROM python_posts AS p
WHERE p.type = 'question'
GROUP BY DATE_PART_STR(p.CreationDate, 'year')
HAVING DATE_PART_STR(p.CreationDate, 'year') = 2011;

-- For the first 10’000 questions (ordered by Id), 
-- obtain their title and the number of answers on that post, 
-- then order them by number of answer in descending order.

SELECT p1.Title, ARRAY_LENGTH(p1.answers) AS num_answers
FROM (SELECT p2.*, a AS answers
FROM python_posts AS p2
NEST python_posts AS a ON p2.Id = a.ParentId AND a.type = 'answer'
WHERE p2.type = 'question'
ORDER BY p2.Id
LIMIT 10000) AS p1
ORDER BY num_answers DESC;

-- Obtain the answers that have score more than 800

SELECT p.*
FROM python_posts AS p
WHERE TONUMBER(p.Score) >= 800 AND type = 'answer';

-- Obtain the questions which have the title “Python and MySQL”

SELECT p.*
FROM python_posts AS p
WHERE Title = 'Python and MySQL' and type = ‘question’;
