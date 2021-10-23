-module(solution).

-export([chunks/2, start/0]).

read_input() -> read_input([]).

read_input(Lst) ->
    case io:fread("", "~d") of
        {ok, N} -> read_input(Lst ++ N);
        _ -> Lst
    end.

chunks([Hd | Tail], N) ->
    case chunks(Tail, N) of
        [Cur | Rest] when length(Cur) < N ->
            [[Hd | Cur] | Rest];
        [Cur | Rest] -> [[Hd], Cur | Rest]
    end;
chunks([], _) -> [[]].

transpose([[A, B, C], [D, E, F], [G, H, I]]) ->
    [[A, D, G], [B, E, H], [C, F, I]].

is_triangle([A, B, C]) ->
    (A < B + C) and (B < A + C) and (C < A + B);
is_triangle(_) -> false.

identity(A) -> A.

solve_a(Input) ->
    Sets = chunks(Input, 3),
    Triangles = lists:filter(fun is_triangle/1, Sets),
    length(Triangles).

solve_b(Input) ->
    Sets = chunks(Input, 3),
    GroupedSets = chunks(Sets, 3),
    TransposedGroups = lists:map(fun transpose/1,
                                 GroupedSets),
    TransposedSets = lists:flatmap(fun identity/1,
                                   TransposedGroups),
    Triangles = lists:filter(fun is_triangle/1,
                             TransposedSets),
    length(Triangles).

start() ->
    Input = read_input(),
    io:write(solve_a(Input)),
    io:nl(),
    io:write(solve_b(Input)),
    io:nl().
