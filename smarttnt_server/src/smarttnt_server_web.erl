%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc Web server for smarttnt_server.

-module(smarttnt_server_web).
-author("Mochi Media <dev@mochimedia.com>").

-export([start/1, stop/0, loop/2]).

%% External API

start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req, DocRoot) ->
    "/" ++ Path = Req:get(path),
    io:format("Path Requested ~p ~n", [Path]),
    try
        case Req:get(method) of
            Method when Method =:= 'GET'; Method =:= 'HEAD' ->
                case Path of
                    _ ->
                        Req:serve_file(Path, DocRoot)
                end;
            'POST' ->
                case Path of
                  "tntns" ->
                      Data = Req:parse_post(),

                      Json = proplists:get_value("json", Data),
                      io:format("~n Raw: ~p~n", [Data]),
                      Struct = mochijson2:decode(Json),

                      io:format("~nStruct : ~p~n", [Struct]),
                      io:format("~nEncoded: ~p~n", [mochijson2:encode(Struct)]),
                       io:format("~nMunged: ~p~n", [munge(Struct)]),
                      
                      A = struct:get_value(<<"action">>, Struct),
                     %  io:format("~nAction : ~p~n", [binary_to_list(A)]),
                      Action = list_to_atom(binary_to_list(A)),
                      

                      Result = tntns:Action(Struct),

                      io:format("~nResult : ~p~n", [Result]),

                      DataOut = mochijson2:encode(Result),

                      Req:ok({"application/json", [], [DataOut]});

                    _ ->
                        Req:not_found()
                end;
            _ ->
                Req:respond({501, [], []})
        end
    catch
        Type:What ->
            Report = ["web request failed",
                      {path, Path},
                      {type, Type}, {what, What},
                      {trace, erlang:get_stacktrace()}],
            error_logger:error_report(Report),
            %% NOTE: mustache templates need \ because they are not awesome.
            Req:respond({500, [{"Content-Type", "text/plain"}],
                         "request failed, sorry\n"})
    end.

%% Internal API

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.

%%
%% Tests
%%
%-ifdef(TEST).
%-include_lib("eunit/include/eunit.hrl").
%
%you_should_write_a_test() ->
%    ?assertEqual(
%       "No, but I will!",
%       "Have you written any tests?"),
%    ok.
%
%-endif.




munge({struct,L}) ->
    {struct,[{list_to_atom(binary_to_list(I)), munge(J)} || {I,J}<-L]};
munge(L) when is_list(L) ->
    [munge(I) || I <- L];
munge(X) -> X.    
    