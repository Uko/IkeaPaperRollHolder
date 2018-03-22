   
module knob(height, diameter, numberOfArms = 6, roundingRadius = 2) {
    
    ff = 0.001; //fudge factorZ
    
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
    
    module hornedRect() {
        union() {
        
            square([petalRadius,height]);
     
            translate([petalRadius, 0])
                difference() {
                    square(roundingRadius);
                    translate([roundingRadius,roundingRadius])
                        circle(roundingRadius);  
                }
            
            translate([petalRadius, height - roundingRadius])
                difference() {
                    square(roundingRadius);
                    translate([roundingRadius,0])
                        circle(roundingRadius); 
            
                }
                
            // ff
            translate([0, -ff])
                square([petalRadius + roundingRadius,ff]);   
            translate([0, height])
                square([petalRadius + roundingRadius,ff]); 
            
        }            
    }
    

    module bump() {
        
            rotate_extrude( convexity=10)
                roundedRect();
    }


    
    module dent() {
            rotate_extrude(convexity=10)
                    hornedRect();
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
    
    difference() {
    union() { 
        cylinder(height,r=chordDistance+petalDistance, $fn = numberOfArms*2);
        
        for (i=[1:numberOfArms])
            rotate([0, 0, chordAngle * 2 * i])
                translate([chordDistance+petalDistance, 0, 0])
                    bump();
    }
        for (i=[1:numberOfArms])
            rotate([0, 0, chordAngle * 2 * (i + 0.5)])
                translate([chordDistance+petalDistance, 0, 0])
                    dent();
        
        
  
        //filling();
        
        
     }
}

