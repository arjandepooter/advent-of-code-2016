program Solution;


uses sysutils;

var
    discId, numberOfPositions, position: Longint;
    current, currentOffset, nextOffset: Longint;
    count, idx: Integer;
    line: String;
begin
    current := 1;
    currentOffset := 0;

    repeat
    readln(line);
    count := sscanf(line, 'Disc #%d has %d positions; at time=0, it is at position %d.', [@discId, @numberOfPositions, @position]);    
    
    if count = 0 then
    begin
        // Output part 1 and set value for part 2
        writeln(currentOffset);
        discId := 7;
        numberOfPositions := 11;
        position := 0;
    end;
    
    for idx := 0 to numberOfPositions do
    begin
        nextOffset := (10 * numberOfPositions - discId - position) mod numberOfPositions;
        if (currentOffset + current * idx) mod numberOfPositions = nextOffset then
        begin   
            currentOffset := currentOffset + current * idx;
            current := current * numberOfPositions;                
            break;
        end            
    end;        
    until count = 0;

    writeln(currentOffset)
end.