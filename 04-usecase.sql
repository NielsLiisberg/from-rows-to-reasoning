-- the inbox. Now let's build a function that takes a question and instructions as input, sends it to the ai and returns the answer. We will use the http_post function to send the request to the ai and get the response. The format of the request and response is different between providers, so we need to wrangle it a bit to get the answer. 
select * from sqlr2r.in_tray;

values sqlr2r.ask_ai  (
    instructions => 'The database is: Db2 for i. respond SQL always in lowercase.' ,
    question  => '
        create or replace an sql view that shows an resume of the inbox table. 
        the inbox is named sqlr2r.in_tray. 
        and has the following columns: SOURCE, SUBJECT, NOTE_TEXT.
        the sql UDF that call the AI is sqlr2r.ask_ai and it takes two parameters, instructions and question.' 
);

create or replace view sqlr2r.in_tray_resume as
select
  source,
  subject,
  sqlr2r.ask_ai(
    'summarize the following inbox message in one concise sentence. preserve any named entities and important actions. if the message is empty, return an empty string.',
    'subject: ' || coalesce(subject,'') || '; note: ' || coalesce(note_text,'')
  ) as resume
from sqlr2r.in_tray;

select * from sqlr2r.in_tray_resume;

-- the response is:
create or replace view sqlr2r.in_tray_resume as
select
  source,
  subject,
  sqlr2r.ask_ai(
    'summarize the following note in one concise sentence. be neutral and keep it to one sentence.',
    note_text
  ) as summary
from sqlr2r.in_tray;

-- does it work?
select * from sqlr2r.in_tray_resume;

values sqlr2r.ask_ai  (
    instructions => 'The database is: Db2 for i. respond SQL always in lowercase.' ,
    question  => '
        construct or replace an sql view based on the table sqlr2r.in_tray.
        the sqlr2r.in_tray table has the following columns: SOURCE, SUBJECT, NOTE_TEXT.
        The view shows the source, subject and note_text, an sort summary of NOTE_TEXT call SUMMARY.
        additional a column named SENTIMENT that shows the sentiment of the note_text with the exact values of positive, negative or neutraL. 
        the sql UDF that call the AI is sqlr2r.ask_ai and it takes two parameters, instructions and question.'
);
 

create or replace view sqlr2r.in_tray_ai_view as
select
  source,
  subject,
  note_text,
  sqlr2r.ask_ai(
    'summarize the following text in one short sentence',
    note_text
  ) as summary,
  sqlr2r.ask_ai(
    'determine the sentiment of the following text. return exactly one of: positive, negative, neutral. return only that single word with no extra punctuation or explanation',
    note_text
  ) as sentiment
from sqlr2r.in_tray;

select  * from sqlr2r.in_tray_ai_view;

-- now it's getting more interesting, now AI is using it self in the query  
-- this is the response: 
create or replace view sqlr2r.in_tray_view as
select
  source,
  subject,
  note_text,
  cast(sqlr2r.ask_ai(
    'provide a concise summary (one short sentence or phrase, no more than 120 characters) of the following text.',
    note_text
  ) as varchar(240)) as summary,
  lower(cast(sqlr2r.ask_ai(
    'analyze the sentiment of the following text and return exactly one of these three words: positive, negative, neutral. do not return anything else, no punctuation, no explanation.',
    note_text
  ) as varchar(20))) as sentiment
from sqlr2r.in_tray;

-- does it work ? 
select * from sqlr2r.in_tray_view;

