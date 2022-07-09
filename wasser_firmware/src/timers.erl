%%%-------------------------------------------------------------------
%%% @author Dieter Schoen <dieter@schoen.or.at>
%%% @copyright (C) 2022, Dieter Schoen
%%% @doc
%%%
%%% @end
%%% Created : 25 Jun 2022 by Dieter Schoen <dieter@schoen.or.at>
%%%-------------------------------------------------------------------
-module(timers).

%% API
-export([jobdef_to_monotime/2,
         when_timer/2,
         start_timers/3,
         clear_timers/2,
         set_timer_plus24/3,
         read_timer/1,
         start_receiver/0,
         show_diff/1,

         sa/0,

         hms_to_seconds/1,
         seconds_to_hms/1]).


-define(PRECISION, millisecond).
-define(ONE_DAY, 1000*3600*24).

jobdef_to_monotime({H, M, S}, {DurH, DurM, DurS}) ->
    NOW = erlang:monotonic_time(millisecond),
    {Hour, Min, Sec} = erlang:time(),
    TimerSec   = hms_to_milliseconds(H, M, S),
    NowSec = hms_to_milliseconds(Hour, Min, Sec),
    EndSec = TimerSec + hms_to_milliseconds(DurH, DurM, DurS) ,

    Tstart = NOW + TimerSec - NowSec,
    Tstop  = NOW + EndSec - NowSec,

    show_diff({Tstart, Tstop}),
    {Tstart, Tstop}.

show_diff({T0, T1}) ->
    NOW = erlang:monotonic_time(millisecond),

    io:format("NOW ~p~n", [NOW]),
    io:format("T0  ~p ~p~n", [T0, T0 - NOW]),
    io:format("T1  ~p ~p~n", [T1, T1 - NOW]).
    
hms_to_milliseconds(H, M, S) ->
    1000 * (H * 3600 + M * 60 + S).
    
when_timer({_Tstart, Tstop}, Tnow) when Tstop < Tnow ->
    past;
when_timer({Tstart, _Tstop}, Tnow) when Tstart > Tnow ->
    future;
when_timer(_, _) ->
    now.

start_receiver() ->
    spawn(fun R() -> 
                  receive 
                      quit ->
                          io:format("received QUIT~n", []),
                          ok;
                      {msg, Delta, Time} -> 
                          io:format("received ~p delta: ~p ~n", 
                                    [Delta, erlang:system_time(millisecond) - Time]),
                          R();
                      X -> 
                          io:format("received ~p @ ~p ~n", [X, 
                                                            erlang:system_time(millisecond)]),
                          R()
                  end
          end). 

sa() ->
    P = start_receiver(),
    lists:foreach(fun (X) ->
                         erlang:send_after(X, P, {msg, X, erlang:system_time(millisecond)}), 
                         timer:sleep(200)
                  end,
                  [1000,2000,3000,4000,3000,2000,1000]),
    erlang:send_after(4500, P, quit).

start_timers(Pid, {T0, T1}, {Msg0, Msg1}) ->
    Tnow = erlang:monotonic_time(millisecond),
    case when_timer({T0, T1}, Tnow) of
        past ->
            logger:info("past"),
            Ref1 = erlang:start_timer(T0 + ?ONE_DAY, Pid, Msg0, [{abs, true}]), 
            Ref2 = erlang:start_timer(T1 + ?ONE_DAY, Pid, Msg1, [{abs, true}]),
            {Ref1, Ref2};
        now ->
            logger:info("now"),
            Pid ! Msg0,
            Ref2 = erlang:start_timer(T1, Pid, Msg1, [{abs, true}]),
            {none, Ref2};
        future ->
            logger:info("future"),
            Ref1 = erlang:start_timer(T0, Pid, Msg0, [{abs, true}]), 
            Ref2 = erlang:start_timer(T1, Pid, Msg1, [{abs, true}]),
            {Ref1, Ref2}
    end.

set_timer_plus24(Pid, T, Msg) ->
    Tnew = T + ?ONE_DAY,
    %% return Ref
    erlang:start_timer(Tnew, Pid, {Msg, Tnew}, [{abs, true}]).


hms_to_seconds({H,M,S}) ->
    H * 3600 + M * 60 + S.
seconds_to_hms(Sec) ->
    H = Sec div 3600,
    M = (Sec - H * 3600) div 60,
    S = Sec - H * 3600 - M * 60,
    {H,M,S}.
    
read_timer(Ref) when is_reference(Ref)->
    erlang:read_timer(Ref) div 1000;
read_timer(none) ->
    none.

clear_timers(Tstart, Tstop) ->
    erlang:cancel_timer(Tstart),
    erlang:cancel_timer(Tstop).
