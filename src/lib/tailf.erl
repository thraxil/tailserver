-module(tailf).
-export([init/1,start/1,start/0,stop/0]).

start() ->
    start(fun info_display/1).
start(Callback) ->
    spawn_link(?MODULE,init,[Callback]).

stop() ->
    tailf ! stop.

init(Callback) ->
    register(tailf,self()),
    Cmd = "tail -f /home/anders/watchfile.txt",
    Port = open_port({spawn, Cmd}, [stderr_to_stdout, {line, 1024}, exit_status]),
    loop(Port,Callback).

info_display(Content) ->
    io:format("[info] ~s~n",[Content]).

loop(Port,Callback) ->
    receive
        {Port, {data, {eol, Bin}}} ->
            Content = iolist_to_binary(Bin),
	    Callback(Content),
            loop(Port,Callback);
%%        {Port, {exit_status, Status}} ->
%%	    io:format("got exit_status message ~p~n",[Status]),
%%            {ok, Status};
%%        {Port, eof} -> 
%%	    io:format("got eof message~n"),
%%            port_close(Port),
%%            {ok, eof};
        stop ->
            Port ! {self(), close},
            receive
                {Port, closed} ->
                    exit(normal)
            end
%%        {'EXIT',Port,Reason} ->
%%	    io:format("terminated ~p~n",[Reason]),
%%            exit(port_terminated);
%%	_ANY_ ->
%%	    io:format("got something unexpected~n")
    end.
