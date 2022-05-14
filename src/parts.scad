include<dimensions.scad>;
include <BOSL2/std.scad>
include <BOSL2/metric_screws.scad>

// Module: plate
// Description:
//   Create a single square equal to the leg size
// Arguments:
//   size = legs dimension in mm
//   thickness = extrusion height of the plate in mm (should match leg thickness)
//   pegSize = diameter of the cylinder cut out of the center of the plate (set to 0 for no cutout)
module plate(
    size=defaultSize,
    thickness=defaultThickness,
    pegSize=defaultPegSize) {
    difference(){
        linear_extrude(thickness)
        square(size, center=true);
        cylinder(d=pegSize, h=size, center=true, $fn=72);
    }
}

// Module: leg
// Description:
//   Creates concentric extrusions of cube edges. The legs are square and contain a center-line cut out to allow bolting things together.
// Arguments:
//   size = legs dimension in mm (x and y axis)
//   thickness = thickness of the leg wall in mm
//   height = how tall the leg is (z-axis)
//   clearance = additional space to account for real-world print clearance (know your printer's clearance)
//   pegSize = diameter of the cylinder cut out from the center-line of the leg
//   pegLength = something larger than the leg size, so the peg can be cutout from both sides of the wall along an x or y axis
//   pegSpacing = linear distance between peg holes
module leg(
    size=defaultSize,
    thickness=defaultThickness,
    height=defaultHeight,
    clearance=defaultClearance,
    pegSize=defaultPegSize,
    pegLength=defaultPegLength,
    pegSpacing=defaultPegSpacing
) {
    difference() {
        union() {
            linear_extrude(height)
            difference(){
                square(size, center=true);
                square(size-thickness, center=true);
            }

            linear_extrude(height)
            difference(){
                square(size-thickness-2*clearance, center=true);
                square(size-2*thickness-2*clearance, center=true);
            }
        }


        for (j = [0:(height/(pegSize+pegSpacing))])
        {
            translate([0,0,j*(pegSize + pegSpacing)])
            rotate(90, [1,0,0])
            cylinder(d=pegSize, h=pegLength, center=true, $fn=72);

            translate([0,0,j*(pegSize + pegSpacing)])
            rotate(90, [0,1,0])
            cylinder(d=pegSize, h=pegLength, center=true, $fn=72);
        }
    }
}

// Module: bracket
// Description:
//   Creates a bracket that fits either the outer or inner leg.
// Arguments:
//   size = legs dimension in mm (x and y axis)
//   thickness = thickness of the leg wall in mm
//   height = how tall the leg is (z-axis)
//   clearance = additional space to account for real-world print clearance (know your printer's clearance)
//   pegSize = diameter of the cylinder cut out from the center-line of the leg
//   pegLength = something larger than the leg size, so the peg can be cutout from both sides of the wall along an x or y axis
//   pegSpacing = linear distance between peg holes
//   inner = true the bracket receives the inner leg, false the bracket receives the outer leg (inner being in reference to the bracket, i.e it models an inner wall)
module bracket(
    size=defaultSize,
    thickness=defaultThickness,
    height=defaultBracketHeight,
    clearance=defaultClearance,
    pegSize=defaultPegSize,
    pegLength=defaultPegLength,
    pegSpacing=defaultPegSpacing,
    inner=false
) {
    translate([0,0,thickness])
    difference() {
        linear_extrude(height)
        if (inner  != true) {
            difference(){
                square(size, center=true);
                square(size-thickness, center=true);
            }
        } else {
            difference() {
                square(size-thickness-2*clearance, center=true);
                square(size-2*thickness-2*clearance, center=true);
            }
        }

        for (j = [1:2])
        {
            translate([0,0,j*(pegSize + pegSpacing)])
            rotate(90, [1,0,0])
            cylinder(d=pegSize, h=pegLength, center=true, $fn=72);

            translate([0,0,j*(pegSize + pegSpacing)])
            rotate(90, [0,1,0])
            cylinder(d=pegSize, h=pegLength, center=true, $fn=72);
        }
    }

    plate(size,thickness,pegSize);

    translate([size,0,0]) {
        if (inner == true) {
            // account for smaller size of inner leg
            plate(size,1.5*thickness,pegSize);

            reflect_y([0,(size-thickness)/2,size/2+thickness])
            rotate(90,[1,0,0])
            plate(size,thickness/2,pegSize);
        } else {
            plate(size,thickness,pegSize);
        }
    }

    translate([0,size,0]){
        if (inner == true) {
            plate(size,1.5*thickness,pegSize);

            reflect_x([size/2,0,size/2+thickness])
            rotate(90,[0,1,0])
            plate(size,thickness/2,pegSize);
        } else {
            plate(size,thickness,pegSize);
        }
    }
}

