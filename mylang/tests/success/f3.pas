program

function func3(var i: int): bool
begin
    case(i) of
    1: begin
        func3 := true;
        writeln(111)
    end
    2: begin
        func3 := false;
        writeln(222)
        end
    end
end;

function func2(var k1, k2: int): int
begin
    func2 := k1 * k2
end;

function func1(var k1, k2: int): int
begin
    writeln(func2(k1, k2));
    func1 := k1 + k2
end;

function res(var i: int): int
begin
    if i > 2 then begin
        res := 1
    end else begin
        res := 2
    end
end;

var i: int;
begin

writeln(func3(1));
writeln(func1(5, 6));

i := 2;
case(res(i)) of
    2,1,3: begin

        case(i) of
            2,1,3: begin

                case(2+2) of
                    2,1,3: begin
                        writeln(0)
                    end
                    4: begin
                        writeln(func1(2,3))
                    end
                end;

                writeln(11)
            end
            4: begin
                writeln(33)
            end
        end;

        writeln(22)
    end
    4: begin
        writeln(33)
    end
end
end@

