program

function num1(var i: int): int
begin
    num1 := i
end;

function num2(var i: int): int
begin
    num2 := i
end;

function plus(var i1, i2: int): int
begin
    plus := i1 + i2
end;

function less(var i1, i2: int): bool
begin
    less := i1 < i2
end;

function more(var i1, i2: int): bool
begin
    more := i1 > i2
end;

function andop(var i1, i2: bool): bool
begin
    andop := i1 and i2
end;


begin
    writeln(
        plus(
            num1(5),
            num2(10)
        )
    );
    writeln(
        andop(
            less(
                num1(5),
                num2(10)
            ),
            more(4, 3)
        )
    );
    writeln(
        andop(
            less(
                num1(5),
                num2(10)
            ),
            more(1, 2)
        )
    )
end@

