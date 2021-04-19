program

function num1(): int
begin
    num1 := 5
end;

function num2(): int
begin
    num2 := 10
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
            num1(),
            num2()
        )
    );
    writeln(
        andop(
            less(
                num1(),
                num2()
            ),
            more(4, 3)
        )
    );
    writeln(
        andop(
            less(
                num1(),
                num2()
            ),
            more(1, 2)
        )
    )
end@

