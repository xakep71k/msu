program

function recursion(var i: int): int
begin
    if (i <= 1) then begin
        recursion := i
    end else begin
        recursion := recursion(i - 1) + recursion(i - 2)
    end
end;

var i: int;
begin
    read(i);
    recursion(i);
    writeln(recursion(i))
end@

