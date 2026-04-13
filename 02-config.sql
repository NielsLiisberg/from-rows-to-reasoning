-- To acces open api you need to set the endpoint, model and key. 
-- You can get a free key from openai.com and use any of the models listed on their website.
create or replace variable sqlr2r.ai_endpoint   varchar(256)  default 'https://api.openai.com/v1/responses';
create or replace variable sqlr2r.ai_key        varchar(2560) default 'xsk-proj-yy7HA6JDV-ydgdXrNVHH8CtJlXkGDTDNjTLPmxSmabE6nDlfo9gp9ok2JCRt0MLAQ4mYv67uAAT3BlbkFJGcXdmUEFwMW93-Ucy8tyyBY14NFj2e-kCbJF2w7OcUu8HvjbzhSH8E9uzbd0IW4l-z3qsMWJoA'; 
create or replace variable sqlr2r.ai_model      varchar(256)  default 'gpt-5-mini';

-- Now what do we have:
values (
    sqlr2r.ai_model, 
    sqlr2r.ai_key, 
    sqlr2r.ai_endpoint
);

-- does it work ? It wil complan Missing bearer or basic authentication in header, but at least we know we can reach the endpoint from our IBM i
values qsys2.http_get  (
    url  => sqlr2r.ai_endpoint  -- from config, can be local or hosted
);




