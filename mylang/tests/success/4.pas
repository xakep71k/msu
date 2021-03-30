program
var i: int;
begin

i := 5;
case((1 = 2) or (2 = 3) or (i = 5)) of
    false: begin
        writeln(99)
    end
    true: begin
        writeln(55)
    end
end

end@


