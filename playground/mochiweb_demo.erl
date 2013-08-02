-module(mochiweb_demo).
-export([mochiweb_request/1, start/1]).

start(Port) ->
    mochiweb_http:start([{port, Port}, {loop, {?MODULE, mochiweb_request}}]).

mochiweb_request(Req) ->
    Req:ok({"text/html",
    <<"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
        <html>
        <head><title >Welcome to mochiweb</title></head>
        <body>
            Hello
        </body>
        </html>">>}).