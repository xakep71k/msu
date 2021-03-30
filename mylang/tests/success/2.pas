program
var b: bool;
begin

b := false;
case(b) of
    true: begin
        writeln(99)
    end
    false: begin
        case(1 < 2) of
            true: begin
                writeln(12)
            end
            false: begin
                writeln(66)
            end
        end;
        writeln(55)
    end
end

end@
