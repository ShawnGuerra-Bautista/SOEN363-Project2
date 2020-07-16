# Python Questions from Stackoverflow Couchbase Database Project
Dataset used for a class project

## How to install the required packages?
- Install Couchbase Community edition
- https://www.couchbase.com/downloads
- By default, your db will be running on http://localhost:8091/

## How to download the dataset?
- Create a Kaggle Account and download the following dataset
- https://www.kaggle.com/stackoverflow/pythonquestions
- To use the fraciton of the dataset we used, execute the following in the command line and make sure you are in the directory where the files are in:
-- sudo split -l 4987937 Questions.csv
-- sudo split -l 4425992 Answers.csv
-- sudo split -l 471270 Tags.csv
- When splitting the file, only use the first part of it
- Also, for each statement executed, make sure you rename the first part to anything you want, and delete the remaining parts

## How to run the code?
- On http://localhost:8091/, create 2 buckets called python_posts and python_posts_tags
- Run the following code in your command line to load
```
/opt/couchbase/bin/cbimport csv -c localhost:8091 -u "your username w/o quotes" -p "your password w/o quotes" -b python_posts -d file:///python_question_data/Questions.csv --generate-key question::%Id%

/opt/couchbase/bin/cbimport csv -c localhost:8091 -u "your username w/o quotes" -p "your password w/o quotes" -b python_posts -d file:///python_question_data/Answers.csv --generate-key answer::%Id%

/opt/couchbase/bin/cbimport csv -c localhost:8091 -u "your username w/o quotes" -p "your password w/o quotes" -b python_posts_tags -d file:///python_question_data/Tags.csv --generate-key tag::%Id%::%Tag%
```
- Go back to http://localhost:8091/ and execute the following queries
```
CREATE INDEX ix_Title ON python_posts(Title);
CREATE INDEX ix_ParentId ON python_posts(ParentId);

UPDATE python_posts
SET type = ‘question’
WHERE Title IS NOT MISSING;

UPDATE python_posts
SET type = ‘question’
WHERE ParentId IS NOT MISSING;
```
- You are now ready to run your code, but create all the necessary indices first
- Good luck!
