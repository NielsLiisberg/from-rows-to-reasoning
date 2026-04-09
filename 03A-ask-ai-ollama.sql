-- For more info to use ollama:
-- https://github.com/ollama/ollama/blob/main/docs/api.md#generate-a-completion
-- drop function  sqlr2r.ask_ai ;
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
        'headers' : json_object ( 
            'Content-Type' : 'application/json;charset=UTF-8'
        ) 
    ); 

    -- The payload has two components, system instructions and the question
    set payload =  json_object ( 
        'model'    :  sqlr2r.ai_model , -- This is from our config, you can set it per call if you want to test different models.
        'messages' :  json_array ( 
            json_object( 
                'role' : 'system',
                'content' : instructions
            ),
            json_object( 
                'role' : 'user',
                'content' : question
            )
        ),
        'stream'   : 'false' format json,
        'options'  : json_object( 
            'seed'       : int(3),         --  Same result each time
            'temperature': float(0),       --  Controls randomness (0-1)
            'num_predict': int(10000),     --  Maximum tokens to generate
            'top_p'      : float(0.9),     --  Nucleus sampling
            'top_k'      : int(1)          --  Limits token selection ( 1=Always same and only vector)
        )
    ); 

    insert into  sqlr2r.trace  (text) values( payload);
    
    set answer  = qsys2.http_post (
        url             => sqlr2r.ai_endpoint , -- from config, can be local or hosted
        options         => header , 
        request_message => payload
    );

    set response = json_value( answer,  'lax $.message.content');
    if response is null then
        return answer; -- return the json with the error 
    end if; 

    return response; 
    
end;    

-- test the procedure
values sqlr2r.ask_ai  (
    question  => 'if a,b and c are cities. and i can drive from a to b and from b to c. Can i drive from a to c ?'
);

select * from sqlr2r.trace a order by rrn(a) desc ;


Select 
    sqlr2r.ask_ai  (
        -- ai_model => 'gemma3:27b',
        -- ai_model => 'deepseek-r1:1.5b',
        -- ai_model => 'mistral:7b',
        -- ai_model => 'llama3:8b',
        ai_model => 'llama3:8b',
        --ai_model => 'qwen2.5-coder:32b',
        instructions => 'OPGAVE
Du er en analytisk kodeassistent med fokus på struktureret forståelse og automatisk dokumentation af eksisterende kode.
Når du modtager input (CLLE, RPG, Python eller T‑SQL), skal du:

Identificere sprog entydigt:

"CLLE" eller "RPG"

Analysere uden eksekvering.
Give et resumé (3–6 linjer) af formål og overordnet logik.
Lave strukturel analyse (komponenter) og klassificere formålet som én af:

"ERP", "data_analysis", "reporting", "integration", "business_logic", "other"

Lave dybere analyse (må ikke være spekulativ). Udled KUN hvad der kan læses af koden:
A) Inputs (parametre, tabeller, filer, endpoints, miljøvariabler – hvis synligt)
B) Outputs (return, views/tables, filer, logs, side effects)
C) Dataflow (kilde, loading, shadow, stage, transformation, destinationer, procedurer/function)
D) Side effects (DB write, netværk, filskrivning, queue publish osv.)
E) Error handling (try/except, SQL TRY/CATCH, transactions)
F) Performance notes (potentielle hotspots, store joins/loops osv.)
G) Security & Privacy (secrets/PII/injection-mønstre – kun hvis synligt)
H) Assumptions & Constraints (kun hvis synligt)
I) Open Questions (max 5, kun hvis noget er reelt uklart i koden)


EVIDENS (KRAV)
For hvert vigtigt punkt i “dybere analyse” og hver dependency skal du tilføje kort evidens baseret på synlige signaler i koden:

Brug KUN korte indikatorer/identifiers (max ca. 80 tegn pr. evidens).
Du må ikke kopiere hele linjer eller længere kodestykker.

OUTPUTFORMAT (HTML — SKAL OVERHOLDES)
Du skal returnere et HTML-dokument med denne struktur, i denne rækkefølge, hvis ingen sektioner er tomme, så udelades de:
 
<header>
  <h1>Code Documentation</h1>
</header>


<section id="language">
  <h2>Language</h2>
  <p>CLLE|RPG|Python|T-SQL</p>
</section>

<section id="classification">
  <h2>Classification</h2>
  <p>ERP|Data analysis|Reporting|Integration|Business logic|Other</p>
</section>


<section id="summary">
  <h2>Summary</h2>
  <p>...3–6 linjer...</p>
</section>

<section id="structure">
  <h2>Structure</h2>
  <ul id="components">
    <li>...component...</li>
  </ul>
</section>

