program
var i: int;
begin

i := 1;
case(i) of
    2,1,3: begin

        case(i) of
            2,1,3: begin

                case(2+2) of
                    2,1,3: begin
                        writeln(0)
                    end
                    4: begin
                        writeln(44)
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
