include <MakeInclude.scad>
include <chamferedCylinders.scad>
use <torus.scad>

// makeUpper2 = false;
// makeUpper3 = false;
// makeUpper4 = false;
// makeUpper5 = false;
makeUpper3Left = false;
makeUpper3Right = false;

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

module upperPiece3Left()
{
    difference()
    {
        translate([1.5*holderSpacingX,0,0]) upperPiece3();
        tcu([-400,-200,-200], 400);
    }
}

module upperPiece3Right()
{
    difference()
    {
        translate([-1.5*holderSpacingX,0,0]) upperPiece3();
        tcu([0,-200,-200], 400);
    }
}

module upperPiece4()
{
    difference()
    {
        union()
        {
            translate([-holderSpacingX,0,0]) upperCore();
            upperCore();
            translate([holderSpacingX,0,0]) upperCore();
            translate([2*holderSpacingX,0,0]) upperCore();

            buttressArm(-2*holderSpacingX);
            buttressArm(-holderSpacingX);
            buttressArm(  0);
            buttressArm( holderSpacingX);
            buttressArm( 2*holderSpacingX);

            hull()
            {
                tsp(p1+[-2*holderSpacingX,0,buttressX], d=d1);
                tsp(p1+[ 2*holderSpacingX,0,buttressX], d=d1);
                tsp(p1+[-2*holderSpacingX,0,d1/2], d=d1);
                tsp(p1+[ 2*holderSpacingX,0,d1/2], d=d1);
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

module upperPiece5()
{
    difference()
    {
        union()
        {
            translate([-2*holderSpacingX,0,0]) upperCore();
            translate([-holderSpacingX,0,0]) upperCore();
            upperCore();
            translate([holderSpacingX,0,0]) upperCore();
            translate([2*holderSpacingX,0,0]) upperCore();

            buttressArm(-3*holderSpacingX);
            buttressArm(-2*holderSpacingX);
            buttressArm(-holderSpacingX);
            buttressArm(  0);
            buttressArm( holderSpacingX);
            buttressArm( 2*holderSpacingX);

            hull()
            {
                tsp(p1+[-3*holderSpacingX,0,buttressX], d=d1);
                tsp(p1+[ 2*holderSpacingX,0,buttressX], d=d1);
                tsp(p1+[-3*holderSpacingX,0,d1/2], d=d1);
                tsp(p1+[ 2*holderSpacingX,0,d1/2], d=d1);
            }
        }

        // Screw holes:
        screwHole(-2*holderSpacingX);
        screwHole(  -holderSpacingX);
        screwHole(   0);
        screwHole(   holderSpacingX);
        screwHole( 2*holderSpacingX);
        
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
        
        // Bungie holes:
        // translate([p1.x+holderSpacingX,d1/2+12,frontFittingZ+3.3])
        //     rotate([0,90,0])
        //     {
        //         tcy([0,0,-10], d=4, h=20);
        //         doubleZ() translate([0,0,-1.3])
        //             cylinder(d1=0, d2=10, h=5);
        //     }
    }
    
}

module bungieHole()
{
    // #3 mast tube
    bungieHoleX = -29;
    bungieHoleY = 31;
    bungieHoleCZ = 4;

    translate([bungieHoleX,bungieHoleY,0])
    {
        tcy([0,0,-1], d=4, h=100);
        translate([0,0,frontFittingZ/2])
            doubleZ()
                translate([0,0,frontFittingZ/2-2-bungieHoleCZ])
                    cylinder(d2=20, d1=0, h=10);
    }

    // Bungie hook screw hole:
    // bungieHookY = 60; // 3" tube
    bungieHookY = 43; // #3 mast tube
    translate([tubeOD/2+d1-15, bungieHookY, frontFittingZ/2])
        rotate([0,90,0])
            cylinder(d=2.9, h=100);
}

module bungieHook()
{
    d = frontFittingZ-2;
    h2 = 2;
    h2a = h2 + 1.6;
    difference()
    {
        union()
        {
            hull() torus3(d, h2a);
            rotate([180,0,0])
                radiusedChamferedCylinder(
                    d = d, 
                    h = h2, 
                    r = 2, 
                    cz = 1);
            translate([0,0,h2a/2-nothing])
                cylinder(d1=d-8, d2=d-8, h=3.5);
        }

            tcy([0,0,-50], 3.7, 100);
    }
}

module clip()
{
	// tcu([-200, -400, -10], 400);
    // tcu([-200, -200, frontFittingZ/2], 400);
}

if(developmentRender)
{
	difference()
	{
        // union()
        // {
        //     holderSpacingX = 65;
        //     translate([-holderSpacingX,0,0]) upperPiece3();
        //     translate([ holderSpacingX,0,0]) upperCore();
        // }

        union()
        {
            translate([ 0.1,0,0]) upperPiece3Left();
            translate([-0.1,0,0]) upperPiece3Right();
        }

        // upperPiece5();
        // upperCore();
        // bungieHook();
		clip();
	}
    // %tcy([0, tubeCtrY, -20], d=tubeOD, h=60);
    // oneR5Inches = 1.5*25.4;
    // %tcu([-100,-oneR5Inches+belowTubeY,-oneR5Inches], [200, oneR5Inches, oneR5Inches]);
}
else
{
    if(makeUpper2) rotate([0,0,180]) upperPiece2();
    if(makeUpper3) rotate([0,0,180]) upperPiece3();
    if(makeUpper4) rotate([0,0,180]) upperPiece4();
    if(makeUpper5) rotate([0,0,180]) upperPiece5();
    if(makeUpper3Left) rotate([0,0,180]) upperPiece3Left();
    if(makeUpper3Right) rotate([0,0,180]) upperPiece3Right();
}