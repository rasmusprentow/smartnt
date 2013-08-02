-module(tntns).
-export([add/1,has_changed/1,get_changed/1,process_records/1]).

%-include("records.hrl").

add(S) ->
	Doc = struct:get_value(<<"doc">>, S),
	Tntn = struct:get_value(<<"tntn">>,Doc),
	case dbase:fetch(Tntn) of 
		{ok,_} -> already_existed;
		_ -> dbase:save(Doc)
	end.

has_changed({struct,S}) ->
	Doc = struct:get_value(<<"doc">>, {struct,S}),
	Tntn = struct:get_value(<<"tntn">>,Doc),
	has_changed_internal(Tntn);
has_changed(Tntn) -> has_changed_internal(Tntn).

has_changed_internal(Tntn) ->
	io:format("~n Tntn: ~p ~n",[Tntn]),
	{ok, DDoc} = dbase:fetch(Tntn),
	%io:format("~n sfsfsfds "),
	{DbCount} = bson:lookup(count,DDoc),
	PostOfficeCount = postoffice:fetch_reg_count(Tntn),
	if DbCount =:= PostOfficeCount -> false;
		true -> case dbase:update(Tntn, PostOfficeCount) of
			true -> true;
			_ -> status_changed_bbut_new_status_was_not_updated 
		end
	end.
	
get_changed(S) ->
	TimeEpxired = bson:secs_to_unixtime(bson:unixtime_to_secs(bson:timenow()) - 1210600),
	AllRecords = dbase:fetch_all_record(TimeEpxired),
	process_records(AllRecords).

process_records([]) -> [];

process_records([H|T]) ->
	%io:format("~n Bson lookup ~p ~n",[[H] ++ T]),
	{Tntn} = bson:lookup(tntn,H),
	%io:format("~n has_changed(Tntn) ~p ~n", [has_changed(Tntn)]),
	
	HasChanged = has_changed(Tntn),
	io:format("~n HasChanged ~p ~n", [HasChanged]),
	Temp = case H of 
		%[] -> [];
		%{} -> [];
		_ -> case HasChanged of
			true -> [H];
			 _ -> []
		end
	end,
    io:format("~n has_changed(Tntn) ~p ~n", [Temp]),
	
	process_records(T) ++ Temp.
	
 	



%%
%% Tests
%%
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

has_changed_test() ->
     Data = {struct,[{<<"action">>,<<"add">>},                   
         {<<"doc">>,
          {struct,[{<<"tntn">>,<<"1234">>},
                   {<<"email">>,<<"somerandomemail@sss.dk">>},
                   {<<"count">>,0}]}}]},
    ?assertEqual(
       true,
       has_changed(Data),
    ok.


integration_test() ->
     Data = {struct,[{<<"action">>,<<"add">>},                   
         {<<"doc">>,
          {struct,[{<<"tntn">>,<<"1234">>},
                   {<<"email">>,<<"somerandomemail@sss.dk">>},
                   {<<"count">>,0}]}}]},
    add(Data),
    dbase:update(<<"1234">>,0),
    ?assertEqual(
       true,
       has_changed(Data),
     ?assertEqual(
       false,
       has_changed(Data),
    ok.


-endif.





%read_all(_S) -> 
%	%Notes = stickydb:read_all(note),
%	%lists:map(fun(F) -> {struct, [{<<"id">>, F#note.id}, {<<"doc">>, F#note.doc}]} end, Notes).
%	ok.
%
%create(S) ->
%	%Doc = struct:get_value(<<"doc">>, S),
%	%Id = stickydb:new_id(note),
%	%{atomic, ok} = stickydb:write({note, Id, Doc}),
%	%S1 = struct:set_value(<<"id">>, Id, S),
%	io:format("ahahah"),
%	[2].
%
%read(S) ->
%	Id = struct:get_value(<<"id">>, S),
%
%	case stickydb:read({note, Id}) of
%		[Doc] ->
%			{struct, [{<<"doc">>, Doc}]};
%		[] ->
%			{struct, [{<<"message">>, <<"note not found">>}]}
%	end.
%
%update(S) ->
%	Id = struct:get_value(<<"id">>, S),
%	Doc = struct:get_value(<<"doc">>, S),
%	{atomic, ok} = stickydb:write({note, Id, Doc}),
%	{struct, [{<<"message">>, ok}]}.
%
%delete(S) ->
%	Id = struct:get_value(<<"id">>, S),
%	{atomic, ok} = stickydb:delete({note, Id}),
%	{struct, [{<<"message">>, ok}]}.%