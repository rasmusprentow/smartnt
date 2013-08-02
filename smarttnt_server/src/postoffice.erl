%postoffice

-module(postoffice).

-export([fetch_reg_count/1,start/0]).

start() ->
	inets:start().

fetch_reg_count(Tn) ->
	{ok, {{Version, 200, ReasonPhrase}, Headers, Body}} =
      httpc:request(get, {"http://localhost/projects/smarttnt/tnt2.html", []}, [], []),
      %io:format("~p", [Body]),
      PdkTable = string:substr(Body,  string:rstr(Body, "pdkTable")),
      RegBody = string:substr(PdkTable,1,  string:str(PdkTable, "/table")),
      ListOfWords = string:tokens(RegBody, "<>"),
     % io:format("~nList ~p~n",[ListOfWords]),
      lists:foldl(
	      	fun(Elem,Count) -> case string:equal(Elem, "tr") of  
	      			true -> Count + 1;
	      			false -> Count 
	      		end
	      	end,
	      -1, ListOfWords).


%Registreringer