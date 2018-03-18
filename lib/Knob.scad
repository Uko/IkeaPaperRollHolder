   
module knob(height, diameter, numberOfArms = 6, roundingRadius = 2) {
    
    chordAngle = 180 / numberOfArms;
    halfChord = sin(chordAngle / 2) * diameter / 2;
    chordDistance = pow(diameter * diameter / 4 - halfChord * halfChord, 1/2);

    petalAngle = 180 - chordAngle;
    petalRadius = halfChord / sin(petalAngle / 2);
    petalDistance = pow(petalRadius * petalRadius - halfChord * halfChord, 1/2);

    module roundedRect() {
        difference() {
        
            square([petalRadius,height]);
     
            translate([petalRadius - roundingRadius, 0])
                difference() {
                    square(roundingRadius);
                    translate([0, roundingRadius])
                        circle(roundingRadius);  
                }
            
            translate([petalRadius - roundingRadius, height - roundingRadius])
                difference() {
                    square(roundingRadius);
                    circle(roundingRadius); 
            
                }
        }            
    }
    

    module bump() {
        rotate([0, 0, (360-petalAngle)/-2])
            rotate_extrude(angle=360-petalAngle, convexity=10)
                roundedRect();
    }

    module dent() {
        rotate([0, 0, 180-petalAngle/2])
            rotate_extrude(angle=petalAngle, convexity=10)
                translate([petalRadius * 2, 0])
                    mirror([1,0]) roundedRect();
    }
    
    module filling() {
        difference() {
            cylinder(height, r=chordDistance);
            
            for (i=[1:numberOfArms])
                rotate([0, 0, chordAngle * 2 * (i + 0.5)])
                    translate([chordDistance+petalDistance, 0, -1])
                        cylinder(height+2, r=(petalRadius+roundingRadius)*1.01);
        }
    }
    
    
    union() {
        for (i=[1:numberOfArms])
            rotate([0, 0, chordAngle * 2 * i])
                translate([chordDistance+petalDistance, 0, 0])
                    bump();
    
        for (i=[1:numberOfArms])
            rotate([0, 0, chordAngle * 2 * (i + 0.5)])
                translate([chordDistance+petalDistance, 0, 0])
                    dent();
  
        filling();
    }
}