// Module: tool
// Description:
//   Creates a tool that with a couple of whacks will help pop the inner leg from the outer leg. Might also serve as an outer leg endcap.
// Arguments:
//   size = legs dimension in mm (x and y axis)
//   thickness = thickness of the leg wall in mm
//   height = how tall the leg is (z-axis)
//   clearance = additional space to account for real-world print clearance (know your printer's clearance)
//   pegSize = diameter of the cylinder cut out from the center-line of the leg
//   pegLength = something larger than the leg size, so the peg can be cutout from both sides of the wall along an x or y axis
//   pegSpacing = linear distance between peg holes
module tool(
    size=defaultSize,
    thickness=defaultThickness,
    height=defaultHeight,
    clearance=defaultClearance,
    pegSize=defaultPegSize,
    pegLength=defaultPegLength,
    pegSpacing=defaultPegSpacing
) {
    difference() {
        linear_extrude(height)
        difference(){
            square(size+thickness+2*clearance, center=true);
            square(size, center=true);
        }
    }

    linear_extrude(thickness)
    square(size, center=true);

    standSize=size-thickness-2*clearance;
    linear_extrude(height*.75)
    square(standSize, center=true);
}

// Module: fastener
// Description:
//   Creates a bolt that fits through a leg and is secured with the accompanying nut
// Arguments:
//   nutSize = standard metric screw size in mm
//   boltSize = diameter of threaded part of screw
//   legSize = dimension of the leg
module fastener(
    nutSize=defaultNutSize,
    boltSize=defaultBoltSize,
    legSize=defaultSize
){
    boltLength=defaultSize+boltSize;
    translate([2*nutSize, 0, 0])
    metric_nut(size=nutSize, hole=true, pitch=1.5, flange=3, details=true, center=false);
    metric_bolt(headtype="pan", size=boltSize, l=boltLength, shank=legSize, details=true, phillips="#2", orient=BOTTOM, anchor=TOP);
}

// Module: tableTop
// Description:
//   Creates a quadrants of the table top that can be joined with top plate cross.
// Arguments:
//   size = legs dimension in mm (x and y axis)
//   thickness = thickness of the leg wall in mm
//   height = how tall the leg is (z-axis)
//   clearance = additional space to account for real-world print clearance (know your printer's clearance)
//   pegSize = diameter of the cylinder cut out from the center-line of the leg
//   pegLength = something larger than the leg size, so the peg can be cutout from both sides of the wall along an x or y axis
//   pegSpacing = linear distance between peg holes
module tableTop (
    size=defaultSize,
    thickness=defaultThickness,
    height=defaultHeight,
    clearance=defaultClearance,
    pegSize=defaultPegSize,
    pegLength=defaultPegLength,
    pegSpacing=defaultPegSpacing
) {
    difference(){
        cube([135,135,2*thickness]);

        for (j = [6:6])
        {
            translate([120,j*(pegSize + pegSpacing),0])
            cylinder(d=pegSize, h=pegLength, center=true, $fn=72);

            translate([j*(pegSize + pegSpacing),120,0])
            cylinder(d=pegSize, h=pegLength, center=true, $fn=72);
        }

        translate([0,0,thickness])
        plate(size+epsilon,thickness+epsilon,0);

        translate([size,0,thickness]){
            plate(size+epsilon,thickness+epsilon,0);
            cylinder(d=pegSize, h=pegLength, center=true, $fn=72);
        }
        translate([0,size,thickness]){
            plate(size+epsilon,thickness+epsilon,0);
            cylinder(d=pegSize, h=pegLength, center=true, $fn=72);
        }
    }
}

// Module: topPlate
// Description:
//   Creates a top plate to join table top quadrants.
// Arguments:
//   size = legs dimension in mm (x and y axis)
//   thickness = thickness of the leg wall in mm
//   height = how tall the leg is (z-axis)
//   clearance = additional space to account for real-world print clearance (know your printer's clearance)
//   pegSize = diameter of the cylinder cut out from the center-line of the leg
//   pegLength = something larger than the leg size, so the peg can be cutout from both sides of the wall along an x or y axis
//   pegSpacing = linear distance between peg holes
module topPlate(
    size=defaultSize,
    thickness=defaultThickness,
    height=defaultHeight,
    pegSize=defaultPegSize,
    nutSize=defaultNutSize,
    boltSize=defaultBoltSize,
) {
    boltLength=2*thickness+boltSize;

    plate(size,thickness,0);

    reflect_x([size,0,0])
    plate(size,thickness,pegSize);

    reflect_y([0,size,0]) {
        plate(size,thickness,pegSize);

        reflect_x([size,0,0]) {
            metric_nut(size=nutSize, hole=true, pitch=1.5, flange=3, details=true, center=false);
            translate([-size,0,0])
            metric_bolt(headtype="pan", size=boltSize, l=boltLength, details=true, phillips="#2", orient=BOTTOM, anchor=TOP);
        }
    }
}