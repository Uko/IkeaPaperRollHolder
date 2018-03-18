use <lib/threads.scad>;
use <lib/bezier_v2.scad>
use <lib/Knob.scad>


$fn=40;

thickness = 8;

bleed = 1;
bleed2 = bleed * 2;

jawWidth = 20;
jawDepth = 5;

bedThickness = 3;
roundRad = 2;

bracketWidth = 50;
bracketHeight = 75;
bracketTouchingHeight = 50;

hightAboveSurface = 55;
pivotDiameter = 25;
pivotLength = 70;

screwDiameter = 23;
screwThreadSize = 4;
screwCoreDiameter = screwDiameter - screwThreadSize - 0.7 ;


bedWidth = bedThickness * 2 + jawWidth;

module roundedCylinder(height, radius, roundness=5, fn = $fn) {

oldfn = $fn;

module torus() {
    translate([0, 0, roundness])
    rotate_extrude(convexity = 10, $fn = fn)
    translate([radius-roundness, 0, 0])    
    circle(r = roundness, $fn = oldfn);
}

hull() {
torus();
translate([0,0,height - roundness* 2])
torus();
}
}

module invRoundedCylinder(height, radius, roundness=5) {


module torus() {
    //translate([0, 0, roundness])
    rotate_extrude(convexity = 10)
    translate([radius, 0, 0])
    difference() {
        square(roundness);
        translate([roundness,roundness])
        circle(r = roundness);       
    }
}

union() {
    cylinder(height, r = radius);
torus();
translate([0,0,height ])
mirror([0,0,1])
torus();
}
}

module vasalPlate(height, width1, width2) {
    
    function nonBezier(from, to) = [from,from,to,to];

    linear_extrude(height = thickness) 
        bezier_polygon([
            nonBezier([0,   0],[0,  width1]),
        
            [[0,  width1],        [height / 2, width1],
            [height / 2, width2], [height, width2]],
     
            nonBezier([height, width2],[height,  0]),
        ]);    
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


union() {

// plate with thread
difference() {
    union() {
        cube([bedWidth / 2  + thickness + bleed2, bracketWidth, thickness]);
        translate([bedWidth / 2 + thickness + bleed, bracketWidth / 2, 0])
            difference() {
                cylinder(thickness, d1 = bracketWidth, d2 = bracketWidth);
                translate([-bracketWidth / 2, -bracketWidth / 2, - bleed])
                cube([bracketWidth / 2 + bleed, bracketWidth, thickness + bleed2]);
            }
    }

    translate([bedWidth / 2 + thickness + bleed, bracketWidth / 2, -bleed])
        scale([1.1,1.1,1])
        metric_thread(screwDiameter, screwThreadSize, thickness + bleed2, internal=true);
}



// side plate
translate([0, 0, thickness])
    cube([thickness, bracketWidth, bracketHeight - bracketTouchingHeight]);

color("red")
// thick side plate
translate([0, 0, thickness + bracketHeight - bracketTouchingHeight])
    cube([thickness + bedThickness + bleed, bracketWidth, bracketTouchingHeight]);


// top plate
translate([0,0,bracketHeight + thickness])
    difference() {
        cube([jawWidth + thickness * 2 + bedThickness + bleed, bracketWidth, thickness + jawDepth]);
        
        translate([thickness + bedThickness + bleed, -bleed, -bleed])
            cutcube(
                [jawWidth, bracketWidth + bleed2, jawDepth + bleed],
                roundRad,
                "top"
            );
    }

topBracketLevel = bracketHeight + thickness * 2 + jawDepth;

color("red")
// top side plate
translate([thickness, 0, topBracketLevel])
rotate([0, -90, 0])
    vasalPlate(hightAboveSurface, bracketWidth, pivotDiameter, thickness);

// pivot
translate([0, pivotDiameter / 2, topBracketLevel + hightAboveSurface])
    rotate([0, 90, 0])
        cylinder(pivotLength + thickness, d1 = pivotDiameter, d2 = pivotDiameter);


}



translate([50, 110, 0])
union() {
metric_thread(screwDiameter, screwThreadSize, 35, leadin=1);
knob(10, 40, 5);
translate([0,0,35])    
cylinder(2, screwCoreDiameter/2, screwCoreDiameter/2);
}


// bed
translate([0, -100, 0])
difference() {
    cube([jawWidth + bedThickness * 2, bracketWidth, jawDepth + bedThickness ]);    
    
    translate([bedThickness, -bleed, bedThickness + bleed])
            cutcube(
                [jawWidth, bracketWidth + bleed2, jawDepth + bleed],
                roundRad,
                "bottom"
            );
    translate([bedThickness + jawWidth / 2, bracketWidth / 2, -bleed])
        cylinder(1 + bleed, (screwCoreDiameter+1)/2, (screwCoreDiameter+1)/2);

}

