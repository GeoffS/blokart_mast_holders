include <MakeInclude.scad>
include <chamferedCylinders.scad>
use <torus.scad>

makeMount1 = false;
makeEndStop = false;

tubeOD = 41+4; // #3 mast section
belowTubeY = 9;

wallFitttingZ = 40;
frontFittingZ = wallFitttingZ;
cz=3;

tubeCtrY1 = belowTubeY + tubeOD/2 + 9;
tubeCtrY2 = belowTubeY + tubeOD/2;

d1 = 12;
p1 = [tubeOD/2+d1/2,0,0];

p2 = [p1.x, tubeCtrY1+d1/2, 0];
p3 = [p1.x, tubeCtrY1-d1/2+cz, 0];
p4 = [p1.x, belowTubeY, 0];
p5 = p4+[0,12,0];

topCtrX = 22;
module exterior()
{
    d = tubeOD + 2*d1;
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
    ty = tubeOD/2 + d1/2;
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
    d = tubeOD;

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
        
        // Clip wall:
        tcu([-200, -400, -200], 400);
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

endStopChamferZ = 6;
endStopDia1 = 50 + endStopChamferZ;
endStopDia2 = endStopDia1 + 10;
module endStop()
{
    difference()
    {
        hull()
        {
            endStopDisk1(-20, endStopDia2);
            endStopDisk1(tubeCtrY1+3, endStopDia1);

            endStopBody1(-20, 20, endStopDia2);
            endStopBody1(tubeCtrY1+3, 10, endStopDia1);

            tsp([0,0,-50], d=40);
        }

        // Clip wall:
        tcu([-100, -200, -190], 200);

        screwHole(0, z=-30);
    }
    
}

module endStopDisk1(y, d)
{
    translate([0, y, -endStopChamferZ])
        cylinder(
            d1=d, 
            d2=d-endStopChamferZ, 
            h=endStopChamferZ);
}

module endStopBody1(y, z, d)
{
    translate([0, y, -z-endStopChamferZ])
    {
        cylinder(
            d=d, 
            h=z);

        translate([0, 0, 0]) difference()
        {
            sphere(d=d);
            tcu([-100, -100, 0], 200);
        }
    }
}

module clip()
{
	// tcu([-200, -200, frontFittingZ/2], 400);
    // tcu([-200, -200, frontFittingZ/2], 400);
    // tcu([-400, -200, -10], 400);
}

if(developmentRender)
{
	difference()
	{
        union()
        {
            translate([0,0,100]) mount1();
            endStop();
        }

		clip();
	}
    %tcy([25,tubeCtrY2-2,0], d=41, h=200);
    %tcy([ 0,tubeCtrY1+2,0], d=41, h=200);
}
else
{
    if(makeMount1) rotate([0,0,180]) mount1();
    if(makeEndStop) rotate([0,180,0]) endStop();
}