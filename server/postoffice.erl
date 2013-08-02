%postoffice

-module(postoffice).

-export([fetch/1,start/0]).

start() ->
	inets:start().

fetch(Tn) ->
	{ok, {{Version, 200, ReasonPhrase}, Headers, Body}} =
      httpc:request(get, {"http://www.erlang.org", []}, [], []),
      io:format("~p", Body).