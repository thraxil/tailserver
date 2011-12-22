-module(tailserver_tail_controller, [Req]).
-compile(export_all).

hello('GET', []) ->
    {output,"Hello World"}.
