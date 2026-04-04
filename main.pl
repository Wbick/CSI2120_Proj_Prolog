% match set looks like:
% [
%   match(nrs, [517,574]),
%   match(obg, [616])
% ]

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

% assign a program to the resident
offer(ResidentID, currentMatchset, newMatchset) :-

% helper to match one resident with one program
offer(ResidentID, ProgramID) :-