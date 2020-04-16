# SOEN363-Project2
Dataset used for SOEN 363 Project 2

## How to install the required packages?
- Install Couchbase Community edition
- https://www.couchbase.com/downloads
- By default, you db will be running on http://localhost:8091/

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
- All details about running the code are in the report (only the prof has access to it).
