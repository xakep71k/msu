program

function less1(var i, j: int): bool
begin
    function less2(var i, j: int): bool
    begin
        less2 := i < j
    end;
    writeln(123)
end;

begin
    writeln(less1(1,2))
end@

