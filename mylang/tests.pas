program

function fff1(var k1, k2: bool): bool
begin
    writeln(k2);
    writeln(k1)
end;

function fff2(var k1, k2: bool): bool
begin
    fff1(k1, k2);
    writeln(k1);
    writeln(k2)
end;

var i: int;
begin
    i := 2;
    fff2(1<2, 4<3);
    writeln(i)

end@

