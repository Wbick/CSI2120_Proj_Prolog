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

%computes the rank of a resident in program's rol
rankInProgram(ResidentID, ProgramID, Rank) :-
    program(ProgramID, _, _, ROL),
    position(ResidentID, ROL, Rank).

%base case, if resident is in first position
position(X, [X|_], 1).
%recursively find resident's rank in program rol
position(X, [_|T], N) :-
    position(X, T, N1),
    N is N1 + 1.


% find least preferred resident in program's list
%-----------------------
%not sure if correct
%-----------------------
leastPreferred(ProgramID, ResidentIDsList, LeastPreferredResidentID, RankOfThisResident) :-
    program(ProgramID, _, _, ROL),
    findall(Rank, (rankInProgram(ResidentID, ProgramID, Rank)), Ranks),
    max_list(Ranks, RankOfThisResident),
    position(LeastPreferredResidentID, ROL, RankofThisResident).

    

%checks if a resident is matched
matched(ResidentID, ProgramID, Matchset) :-
    member(match(ProgramID, Residents), Matchset),
    member(ResidentID, Residents).

% assign a program to the resident
offer(ResidentID, currentMatchset, newMatchset) :-

% helper to match one resident with one program
offer(ResidentID, ProgramID) :-