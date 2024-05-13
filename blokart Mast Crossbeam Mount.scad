include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

makeUpper2 = false;

tubeOD = 41+6; // #3 mast section
belowTubeY = 14;

wallFitttingZ = 40;
frontFittingZ = 40;
cz=4;

tubeCtrY = belowTubeY + tubeOD/2;

d1 = 12;
p1 = [tubeOD/2+d1/2+6, 0, 0];

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
        cylinder(d=d, h=200); //wallFitttingZ-2*cz+2*nothing);
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

module upperPiece1()
{
    difference()
    {
        exterior();

        interior();

        // Screw holes:
        screwHole(   0);
        screwHole(  holderSpacingX);
        
        // Clip wall:
        tcu([-200, -400, -200], 400);
    }
}

module upperPiece2()
{
    difference()
    {
        union()
        {
            hull()
            {
                exterior();
                translate([holderSpacingX,0,0]) exterior();
            }
        }

        interior();
        translate([holderSpacingX,0,0]) interior();

        // Screw holes:
        screwHole(   0);
        screwHole(  holderSpacingX);
        
        // Clip wall:
        tcu([-200, -400, -200], 400);
    }
}

module upperPiece3()
{
    difference()
    {
        hull()
        {
            translate([-holderSpacingX,0,0]) exterior();
            exterior();
            translate([holderSpacingX,0,0]) exterior();
        }
        
        translate([-holderSpacingX,0,0]) interior();
        interior();
        translate([holderSpacingX,0,0]) interior();

        // Screw holes:
        screwHole( -holderSpacingX);
        screwHole(   0);
        screwHole(  holderSpacingX);
        
        // Clip wall:
        tcu([-200, -400, -200], 400);
    }
}

screwdriverHoleDia = 10.5;

module screwHole(x)
{
    screwCleanceHoleDia = 4.4; // #8 sheet-metal screw
    chamferZ = -d1/2-5+screwCleanceHoleDia/2 + 2.5;
    translate([x,0,frontFittingZ/2]) rotate([90,0,0])
    {
        tcy([0,0,-50], d=screwCleanceHoleDia, h=100);
        translate([0,0,chamferZ]) cylinder(d1=screwdriverHoleDia, d2=0, h=screwdriverHoleDia/2);
        tcy([0,0,chamferZ-200+nothing], d=screwdriverHoleDia, h=200);
    }
}

module clip(d=0)
{
	// tcu([-400, -200, -800+frontFittingZ/2], 800);
}

if(developmentRender)
{
    display() translate([120,0,0]) upperPiece2();
    upperPiece1();
    display() translate([-200,0,0]) upperPiece3();

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