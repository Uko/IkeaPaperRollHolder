PARTS=(holder screw bed all)

mkdir -p stl

for part in "${PARTS[@]}"
do
	printf "Compiling: %-15s" $part
	start_time=`date +%s`
	/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -D part=\"$part\" -o stl/$part.stl PaperRollHolder.scad
	end_time=`date +%s`
	duration=$(($end_time - $start_time))
	
	printf "\tduration: %2s:%02d\n" $(($duration/60)) $(($duration%60))
done

ALIGNS=(left right)

for align in "${ALIGNS[@]}"
do
	printf "Compiling: %-15s" $align
	start_time=`date +%s`
	/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -D part=\"holder\" -D align=\"$align\" -o stl/holder_$align.stl PaperRollHolder.scad
	end_time=`date +%s`
	duration=$(($end_time - $start_time))
	printf "\tduration: %2s:%02d\n" $(($duration/60)) $(($duration%60))
done