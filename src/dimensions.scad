
epsilon=.01;

defaultSize=30;
defaultThickness=2;
defaultHeight=180;
defaultBracketHeight=defaultSize;
defaultClearance=.2;
defaultPegSize=10;
defaultPegLength=40;
defaultPegSpacing=5;

defaultNutSize=defaultPegSize+2*defaultClearance;
defaultBoltSize=defaultPegSize-defaultClearance;

module reflect_x(v) {
    translate([1*v[0],v[1],v[2]]) mirror([1,0,0]) children();
    translate([-1*v[0],v[1],v[2]]) children();
}

module reflect_y(v) {
    translate([v[0],1*v[1],v[2]]) mirror([0,1,0]) children();
    translate([v[0],-1*v[1],v[2]]) children();
}

