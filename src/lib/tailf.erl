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
        {Port, {data, {_EolFlag, Bin}}} ->
            Content = iolist_to_binary(Bin),
	    Callback(Content),
            loop(Port,Callback);
        {Port, {exit_status, Status}} ->
            {ok, Status};
        {Port, eof} -> 
            port_close(Port),
            {ok, eof};
        stop ->
	    port_close(Port),
	    {ok, stop};
        {'EXIT',Port,Reason} ->
            exit(port_terminated);
	_ANY ->
	    loop(Port,Callback)
    end.
