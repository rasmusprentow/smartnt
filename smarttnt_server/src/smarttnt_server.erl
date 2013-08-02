%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc smarttnt_server.

-module(smarttnt_server).
-author("Mochi Media <dev@mochimedia.com>").
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.


%% @spec start() -> ok
%% @doc Start the smarttnt_server server.
start() ->
    smarttnt_server_deps:ensure(),
    ensure_started(crypto),
    ensure_started(mongodb),
    ensure_started(inets),
    application:start(smarttnt_server).


%% @spec stop() -> ok
%% @doc Stop the smarttnt_server server.
stop() ->
    application:stop(smarttnt_server).
