%% @author Mochi Media <dev@mochimedia.com>
%% @copyright smarttnt_server Mochi Media <dev@mochimedia.com>

%% @doc Callbacks for the smarttnt_server application.

-module(smarttnt_server_app).
-author("Mochi Media <dev@mochimedia.com>").

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for smarttnt_server.
start(_Type, _StartArgs) ->
    smarttnt_server_deps:ensure(),
    smarttnt_server_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for smarttnt_server.
stop(_State) ->
    ok.
