-module(tailserver_tail_controller, [Req]).
-compile(export_all).

hello('GET', []) ->
    TimeStamp = boss_mq:now("tail-channel"),
    {ok,[{timestamp, TimeStamp}]}.

pull('GET', [LastTimeStamp]) ->
    case boss_mq:pull("tail-channel", list_to_integer(LastTimeStamp)) of
	{ok, Timestamp, Lines} ->
	    {json, [{timestamp, Timestamp}, {lines, Lines}]};
	{error, Reason} ->
	    io:format("error: ~p~n",[Reason]),
	    {output,Reason};
	Other ->
	    io:format("unexpected: ~p~n",[Other])
    end.




