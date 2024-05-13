include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

makeUpper2 = false;

tubeOD = 41+4; // #3 mast section
belowTubeY = 9;

wallFitttingZ = 21;
frontFittingZ = 21;
cz=3;

tubeCtrY = belowTubeY+tubeOD/2;

d1 = 12;
p1 = [tubeOD/2+d1/2,0,0];

p2 = [p1.x, tubeCtrY+d1/2, 0];
p3 = [p1.x, tubeCtrY-d1/2+cz, 0];
p4 = [p1.x, belowTubeY, 0];
p5 = p4+[0,12,0];

module exterior()
{
    d = tubeOD + 2*d1;
    hull()
    {
        tsccde(
            t = [0,tubeCtrY,0],
            d = d
        );
        tsccde(
            t = [0,-100,0],
            d = d
        );
    }
}

module interior()
{
    d = tubeOD;
    p = [0, tubeCtrY, 0];

    interior_tChamferTop(p, d=d);
    interior_tcy(p, d=d);
    interior_tChamferBottom(p, d=d);
}

module tsccde(t, d)
{
    translate(t)
        simpleChamferedCylinderDoubleEnded(d, h=frontFittingZ, cz=cz);
}

interior_dh = 1;
interior_cz = cz + interior_dh;
module interior_tcy(t, d)
{
    translate(t+[0,0,cz-nothing])
        cylinder(d=d, h=wallFitttingZ-2*cz+2*nothing);
}

module interior_tChamferBottom(t, d)
{
    translate(t+[0,0,-interior_dh])
        cylinder(d1=d+2*interior_cz, d2=d, h=interior_cz);
}

module interior_tChamferTop(t, d)
{
    translate(t+[0,0,wallFitttingZ-cz])
        cylinder(d2=d+2*interior_cz, d1=d, h=interior_cz);
}

module upperCore()
{
    difference()
    {
        exterior();
        interior();
    }
}

holderSpacingX = 2*p1.x;
module upperPiece2()
{
    difference()
    {
        union()
        {
            upperCore();
            translate([holderSpacingX,0,0]) upperCore();

            buttressArm(-holderSpacingX);
            buttressArm(  0);
            buttressArm( holderSpacingX);

            hull()
            {
                tsp(p1+[-holderSpacingX,0,buttressX], d=d1);
                tsp(p1+[ holderSpacingX,0,buttressX], d=d1);
                tsp(p1+[-holderSpacingX,0,d1/2], d=d1);
                tsp(p1+[ holderSpacingX,0,d1/2], d=d1);
            }
        }

        // Screw holes:
        screwHole( -holderSpacingX);
        screwHole(   0);
        screwHole(  holderSpacingX);
        screwHole(2*holderSpacingX);
        
        // Clip wall:
        tcu([-200, -400, -200], 400);
    }
}

module upperPiece3()
{
    difference()
    {
        union()
        {
            translate([-holderSpacingX,0,0]) upperCore();
            upperCore();
            translate([holderSpacingX,0,0]) upperCore();

            buttressArm(-2*holderSpacingX);
            buttressArm(-holderSpacingX);
            buttressArm(  0);
            buttressArm( holderSpacingX);

            hull()
            {
                tsp(p1+[-2*holderSpacingX,0,buttressX], d=d1);
                tsp(p1+[ holderSpacingX,0,buttressX], d=d1);
                tsp(p1+[-2*holderSpacingX,0,d1/2], d=d1);
                tsp(p1+[ holderSpacingX,0,d1/2], d=d1);
            }
        }

        // Screw holes:
        screwHole( -holderSpacingX);
        screwHole(   0);
        screwHole(  holderSpacingX);
        screwHole(2*holderSpacingX);
        
        // Clip wall:
        tcu([-200, -400, -200], 400);
    }
}

module screwHole(x)
{
    screwCleanceHoleDia = 3.7; // #6 sheet-metal screw
    chamferZ = -d1/2-5+screwCleanceHoleDia/2 + 2.5;
    translate([x,0,frontFittingZ+7]) rotate([90,0,0])
    {
        tcy([0,0,-50], d=screwCleanceHoleDia, h=100);
        translate([0,0,chamferZ])
            cylinder(d1=10, d2=0, h=5);
    }
}

buttressX = 50;
module buttressArm(holderSpacingX)
{
    d = d1-2*cz;
    difference()
    {
        hull()
        {
            tsp(p1+[holderSpacingX,0,buttressX], d=d);
            tsp(p1+[holderSpacingX,0,d/2], d=d);
            tsp(p2+[holderSpacingX,0,frontFittingZ-4], d=d);
        }
    }
    
}

module clip(d=0)
{
	
}

if(developmentRender)
{
    display() upperPiece2();

    displayGhost() mastGhost();
}
else
{
    if(makeUpper2) rotate([0,0,180]) upperPiece2();
}

module mastGhost()
{
    tcy([0,tubeCtrY,-100], d=41, h=200);
}