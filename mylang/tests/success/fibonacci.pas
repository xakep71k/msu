program
var f0, f1, fi, k, i: int, b: bool;
begin

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

