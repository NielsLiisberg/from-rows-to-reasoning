-- Configure the AI endpoint and model to use for SQLR2R. You can either run your own instance of Olama 
-- or use the hosted version. If you use the hosted version, make sure to get your own API key from olama.com 
-- and set it in the ai_key variable.

-- First let's run it local: Install it from here
-- https://ollama.com/download

-- pull a model: ( here i pull a super tiny one to test, but you can pull any of the models listed on the olama hub
-- ollama pull deepseek-coder:latest

-- I use 
-- ollama pull llama3:latest

-- there is a lot:
-- 'llama3',
-- 'llama3.3:70b',
-- 'llama3:8b',
-- 'mistral:7b',
-- 'gemma3:27b',
-- 'deepseek-r1:1.5b',

-- And set model and endpoint here:
create or replace variable sqlr2r.ai_model            varchar(256) default 'llama3:latest';

-- API key if you use the hosted version, you can get your own free key from olama.com
create or replace variable sqlr2r.ai_key              varchar(2560) default ''; 

-- Next up. Your IBM i needs to be able to reach the olama endpoint. 
-- If you run it local, make sure to set the ai_endpoint variable to the IP address of your machine. 
-- You can find this by running "curl ifconfig.me/ip" from a terminal on your machine.

-- curl ifconfig.me/ip
create or replace variable sqlr2r.ai_endpoint varchar(256) default 'http://put-your-olama-host-ip-here:11434/api/chat';

-- look like this:
create or replace variable sqlr2r.ai_endpoint varchar(256) default 'http://87.63.251.14:11434/api/chat';


-- Now what do we have:
values (
    sqlr2r.ai_model, 
    sqlr2r.ai_key, 
    sqlr2r.ai_endpoint
);

-- does it work ? 
values qsys2.http_get  (
    url             => sqlr2r.ai_endpoint  -- from config, can be local or hosted
);




