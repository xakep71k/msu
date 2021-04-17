program

function f1(): int
begin
    f1 := 1
end;

function f2(): int
begin
    f2 := 2
end;

var i: int;
begin
    writeln(f1());
    writeln(f2());
    writeln(f1() < f2());
    writeln(f1() > f2());
    writeln(f1() + f2());
    if (f1() < f2()) then begin
        writeln(222)
    end
end@
