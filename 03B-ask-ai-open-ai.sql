create or replace function  sqlr2r.ask_ai (
    question            clob,
    instructions        clob default 'Answers as an assistant'
 )
returns clob

    specific ASKAI 
    language sql
    modifies sql data
    set option output=*print, commit=*none, dbgview=*source
    
begin 

    declare answer clob;
    declare header clob; 
    declare payload clob; 
    declare response clob;

    -- We send requestion in JSON format, header is required
    set header = json_object ( 
        'sslTolerate' : 'true',
        'headers' : json_object ( 
            'Content-Type'  : 'application/json;charset=UTF-8',
            'Authorization' : 'Bearer ' || sqlr2r.ai_key ABSENT ON NULL
        ) 
    ); 

    -- The payload has two of our components, system instructions and the question. (and the model) 
    -- the rest is meta data to control the response, you can experiment with it to see how it changes the answer.
    -- The format of the payload is different between providers, for olama we can send the question and instructions in a messages array, but for open ai we need to send them as separate fields.
    set payload = json_object ( 
        'model'    : sqlr2r.ai_model,
        'reasoning': json_object (
            'effort': 'low'
        ),
        'stream'   : 'false' format json, -- we want the response all at once, not in a stream
        'max_output_tokens': int(10000),
        'instructions': instructions,
        'input'    : question
    );

    -- Let's log the header and payload we send to the ai, this is useful for debugging and to see what we are sending to the ai. 
    insert into  sqlr2r.trace (text) values( header);
    insert into  sqlr2r.trace (text) values( payload);
    
    -- Now we send the request to the ai, we use http_post to send the request and get the response.
    set response  = qsys2.http_post (
        url             => sqlr2r.ai_endpoint , -- from config, can be local or hosted
        options         => header , 
        request_message => payload
    );

    -- The format of the response is different between providers and models, so we need to extract the answer from the response.
    insert into  sqlr2r.trace (text) values(response);

    -- Use OLAP to wrangel the response, we need to do this because the format of the response is different between models and providers.
    -- For olama we can get the answer directly from $.message.content, but for open ai we need to extract the text from the output array.
    -- And we need one single text string, so we use listagg to concatenate the text from the output array into one string.  
    Select listagg (ifnull(content_text,'') , ' ') within group (order by ord)
        into answer
        from json_table (
            response ,
            'lax $.output[*].content[*]' 
            columns (             
                content_text  clob  path '$.text',
                ord for ordinality -- "ordinality" is a "build in". We need this to maintain the order of the text in the output array, otherwise we might get a jumbled answer
            )
        )
        where content_text is not null;

    if answer is null then
        insert into  sqlr2r.trace (text) values(response);
        return response; -- return the json with the error 
    end if; 

    return answer; 
    
end;    


-- test the function with a simple question, you can change the question and instructions as you like.
values sqlr2r.ask_ai  (
    question  => 'if a,b and c are cities. and i can drive from a to b and from b to c. Can i drive from a to c ?'
);

-- Now with instructions:
values sqlr2r.ask_ai  (
    instructions => 'Talk like a pirate',
    question  => 'tell a sailor joke'
);

-- So what do we have in our trace:
select * from sqlr2r.trace a order by rrn(a) desc ;


