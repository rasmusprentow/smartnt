#!/bin/sh
# NOTE: mustache templates need \ because they are not awesome.
exec erl -pa ebin edit deps/*/ebin -boot start_sasl \
    -sname smarttnt_server_dev \
    -s smarttnt_server \
    -s reloader
