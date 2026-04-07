% high-level gale_shapley/0
gale_shapely :-
    initialMs(InitialMatchSet),
    stable_loop(InitialMatchSet, FinalMatchSet),
    write_solution(FinalMatchSet).

% display solution
writeMatchInfo(ResidentID, ProgramID) :-
    resident(ResidentID, name(FN,LN), _),
    program(ProgramID, TT, _, _), write(LN), write(','),
    write(FN), write(','), write(ResidentID), write(','),
    write(ProgramID), write(','), writeln(TT).

initialMs(Ms) :-
    findall(match(P,[]), program(P,_,_,_), Ms).

% computes the rank of a resident in programs rol
rankInProgram(ResidentID, ProgramID, Rank) :-
    program(ProgramID, _, _, ROL),
    position(ResidentID, ROL, Rank).

% resident is in first position
position(X, [X|_], 1).

% recursively find residents rank in program rol
position(X, [_|T], N) :-
    position(X, T, N1),
    N is N1 + 1.

% list has one resident
leastPreferred(ProgramID, [ResidentID], ResidentID, Rank) :-
    rankInProgram(ResidentID, ProgramID, Rank).

% find least preferred resident in programs list
leastPreferred(ProgramID, [H|T], LeastPreferredResidentID, RankOfThisResident) :-
    leastPreferred(ProgramID, T, TWorstResident, TWorstRank),
    rankInProgram(H, ProgramID, HRank),
    (
        HRank > TWorstRank ->
        LeastPreferredResidentID = H,
        RankOfThisResident = HRank
    ;
        LeastPreferredResidentID = TWorstResident,
        RankOfThisResident = TWorstRank
    ).

% checks if a resident is matched
matched(ResidentID, ProgramID, Matchset) :-
    member(match(ProgramID, Residents), Matchset),
    member(ResidentID, Residents).

% do nothing if matched already
offer(ResidentID, MatchSet, MatchSet) :-
    matched(ResidentID, _, MatchSet),!.

% assign a program to the resident
offer(ResidentID, CurrentMatchset, NewMatchset) :-
    resident (ResidentID, _, Preferences),
    offer_preferences(ResidentID, Preferences, CurrentMatchset, NewMatchset).

% no program works so matchset stays the same
offer_preferences(_, [], MatchSet, MatchSet).

% first preferred program
offer_preferences(ResidentID, [ProgramID|_], CurrentMatchset, NewMatchset) :-
    offer_res_to_prog(ResidentID, ProgramID, CurrentMatchset, NewMatchset), !.

offer_preferences(ResidentID, [_|Rest], CurrentMatchset, NewMatchset) :-
    offer_preferences(ResidentID, Rest, CurrentMatchset, NewMatchset).

    
% helper to match one resident with one program
offer_res_to_prog(ResidentID, ProgramID, CurrentMatchset, NewMatchset) :-
    rankInProgram(ResidentID, ProgramID, _),
    member(match(ProgramID, Residents), CurrentMatchset),
    program(ProgramID, _, Capacity, _),
    length(Residents, NumberOfResidents),
    length_compare_capacity(Capacity, NumberOfResidents, Residents, ResidentID, ProgramID, CurrentMatchset, NewMatchset).

%case one number of residents is less than capacity, add resident to program
length_compare_capacity(Capacity, NumberOfResidents, Residents, ResidentID, ProgramID, CurrentMatchset, NewMatchset) :-
    NumberOfResidents < Capacity,
    append(Residents, [ResidentID], NewResidents),
    select(match(ProgramID, Residents), CurrentMatchset, match(ProgramID, NewResidents), NewMatchset).

%case two number of residents is greater than or equal to capacity,
%check if resident is more preferred than least preferred resident,
%if so replace least preferred resident with new resident
length_compare_capacity(Capacity, NumberOfResidents, Residents, ResidentID, ProgramID, CurrentMatchset, NewMatchset) :-
    NumberOfResidents >= Capacity,
    leastPreferred(ProgramID, Residents, LeastPreferredResidentID, RankOfLeastPreferredResident),
    rankInProgram(ResidentID, ProgramID, ResidentRank),
    ResidentRank < RankOfLeastPreferredResident,
    select(LeastPreferredResidentID, Residents, RemainingResidents),
    append(RemainingResidents, [ResidentID], NewResidents),
    select(match(ProgramID, Residents), CurrentMatchset, match(ProgramID, NewResidents), NewMatchset).

% go through every resident and offer
offer_all([], MatchSet, MatchSet).

offer_all([ResidentID|Rest], CurrentMatchSet, NewMatchSet) :-
    offer(ResidentID, CurrentMatchSet, UpdatedMatchSet),
    offer_all(Rest, UpdatedMatchSet, NewMatchSet).

% offer all residents until matchset stays the same
stable_loop(CurrentMatchSet, FinalMatchSet) :-
    findall(ResidentID, resident(ResidentID, _, _), Residents),
    offer_all(Residents, CurrentMatchSet, NewMatchSet),
    (
        NewMatchSet == CurrentMatchSet ->
        FinalMatchSet = CurrentMatchSet
    ;
        stable_loop(NewMatchSet, FinalMatchSet)
    ).

% print all residents, either matched or unmatched
print_all_residents(FinalMatchset) :-
    forall(
        resident(ResidentID, name(FN, LN), _),
        (
            (
                matched(ResidentID, ProgramID, FinalMatchset) ->
                writeMatchInfo(ResidentID, ProgramID)
            ;
                write(LN), write(','),
                write(FN), write(','),
                write(ResidentID), write(','),
                write('XXX'), write(','),
                writeln('NOT_MATCHED')
            )
        )
    ).

% count all residents who arent matched
count_unmatched(FinalMatchset, Count) :-
    findall(ResidentID,
        (
            resident(ResidentID, _, _),
            \+ matched(ResidentID, _, FinalMatchset)
        ),
        UnmatchedResidents),
    length(UnmatchedResidents, Count).

program_open_positions(FinalMatchset, Count) :-
    findall(OpenPositions,
        (
            program(ProgramID, _, Capacity, _),
            member(match(ProgramID, Residents), FinalMatchset),
            length(Residents, NumberOfResidents),
            OpenPositions is Capacity - NumberOfResidents
        ),
        OpenCount),
    sum_list(OpenCount, Count).