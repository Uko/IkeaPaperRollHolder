use <lib/threads.scad>;
use <lib/bezier_v2.scad>
use <lib/Knob.scad>

part = "all"; // [ "holder", "screw", "bed", "all" ]

$fn=80;

thickness = 8;
baseThickness = 12;



ff = 0.005; // fudge factor
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


module vasalPlate(height, width1, width2) {
    
    function nonBezier(from, to) = [from,from,to,to];
    
    module halfVasalPlate() {
        halfWidth1 = width1/2;
        halfWidth2 = width2/2;
        bezier_polygon([
            nonBezier([0,   0],[0,  halfWidth1]),
        
            [[0,  halfWidth1],        [height / 2, halfWidth1],
            [height / 2, halfWidth2], [height, halfWidth2]],
     
            nonBezier([height, halfWidth2],[height,  0]),
        ]);
    }
    
    
    linear_extrude(height = thickness) 
    union() {
        halfVasalPlate();
        mirror([0,1,0])
        halfVasalPlate();
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
        
        //weird cutouts to support overhang printing with second bigger radius
        translate([thickness + tol + bedThickness, -ff, -jawDepth - ff])
            cutcube(
                [jawWidth*5/6, bracketWidth + ff2, jawDepth * 2 + ff],
                roundRad,
                "top"
            );
    
        //this is the second bigger radius
        translate([
            thickness + tol + bedThickness + jawWidth/3,
            -ff,
            -jawDepth - ff])
                cutcube(
                    [jawWidth*2/3, bracketWidth + ff2, jawDepth * 2 + ff],
                    jawDepth,
                    "top"
                );
    }

topBracketLevel = baseThickness + bracketHeight + jawDepth + thickness;


// top side plate
color("red")
translate([thickness, bracketWidth/2, topBracketLevel])
mirror([0,1,0])
rotate([0, -90, 0])
    vasalPlate(hightAboveSurface, bracketWidth, pivotDiameter, thickness);

// pivot
translate([0, bracketWidth/2, topBracketLevel + hightAboveSurface])
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
