include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

makeMount1 = false;
makeBungieRetainer = false;

supportTubeOD = 43.6;

mastTubeOD = 41+4; // #3 mast section
belowMastTubeY = 9;

wallFitttingZ = 30;
frontFittingZ = wallFitttingZ;
wallFittingCZ=3;

tubeCtrY1 = belowMastTubeY + mastTubeOD/2 + 9;
tubeCtrY2 = belowMastTubeY + mastTubeOD/2;

d1 = 12;
p1 = [mastTubeOD/2+d1/2,0,0];

p2 = [p1.x, tubeCtrY1+d1/2, 0];
p3 = [p1.x, tubeCtrY1-d1/2+wallFittingCZ, 0];
p4 = [p1.x, belowMastTubeY, 0];
p5 = p4+[0,12,0];

topCtrX = 22;

extDia = mastTubeOD + 2*d1;

module exterior()
{
    
    hull()
    {
        tsccde(
            t = [0,tubeCtrY1,0],
            d = extDia
        );
        tsccde(
            t = [topCtrX,14,0],
            d = extDia
        );
        tsccde(
            t = [topCtrX,-30,0],
            d = extDia
        );
        tsccde(
            t = [-25,0,0],
            d = extDia
        );
        tsccde(
            t = [-7,tubeCtrY1,0],
            d = extDia
        );
    }

    bungieClip();
}

module bungieClip()
{
    
    d = 10;
    cz = wallFittingCZ;
    ctrZ = wallFitttingZ/2;
    
    // MAGIC NUMBER: 1.055 depends on 137 degree angle
    translate([-7,tubeCtrY1,0]) rotate([0,0,140]) translate([extDia/2-d/2-1.055, 0, ctrZ]) rotate([0,0,15])
    {
        x = 10.7;
        // MAGIC NUMBER: -0.1, depends on 1.055 above
        z1 = wallFitttingZ; // - 0.1;
        z2 = z1; //z1 - 2*x;
        hull()
        {
            translate([0, 0, -z1/2]) simpleChamferedCylinderDoubleEnded(d=d, h=z1, cz=cz);
            translate([x, 0, -z2/2]) simpleChamferedCylinderDoubleEnded(d=d, h=z2, cz=cz);
        }
        // Block to help adjust the final angle (above 9 degrees)
        // %tcu([7, -20,-20], [10, 40, 40]);
    }
}

clipAngle = -55;

module clipRemoval1()
{
    translate([0,tubeCtrY1,0]) 
        rotate([0,0,clipAngle])
            tcu([0,0, -50], [25, 100, 100]);
}

module clipEnd(mx)
{
    d1p = d1;
    ty = mastTubeOD/2 + d1/2;
    mirror([mx,0,0]) 
        translate([0,tubeCtrY1,0]) 
            rotate([0,0,clipAngle])
                tsccde(
                    t = [0,ty,0], 
                    d = d1p);
}

module interior1()
{
    interiorPiece([[0, tubeCtrY1, 0]]);

    difference()
    {
        interiorPiece([
            [  0, tubeCtrY1, 0],
            [100, tubeCtrY1, 0]
        ]);

        tcu([0, tubeCtrY1, -200], 400);

        translate([0,tubeCtrY1,0]) 
            rotate([0,0,clipAngle])
                tcu([0,0, -50], [25, 100, 100]);
    }
}

module interior2()
{
    difference()
    {
        interiorPiece([
            [  0, tubeCtrY1, 0],
            [  0, tubeCtrY2, 0],
            [100, tubeCtrY2, 0],
        ]);

        tcu([0, tubeCtrY1, -200], 400);
    }
}

module interiorPiece(centers)
{
    d = mastTubeOD;

    hull() for(p = centers)
    {
        interior_tChamferTop(p, d=d);
    }
    hull() for(p = centers)
    {
        interior_tcy(p, d=d);
    }
    hull() for(p = centers)
    {
        interior_tChamferBottom(p, d=d);
    }
}

module tsccde(t, d)
{
    translate(t)
        simpleChamferedCylinderDoubleEnded(
            d, 
            h=frontFittingZ, 
            cz=wallFittingCZ);
}

interior_dh = 1;
interior_cz = wallFittingCZ + interior_dh;
module interior_tcy(t, d)
{
    translate(t+[0,0,wallFittingCZ-nothing])
        cylinder(d=d, h=wallFitttingZ-2*wallFittingCZ+2*nothing);
}

module interior_tChamferBottom(t, d)
{
    translate(t+[0,0,-interior_dh])
        cylinder(d1=d+2*interior_cz, d2=d, h=interior_cz);
}

module interior_tChamferTop(t, d)
{
    translate(t+[0,0,wallFitttingZ-wallFittingCZ])
        cylinder(d2=d+2*interior_cz, d1=d, h=interior_cz);
}

module upperCore()
{
    difference()
    {
        exterior();
        clipRemoval1();
        interior1();
        interior2();
    }
    clipEnd(0);
}

