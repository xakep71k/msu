program

function less(var i, j: int): bool
begin
    less := i < j
end;

begin
    writeln(less(1, 2));
    writeln(less(2, 1))
end@
