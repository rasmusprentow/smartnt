%dbase.erl
%http://erlangx.tumblr.com/
%http://stackoverflow.com/questions/9095845/mongodb-erlang-erlang-driver-examples
-module(dbase).
-export([save/2,fetch/1,start/0,stop/0]).
-include ("/usr/lib/erlang/lib/mongodb-master/include/mongo_protocol.hrl").

start() ->
	application:start(mongodb).

stop() -> 
	ok.
	


% tntnum, items
save(Tnum, Count) ->
	{ok, Conn} = mongo:connect(localhost),
    case mongo:do(safe, master, Conn, my_db, fun()->
        mongo:insert(my_collection, {tntn,Tnum,count,Count}) end) of
        {ok, _} -> true;   
        _else -> false
    end,
    mongo:disconnect(Conn).




fetch(Tnum) ->
    {ok, Conn} = mongo:connect(localhost),
    case mongo:do(safe, master, Conn, my_db, fun()->
        mongo:find_one(my_collection, {'tntn',Tnum}) end) of
        {ok, Result} ->
            case Result of
                {Doc} -> {ok, Doc};
                {} -> false
            end;
        _else -> false
    end.
   

    
    
