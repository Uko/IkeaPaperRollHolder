use <threads.scad>;
include <bezier_v2.scad>

$fn=360;

thickness = 8;

bleed = 1;
bleed2 = bleed * 2;

jawWidth = 20;
jawDepth = 5;

bedThickness = 3;
roundRad = 2;

bracketWidth = 50;
bracketHeight = 80;

hightAboveSurface = 60;
pivotDiameter = 25;
pivotLength = 70;

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


union() {

// plate with thread
difference() {
    cube([bedWidth + thickness + bleed2, bracketWidth, thickness]);    

    translate([bedWidth / 2 + thickness + bleed, bracketWidth / 2, -bleed])
        //cylinder(thickness + bleed2, screwDiameter/2, screwDiameter/2);
        scale([1.1,1.1,1])
        metric_thread(screwDiameter, screwThreadSize, thickness + bleed2, internal=true);
}

// side plate
translate([0, 0, thickness])
    cube([thickness,50,bracketHeight]);


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

topBracketLevel = bracketHeight + thickness * 2;

color("red")
// top side plate
translate([thickness, bracketWidth / 2, topBracketLevel])
rotate([0, -90, 0])
    vasalPlate(hightAboveSurface, bracketWidth, pivotDiameter, thickness);

// pivot
translate([0, bracketWidth / 2, topBracketLevel + hightAboveSurface])
    rotate([0, 90, 0])
        cylinder(pivotLength + thickness, d1 = pivotDiameter, d2 = pivotDiameter);


}

translate([50, 110, 0])
union() {
metric_thread(screwDiameter, screwThreadSize, 35, leadin=1);
cylinder(10, 22, 22, $fn=8);
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

