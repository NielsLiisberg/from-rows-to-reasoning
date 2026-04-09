create or replace function sqlr2r.capitalize (
   name varchar(256)
)  
returns varchar(256)
    no external action 
    deterministic 
    specific CAPITAL
    set option output=*print, commit=*none, dbgview = *source
begin
    declare temp varchar(256); 
    declare outString varchar(256); 
    declare i int;
    declare upperNext int;
    declare c char(1); 
    
    set temp = lower(name);
    set i = 1;
    set upperNext = 1;
    set outString = '';
    while i <=  length(temp) do 
       set c = substr(temp , i ,1);
       if c = ' ' then 
           set upperNext = 1;
       elseif upperNext = 1 then  
           set c  = upper(c);
           set upperNext = 0;
       end if;
       set outString = outString || c;
       set i = i +1;
    end while;   
    return outString;
end;

-- usecase 
values sqlr2r.capitalize('JOHN A JOHNSON');
values sqlr2r.capitalize('john a johnson');
values sqlr2r.capitalize('');
