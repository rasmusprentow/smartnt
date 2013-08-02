
-module(mongosave).

-export([save/1]).

save(A) ->
	{ok, Conn} = mongo:connect(localhost),
	mongo:do (safe, master, Conn, test, fun() ->
    	mongo:delete (foo, {}),
    	mongo:insert (foo, {x,1}),
    	mongo:find (foo, {x,1}) end).