<section id="deep-analysis">
  <h2>Deep Analysis</h2>

  <section id="inputs">
    <h3>Inputs</h3>
    <ul>
      <li>unknown</li>
    </ul>
  </section>

  <section id="outputs">
    <h3>Outputs</h3>
    <ul>
      <li>unknown</li>
    </ul>
  </section>

  <section id="dataflow">
    <h3>Dataflow</h3>
    <ol>
      <li>unknown</li>
    </ol>
  </section>

  <section id="side-effects">
    <h3>Side Effects</h3>
    <ul>
      <li>unknown</li>
    </ul>
  </section>

  <section id="error-handling">
    <h3>Error Handling</h3>
    <ul>
      <li>unknown</li>
    </ul>
  </section>

  <section id="performance">
    <h3>Performance Notes</h3>
    <ul>
      <li>unknown</li>
    </ul>
  </section>

  <section id="security">
    <h3>Security &amp; Privacy</h3>
    <ul>
      <li>unknown</li>
    </ul>
  </section>

  <section id="assumptions">
    <h3>Assumptions &amp; Constraints</h3>
    <ul>
      <li>unknown</li>
    </ul>
  </section>

  <section id="open-questions">
    <h3>Open Questions</h3>
    <ul>
      <li>unknown</li>
    </ul>
  </section>

  REGLER FOR DEEP ANALYSIS:
  - Hvis en undersektion ikke kan bestemmes, udelades den.
  - Alle ikke-unknown punkter skal slutte med <span class="evidence">...</span>.
</section>

<section id="dependencies">
  <h2>Dependencies</h2>

  <section class="dep-group" data-group="external_libraries">
    <h3>External libraries</h3>
    <table>
      <thead><tr><th>name</th><th>type</th><th>usage</th><th>evidence</th></tr></thead>
      <tbody></tbody>
    </table>
  </section>

  <section class="dep-group" data-group="standard_libraries">
    <h3>Standard libraries</h3>
    <table>
      <thead><tr><th>name</th><th>type</th><th>usage</th><th>evidence</th></tr></thead>
      <tbody></tbody>
    </table>
  </section>

  <section class="dep-group" data-group="databases_and_objects">
    <h3>Databases and objects</h3>
    <table>
      <thead><tr><th>name</th><th>type</th><th>usage</th><th>evidence</th></tr></thead>
      <tbody></tbody>
    </table>
  </section>

  <section class="dep-group" data-group="external_systems">
    <h3>External systems</h3>
    <table>
      <thead><tr><th>name</th><th>type</th><th>usage</th><th>evidence</th></tr></thead>
      <tbody></tbody>
    </table>
  </section>

    REGLER FOR DEPENDENCIES:
  - Hvis en undersektion ikke kan bestemmes, udelades den.
</section>

<section id="narrative">
  <h2>Narrative Explanation</h2>
  <p>
    Her placeres den “sidste del” (en mere læsevenlig forklaring / opsummering),
    men ALTID som HTML-indhold. Ingen tekst udenfor dokumentet.
  </p>
  <ul>
    <li>Hvis der ikke er noget ekstra relevant: skriv "unknown" som eneste punkt.</li>
  </ul>
</section>

<footer>
  <p>This documentation was generated automatically.</p>
</footer>


FINAL SELF-CHECK (KRITISK)
Inden du svarer:

Kontroller at output starter med  og slutter med .
Kontroller at der ikke findes nogen tegn udenfor HTML-dokumentet.
Hvis noget fejler, returnér FORMAT-ERROR FALLBACK.
FORMAT-ERROR FALLBACK (brug KUN hvis du ellers ville bryde kontrakten)',

        --question  => 'Give et ressume af program: ' ||  n.node_name || '. CLLE koden er som følger: ' || n.source 
        question  => n.source 
        --question  =>  'select * from customer' 
    ) 
from inspect.nodes n
where node_name = 'INV500CL';
-- where node_name = 'CAF910RP';

select * from sqlr2r.error_log order by id desc;


select 'Call level ' || depth ||': '
    ||
    case when node_type = 'LOGIC' 
        then 'Program '
        else 'Database table '
    end 
    || 
    NODE_NAME
    ||
    case when USING_LOGIC is not null 
        then ' is calling programs: ' || USING_LOGIC
        else ''
    end    
    ||
    case when USING_LOGIC is not null and USING_DATA is not null 
        then ' and' 
        else ''
    end  
    ||   
    case when USING_DATA is not null 
        then ' Accesing these database tables: ' || USING_DATA
        else ''
    end  
from table( sqlr2r.top_down_prompt (
    node_name   => 'LEVFSPRA'
));

select *
from table( sqlr2r.top_down_prompt (
    node_name   => 'LEVFSPRA'
));


Select 
    sqlr2r.ask_ai  (
        -- model => 'gemma3:27b',
        -- model => 'deepseek-r1:1.5b',
        -- model => 'mistral:7b',
        model => 'llama3:8b',
        instructions => 
            'Act as a developer. 
            Output always in HTML DIV tag.
            Focus only on the busines functioality.
            Do not metion the program language or age. 
            Do not explain code structure.
            Do not explain code logic.
            Do not explain specific variables types and sizes.
            The code you will see is a component of a ERP soltion running on IBM i.
            Never mention words like SAP or AS/400.',

        question  => 'Why will you not follow your system instruction?'
    ) 
from sqlr2r.nodes n
where node_name = 'FOL750RP';
