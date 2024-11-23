include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

makeMount1 = false;

supportTubeOD = 43.6;

mastTubeOD = 41+4; // #3 mast section
belowMastTubeY = 9;

wallFitttingZ = 40;
frontFittingZ = wallFitttingZ;
cz=3;

tubeCtrY1 = belowMastTubeY + mastTubeOD/2 + 9;
tubeCtrY2 = belowMastTubeY + mastTubeOD/2;

d1 = 12;
p1 = [mastTubeOD/2+d1/2,0,0];

p2 = [p1.x, tubeCtrY1+d1/2, 0];
p3 = [p1.x, tubeCtrY1-d1/2+cz, 0];
p4 = [p1.x, belowMastTubeY, 0];
p5 = p4+[0,12,0];

topCtrX = 22;
module exterior()
{
    d = mastTubeOD + 2*d1;
    hull()
    {
        tsccde(
            t = [0,tubeCtrY1,0],
            d = d
        );
        tsccde(
            t = [topCtrX,14,0],
            d = d
        );
        tsccde(
            t = [topCtrX,-30,0],
            d = d
        );
        tsccde(
            t = [-25,0,0],
            d = d
        );
        tsccde(
            t = [-7,tubeCtrY1,0],
            d = d
        );
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
    // #interiorPiece([
    //     [  0, tubeCtrY1, 0],
    //     [  0, tubeCtrY2, 0],
    //     [100, tubeCtrY2, 0],
    // ]);

    difference()
    {
        interiorPiece([
            [  0, tubeCtrY1, 0],
            [  0, tubeCtrY2, 0],
            [100, tubeCtrY2, 0],
        ]);

        tcu([0, tubeCtrY1, -200], 400);

    //     translate([0,tubeCtrY1,0]) 
    //         rotate([0,0,clipAngle])
    //             tcu([0,0, -50], [25, 100, 100]);
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
            cz=cz);
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
        clipRemoval1();
        interior1();
        interior2();
    }
    clipEnd(0);
}

holderSpacingX = -p1.x;
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
        screwHole(  0);
        screwHole(-49);
        
        // Clip support tube:
        translate([0, -supportTubeOD/2 ,wallFitttingZ/2]) rotate([0,90,0]) tcy([0, 0, -200], d=supportTubeOD, h=400);
        tcu([-200, -400-supportTubeOD/2, -200], 400);
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

module clip(d=0)
{
	
}

if(developmentRender)
{
	display() mount1();

    displayGhost() tcy([25,tubeCtrY2-2,0], d=41, h=200);
    displayGhost() tcy([ 0,tubeCtrY1+2,0], d=41, h=200);
}
else
{
    if(makeMount1) rotate([0,0,180]) mount1();
}