%dbase.erl
%http://erlangx.tumblr.com/
%http://stackoverflow.com/questions/9095845/mongodb-erlang-erlang-driver-examples
-module(dbase).
-export([save/1,fetch/1,start/0,update/2,fetch_all_record/1]).
-include ("/usr/lib/erlang/lib/mongodb-master/include/mongo_protocol.hrl").


start() ->
    {ok, Conn} = mongo:connect(localhost),
    case mongo:do(safe, master, Conn, my_db, fun()->
        mongo:create_index(my_collection,{key,{tntn,1},unique,true,dropDups,true})  end) of
        {ok, _} -> true;   
        _else -> false
    end,
    mongo:disconnect(Conn).


% tntnum, items
save(Data) ->
 	  {ok, Conn} = mongo:connect(localhost),
    case mongo:do(safe, master, Conn, my_db, fun()->
        mongo:insert(my_collection, fix_data(munge(Data)) ) end) of
        {ok, _} -> true;   
        _else -> false
    end,
    mongo:disconnect(Conn).


update(Tntn,Count) ->
    {ok, Conn} = mongo:connect(localhost),
    case mongo:do(safe, master, Conn, my_db, fun()->
          mongo:modify(my_collection, {tntn,Tntn} ,{'$set', {count,Count},'$set', {updated,bson:timenow()}}) end) of
        {ok, _} -> true;
        _else -> false
    end.
  
fetch(Tntn) ->
    {ok, Conn} = mongo:connect(localhost),
    case mongo:do(safe, master, Conn, my_db, fun()->
        mongo:find_one(my_collection,{tntn,Tntn}) end) of
        {ok, Result} ->
            case Result of
                {Doc} -> {ok, Doc};
                {} -> false
            end;
        _else -> false
    end.


-type maybe(A) :: {A} | {}.
-spec fetch_all_record(bson:unixtime()) -> maybe(bson:document()).

fetch_all_record(UpdatedAfter) ->
    io:format("~n Timenow: ~p~n", [bson:unixtime_to_secs(bson:timenow())]),
    io:format("~n UpdatedAfter: ~p~n", [bson:unixtime_to_secs(UpdatedAfter)]),
    {ok, Conn} = mongo:connect(localhost),
    case mongo:do(safe, master, Conn, my_db, fun()->
         mongo:find(my_collection, {updated,{'$gt',UpdatedAfter}}) end) of
            {ok, Cursor} ->
               Results = process_cursor(Cursor),
               mongo:close_cursor(Cursor),
               Results;
            _ ->
               false
    end.


process_cursor(Cursor) ->
   process_cursor(Cursor, []).
process_cursor(Cursor, List) ->
   Record = mongo:next(Cursor),
   case Record of
      {} -> List;
      {Doc} -> process_cursor(Cursor, [Doc|List])
   end.
%process({}) ->
%    ok;
%process(Cursor) ->
%    io:format("----Cursor:~p~n", [Cursor]),
%    Record = mongo:next(Cursor),
%    io:format("Record:~p~n", [Record]),
%    case Cursor of
%        {} -> [Record];
%        _ -> Record ++ process(Cursor)
%    end. 
    
    
    



       
fix_data({struct, X}) -> 
    bson:append({updated,bson:timenow()},fix_data(X,{})).
fix_data([H|T],Doc) -> 
    bson:append(H,fix_data(T,Doc));
fix_data([],Doc) -> 
    Doc.

munge({struct,L}) ->
    {struct,[{list_to_atom(binary_to_list(I)), munge(J)} || {I,J}<-L]};
munge(L) when is_list(L) ->
    [munge(I) || I <- L];
munge(X) -> X.    
 

%%
%% Tests
%%
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

mochijson_test() ->
    Data = "{\"action\":\"add\",\"doc\":{\"tntn\":\"1234\",\"email\":\"somerandomemail@sss.dk\",\"count\":0}}",
    Expected = {struct,[{<<"action">>,<<"add">>},                   
         {<<"doc">>,
          {struct,[{<<"tntn">>,<<"1234">>},
                   {<<"email">>,<<"somerandomemail@sss.dk">>},
                   {<<"count">>,0}]}}]},
    ?assertEqual(
       Expected,
       mochijson2:decode(Data)),
    ok.

munge_and_fix_data_test() ->
   Data = {struct,[{<<"action">>,<<"add">>},                   
         {<<"doc">>,
          {struct,[{<<"tntn">>,<<"1234">>},
                   {<<"email">>,<<"somerandomemail@sss.dk">>},
                   {<<"count">>,0}]}}]},
    Expected = {tntn,<<"1234">>,email,<<"somerandomemail@sss.dk">>,count,0},
    io:format("~n Result: ~p~n",[fix_data(munge(struct:get_value(<<"doc">>,Data)))]),
    ?assertEqual(
       Expected,
       fix_data(munge(struct:get_value(<<"doc">>,Data)))),

    ok.

-endif.


%Data = {struct,[{<<"action">>,<<"add">>},{<<"doc">>,  {struct,[{<<"tntn">>,<<"1234">>},{<<"email">>,<<"somerandomemail@sss.dk">>},{<<"count">>,0}]}}]}.
