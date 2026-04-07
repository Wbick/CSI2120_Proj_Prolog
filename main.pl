% match set looks like:
% [
%   match(nrs, [517,574]),
%   match(obg, [616])
% ]

%TEMP FOR TESTING PURPOSES
%--------------------------------------------------------
resident(574, name(salvatore,williams), [nrs,hep,mmi]).
resident(517, name(rosalie,frederick), [nrs,mmi]).
resident(126, name(indie,medrano), [mmi,nrs]).
resident(828, name(emma,tremmo), [obg,nrs]).
resident(403, name(aspyn,olson), [hep,nrs]).
resident(226, name(zev,jarvis), [mmi,hep,nrs]).
resident(913, name(camille,paquet), [obg,mmi,hep]).
resident(773, name(marie,clown), [obg]).
resident(616, name(laurent,robert), [obg,mmi,hep,nrs]).
resident(377, name(tom,tan), [mmi,obg]).
program(nrs, "Neurosurgery",4, [574,517,403,828,226,126]).
program(obg, "Obstetrics and Gynecology",3, [616,828,773,913]).
program(mmi, "Microbiology",1, [574,517,226,913,377,126]).
program(hep, "Hematological Pathology",2, [403,574,913,616,226]).
%--------------------------------------------------------


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
