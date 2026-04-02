# display solution
writeMatchInfo(ResidentID, ProgramID) :-
    resident(ResidentID, name(FN,LN), _),
    program(ProgramID, TT, _, _), write(LN), write(','),
    write(FN), write(','), write(ResidentID), write(','),
    write(ProgramID), write(','), writeln(TT).

# computes the rank of a resident in program's rol
rankInProgram(ResidentID, ProgramID, Rank) :-

# find least preferred resident in program's list
leastPreferred(ProgramID, ResidentIDsList, LeastPreferredResidentID, RankOfThisResident) :-

# checks if a resident is matched
matched(ResidentID, ProgramID, Matcheset) :-

# assign a program to the resident
offer(ResidentID, currentMatchset, newMatchset) :-

# helper to match one resident with one program
offer(ResidentID, ProgramID) :-