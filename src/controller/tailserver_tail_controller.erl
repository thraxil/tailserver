-module(tailserver_tail_controller, [Req]).
-compile(export_all).

hello('GET', []) ->
    TimeStamp = boss_mq:now("tail-channel"),
    {ok,[{timestamp, TimeStamp}]}.

pull('GET', [LastTimeStamp]) ->
    {ok, Timestamp, Lines} = boss_mq:pull("tail-channel", list_to_integer(LastTimeStamp)),
    io:format("got ~p~n",[Lines]),
    {json, [{timestamp, Timestamp}, {lines, Lines}]}.


