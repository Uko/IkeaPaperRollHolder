use <lib/threads.scad>;
use <lib/bezier_v2.scad>
use <lib/Knob.scad>

part = "all"; // [ "holder", "screw", "bed", "all" ]

$fn=80;
align = "middle"; // [ "middle", "left", "right" ]


thickness = 8;
baseThickness = 12;



ff = 0.01; // fudge factor
ff2 = ff * 2;

tol = 0.5; // tolerance

jawWidth = 19;
jawDepth = 5;

bedThickness = 3;
roundRad = 2;

bracketWidth = 40;
bracketHeight = 75;
bracketTouchingHeight = 50;

hightAboveSurface = 55;
pivotDiameter = 25;
pivotLength = 60;

screwDiameter = 23;
screwThreadSize = 4;
screwCoreDiameter = screwDiameter - screwThreadSize - 0.7 ;


bedWidth = bedThickness * 2 + jawWidth;


module halfVasalPlate(height, width1, width2) {
    
    function nonBezier(from, to) = [from,from,to,to];
    
    halfWidth1 = width1/2;
    halfWidth2 = width2/2;
    
    linear_extrude(height = thickness)
    bezier_polygon([
        nonBezier([0,   0],[0,  width1]),
    
        [[0,  width1],        [height / 2, width1],
        [height / 2, width2], [height, width2]],
 
        nonBezier([height, width2],[height,  0]),
    ]);
}

module vasalPlate(height, width1, width2) {
    
    halfWidth1 = width1/2;
    halfWidth2 = width2/2;
     
    union() {
        halfVasalPlate(height, halfWidth1, halfWidth2);
        mirror([0,1,0])
        halfVasalPlate(height, halfWidth1, halfWidth2);
    }
}





module cutcube(dimmentions, radius, variant) {
    x = dimmentions[0];
    y = dimmentions[1];
    z = dimmentions[2];
    
    
    module helperCylinder() {
        rotate([-90, 0, 0])
        cylinder(y, radius, radius);
    }
    
    hull() {
        if ((variant == "bottom") || (!variant)) {
            translate([radius, 0, radius])
                helperCylinder();
            translate([x - radius, 0, radius])
                helperCylinder();
        } else {
            cube([x, y, z/2]);
        }
        if ((variant == "top") || (!variant)) {
            translate([x - radius, 0, z - radius])
                helperCylinder();
            translate([radius, 0, z - radius])
                helperCylinder();
        } else {
            translate([0,0,z/2])
                cube([x, y, z/2]);
        }
    }
}

module holder () {
translate([bracketHeight,-bracketWidth/2,0])
rotate([0,-90,0])
union() {

//# plate with thread    

difference() {
    threadCenter = bedWidth / 2 + thickness + tol;
    union() {
        // ractangular part of base
        cube([threadCenter, bracketWidth, baseThickness]);
        // round part of base
        translate([threadCenter, bracketWidth / 2, 0])
            difference() {
                cylinder(baseThickness, d = bracketWidth);
                translate([-bracketWidth / 2, -bracketWidth / 2, -ff])
                    cube([bracketWidth / 2, bracketWidth, baseThickness + ff2]);
            }
    }

    // thread cutout
    translate([threadCenter, bracketWidth / 2, -ff])
        metric_thread(screwDiameter + tol*2, screwThreadSize, baseThickness + ff2, internal=true);
}



// side plate
translate([0, 0, baseThickness])
    cube([thickness, bracketWidth, bracketHeight - bracketTouchingHeight]);

color("red")
// thick side plate
translate([0, 0, baseThickness + bracketHeight - bracketTouchingHeight])
    cube([thickness + bedThickness + tol, bracketWidth, bracketTouchingHeight]);


// top plate
translate([0,0,bracketHeight + baseThickness])
   

    difference() {
        cube([
            thickness + tol + bedThickness + jawWidth + thickness,
            bracketWidth,
            thickness + jawDepth]);
        color("blue")
        translate([thickness+tol+bedThickness,bracketWidth+ff,-ff])
        rotate([90,0,0])
        linear_extrude(bracketWidth+ff2)
            union() {
                
                square([jawWidth-jawDepth,jawDepth-roundRad]);
                translate([roundRad,jawDepth-roundRad])    
                    square([jawWidth-jawDepth-roundRad,roundRad]);
                
                translate([roundRad,jawDepth-roundRad])    
                intersection() {
                    circle(r=roundRad);
                    translate([-roundRad,0])
                        square(roundRad);
                }
                
                translate([jawWidth-jawDepth,0])    
                intersection() {
                    circle(r=jawDepth);
                    square(jawDepth);
                }
                
                translate([0,-ff])
                    square([jawWidth,-ff]);
            }
}

topBracketLevel = baseThickness + bracketHeight + jawDepth + thickness - ff;


// top side plate
color("red")
translate([thickness, bracketWidth/2, topBracketLevel])
rotate([0, -90, 0])
    if(align == "left")
    {
        translate([0, -bracketWidth/2, 0])
        halfVasalPlate(hightAboveSurface, bracketWidth, pivotDiameter);
    } else if(align == "right") {
        translate([0, bracketWidth/2, 0])
        mirror([0,1,0])
        halfVasalPlate(hightAboveSurface, bracketWidth, pivotDiameter);
    } else {    
        vasalPlate(hightAboveSurface, bracketWidth, pivotDiameter);
    }

// pivot
pivotNudge = (align == "left") ? (pivotDiameter-bracketWidth)/2 : // left
            ((align == "right") ? (bracketWidth-pivotDiameter)/2 : // right
            0); // middle (or anything)
    
translate([0, bracketWidth/2 + pivotNudge, topBracketLevel + hightAboveSurface])
    rotate([0, 90, 0])
        cylinder(pivotLength + thickness, d = pivotDiameter);


}
}

module screw() {

union() {
metric_thread(screwDiameter, screwThreadSize, 32, leadin=1);
knob(10, 35, 6);
translate([0,0,32])    
cylinder(2, screwCoreDiameter/2, screwCoreDiameter/2);
}
}

module bed() {
// bed
translate([ -jawWidth/2 - bedThickness, (jawDepth + bedThickness) / 2, 0])
rotate([90,0,0])
difference() {
    cube([jawWidth + bedThickness * 2, bracketWidth, jawDepth + bedThickness ]);    
    
    translate([bedThickness, -ff, bedThickness + ff])
            cutcube(
                [jawWidth, bracketWidth + ff2, jawDepth + ff],
                roundRad,
                "bottom"
            );
    translate([bedThickness + jawWidth / 2, bracketWidth / 2, -ff])
        cylinder(1 + ff, d=screwCoreDiameter+tol);

}

}


module all() {
   //translate([bracketHeight,-bracketWidth/2,0])
    translate([0,-bracketWidth*2/3,0])
        holder();
    translate([bracketHeight/2,bracketWidth*2/3,0])
        screw();
    translate([-bracketHeight/2,bracketWidth*2/3,0])
        bed();
}

if ((part == "holder") || (part == 1)) {
    holder();
} else if ((part == "screw") || (part == 2)) {
    screw();
} else if ((part == "bed") || (part == 3)) {
    bed();
} else {
    all();
}