holderSpacingX = -p1.x;
mountBungieHoleDia = 5;

module mount1()
{
    difference()
    {
        upperCore();

        // Trim the bit of excess that didn't get taken care of...
        tcy([42,42,-100], d=10, h=200);

        // Chamfer top:
        translate([topCtrX+37.5,0,0]) //[37.5,0,0])
            rotate([0,0,45])
                tcu([0, -5, -100], [30, 30, 200]);

        // Screw holes:
        screwHole( 45, screwHeadClearanceDia=9);
        // screwHole(  0);
        screwHole(-49);
        
        // Clip support tube:
        translate([0, -supportTubeOD/2, wallFitttingZ/2]) rotate([0,90,0]) tcy([0, 0, -200], d=supportTubeOD, h=400);
        tcu([-200, -400-supportTubeOD/2, -200], 400);

        // Bungie hole:
        translate([-31.9, 45, wallFitttingZ/2]) 
        {
            tcy([0, 0,-100], d=mountBungieHoleDia, h=200);
            doubleZ() translate([0, 0, wallFitttingZ/2-mountBungieHoleDia/2-3.5]) cylinder(d1=0, d2=20, h=10);
        }
    }
}

module screwHole(x, z=frontFittingZ/2, screwHeadClearanceDia=11)
{
    screwCleanceHoleDia = 3.7; // #6 sheet-metal screw
    // screwHeadClearanceDia = 11.0;

    chamferZ = -d1/2-5+screwCleanceHoleDia/2 + 2.5;
    translate([x,0,z]) rotate([90,0,0])
    {
        tcy([0,0,-50], d=screwCleanceHoleDia, h=100);
        translate([0,0,chamferZ])
        {
            cylinder(
                d1=screwHeadClearanceDia, 
                d2=0, 
                h=screwHeadClearanceDia/2);
            tcy([0,0,-100+nothing], d=screwHeadClearanceDia, h=100);
        }
    }
}


retainerBungieHoleDia = 3.5;

module bungieRetainer()
{
    // MAGIC NUMBER: 3.37 matches the chamfers on the body octagons.
    cz = 3.37;

    x1 = frontFittingZ + 2*cz + 2*retainerBungieHoleDia + 0.5;
    x2 = frontFittingZ;
    x3 = 15;
    y = 15;

    d = retainerBungieHoleDia + 8;
    z = d * cos(22.5);

    bungieHoleCtrOffsetX = frontFittingZ/2 -0.5 + retainerBungieHoleDia/2;

    difference()
    {
        union()
        {
            translate([-x1/2, 0, 0]) rotate([0,90,0]) rotate([0,0,22.5]) simpleChamferedCylinderDoubleEnded1(d = d, h = x1, cz = cz, $fn=8);

            // Front extension to fit into the 90 degree bungie-clip:
            difference()
            {
                // MAGIC NUMBER: 15.0255, should be calc. from d
                frontZ = frontFittingZ - 1;
                translate([0,0,0]) rotate([0,90,0]) tcy([0,0,-frontZ/2], d=15.0255, h=frontZ, $fn=4);
                // Trim back:
                tcu([-200,0,-200], 400);
                // Trim top and bottom:
                doubleZ() tcu([-200, -200, z/2], 400);
                // Clip the front point:
                tcu([-200,-400-7.3,-200], 400);
                // Angle the ends slightly:
                doubleX() translate([frontZ/2,-z/2,0]) rotate([0,0,-30]) tcu([0,-10,-10], 20);
            }

            hull()
            {
                translate([- x2/2, 0, 0]) rotate([0,90,0]) rotate([0,0,22.5]) simpleChamferedCylinderDoubleEnded1(d = d, h = x2, cz = cz, $fn=8);
                translate([- x3/2, y, 0]) rotate([0,90,0]) rotate([0,0,22.5]) simpleChamferedCylinderDoubleEnded1(d = d, h = x3, cz = cz, $fn=8);
            }
        }

        // Bungie holes:
        doubleX() translate([bungieHoleCtrOffsetX,0,0]) rotate([90,0,0]) tcy([0,0,-50], d=retainerBungieHoleDia, h=100);

        // Finger grips:
        yf = y-4.5;
        doubleZ() translate([0, yf, z/2-6]) cylinder(d1=0, d2=20, h=10);
        tcy([0,yf,-50], d=8, h=100);
    }
}

module clip(d=0)
{
	// tcu([-200, -200, wallFitttingZ/2-d], 400);

    // Trim +X:
    // tcu([0, -200, -200], 400);
}

if(developmentRender)
{
	// display() mount1();
    // displayGhost() tcy([25,tubeCtrY2-2,0], d=41, h=200);
    // displayGhost() tcy([ 0,tubeCtrY1+2,0], d=41, h=200);

    display() bungieRetainer();
}
else
{
    if(makeMount1) rotate([0,0,180]) mount1();
    if(makeBungieRetainer) rotate([0,0,180]) bungieRetainer();
}