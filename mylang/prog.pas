program
var f0, f1, fi, k, i: int, b: bool;
begin

i := 1;
case(i) of
    2,1,3: begin
        writeln(22)
    end
    4: begin
        writeln(33)
    end
end;

b := false;
case(b) of
    true: begin
        writeln(44)
    end
    false: begin
        writeln(55)
    end
end;

f0 := 0;
f1 := 1;
k := 2;
read(i);
fi := i;

if(i > 1) then begin
    while(k <= i) do begin
        fi := f0 + f1;
        f0 := f1;
        f1 := fi;
        k := k + 1
    end
end;

writeln(fi)

end@
