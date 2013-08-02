%mongo_test2.erl

-module(mongo_test2).
-export([tmp_test/0]).
-include ("/usr/lib/erlang/lib/mongodb-master/include/mongo_protocol.hrl").

tmp_test() ->
    application:start(mongodb),
    Host = {localhost, 27017},
    {ok, Conn} = mongo:connect(Host),
    io:format("Conn is : ~p~n", [Conn]),
    DbConn = {test, Conn},
    Cursor = mongo_query:find(DbConn, #'query'{collection=erltest, selector={x, {'$gt', 2}}}),
    process(Cursor),
    mongo:disconnect(Conn).

process({}) ->
    ok;
process(Cursor) ->
    io:format("----Cursor:~p~n", [Cursor]),
    Record = mongo:next(Cursor),
    io:format("Record:~p~n", [Record]),
    case Record of 
        {} ->
            no_more;
        _ ->        
            process(Cursor)
    end.