include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

makeMount1 = false;
makeMount2 = false;
makeBungieRetainer = false;
makeDrillGuide = false;

supportTubeOD = 43.6;

mastTubeHoleDia = 41 + 4; // #3 mast section
belowMastTubeY = 9;

wallFitttingZ = 35;
frontFittingZ = wallFitttingZ;
wallFittingCZ=3;

tubeCtrY1 = belowMastTubeY + mastTubeHoleDia/2 + 9;
tubeCtrY2 = belowMastTubeY + mastTubeHoleDia/2;

d1 = 12;
p1 = [mastTubeHoleDia/2+d1/2,0,0];

p2 = [p1.x, tubeCtrY1+d1/2, 0];
p3 = [p1.x, tubeCtrY1-d1/2+wallFittingCZ, 0];
p4 = [p1.x, belowMastTubeY, 0];
p5 = p4+[0,12,0];

topCtr1X = 22;
botCtrX = -25;

tubeCtr2X = 0; //(topCtr1X + botCtrX);
tubeCtr2Y = tubeCtrY1 - 1.5;
echo(str("tubeCtr2X = ", tubeCtr2X));

extDia = mastTubeHoleDia + 2*d1;
extDia2 = mastTubeHoleDia + 10;

module exterior1()
{
    exteriorCore1();
    bungieClip();
}

module exteriorCore1()
{
    hull()
    {
        // Max. +Y exterior
        tsccde(
            t = [0,tubeCtrY1,0],
            d = extDia
        );

        // +X End:
        tsccde(
            t = [topCtr1X,14,0],
            d = extDia
        );
        tsccde(
            t = [topCtr1X,-30,0],
            d = extDia
        );

        tsccde(
            t = [botCtrX,0,0],
            d = extDia
        );
        tsccde(
            t = [botCtrX,-30,0],
            d = extDia
        );

        tsccde(
            t = [-7,tubeCtrY1,0],
            d = extDia
        );
    }
}

module exterior2()
{
    hull()
    {
        tsccde(
            t = [topCtr1X,0,0],
            d = extDia
        );
        tsccde(
            t = [topCtr1X,-30,0],
            d = extDia
        );

        tsccde(
            t = [botCtrX,0,0],
            d = extDia
            );
        tsccde(
            t = [botCtrX,-30,0],
            d = extDia
        );

        ext2Dia = mastTubeHoleDia + 25;
        tsccde(
            t = [tubeCtr2X, tubeCtr2Y, 0],
            d = ext2Dia
        );
    }
}

bungieClipDia = 10;
bungieClipCZ = wallFittingCZ;
bungieClipCtrZ = wallFitttingZ/2;
bungieClipZ = wallFitttingZ;

protrusionX = 10.7;
protrusionAngle = 16;

module bungieClip()
{
    difference() 
    {
        bungieClipCore();
        protrusionEndXform() tcu([-30, 0, -25], 80);
    }
    hull() bungieClipProtrusion();
}

module bungieClipProtrusion()
{
    protrusionXform() simpleChamferedCylinderDoubleEnded(d=bungieClipDia, h=bungieClipZ, cz=bungieClipCZ);
    protrusionEndXform() simpleChamferedCylinderDoubleEnded(d=bungieClipDia, h=bungieClipZ, cz=bungieClipCZ);
}

module bungieClipCore()
{
    // {
    
    hull()
    {
        bungieClipProtrusion();
        exteriorCore1();
    }
    // Block to help adjust the final angle (above 9 degrees)
    // %protrusionEndXform() tcu([-3.6, -20,-20], [10, 40, 40]);
}

module protrusionEndXform()
{
    protrusionXform() rotate([0,0,protrusionAngle]) translate([protrusionX, 0, 0]) children();
}

module protrusionXform(a=140)
{
    // MAGIC NUMBER: 1.055 depends on 137 degree angle
    translate([-7,tubeCtrY1,0]) rotate([0,0,a]) translate([extDia/2-bungieClipDia/2-1.055, 0, bungieClipCtrZ]) translate([0, 0, -bungieClipZ/2]) children();
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
    ty = mastTubeHoleDia/2 + d1/2;
    mirror([mx,0,0]) 
        translate([0,tubeCtrY1,0]) 
            rotate([0,0,clipAngle])
                tsccde(
                    t = [0,ty,0], 
                    d = d1p);
}

module interior1a()
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

module interior1b()
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

module interior2b()
{
    y = tubeCtr2Y;
    d = mastTubeHoleDia + 3;
    interiorPiece([[tubeCtr2X, y, 0]], d = d);
}

module interiorPiece(centers, d = mastTubeHoleDia)
{
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

module upperCore1()
{
    difference()
    {
        exterior1();
        clipRemoval1();
        interior1a();
        interior1b();
    }
    clipEnd(0);
}

module upperCore2()
{
    difference()
    {
        exterior2();
        interior2b();
    }
}

holderSpacingX = -p1.x;
mountBungieHoleDia = 3.5;

module mount1()
{
    difference()
    {
        upperCore1();

        // Trim the bit of excess that didn't get taken care of...
        tcy([42,42,-100], d=10, h=200);

        // Chamfer top:
        translate([topCtr1X+37.5,0,0]) //[37.5,0,0])
            rotate([0,0,45])
                tcu([0, -5, -100], [30, 30, 200]);


        commonExteriorTrimming();
    }
}

module mount2()
{
    difference()
    {
        upperCore2();

        commonExteriorTrimming();
    }
}

screwHoleTopX = 45;
screwHoleBotX = -49;
extraBetweenSupportAndMountY = 4;

module commonExteriorTrimming()
{
    // Screw holes:
    screwHole(screwHoleTopX, screwHeadClearanceDia=9);
    // screwHole(  0);
    screwHole(screwHoleBotX);
    
    // Clip support tube:
    supportTubeOffsetY = -supportTubeOD/2 - extraBetweenSupportAndMountY;
    translate([0, supportTubeOffsetY, wallFitttingZ/2]) rotate([0,90,0]) tcy([0, 0, -200], d=supportTubeOD, h=400);
    tcu([-200, -400+supportTubeOffsetY, -200], 400);

    // Clip the sharp edges from the support-tube:
    // MAGIC NUMBER: sharpEdgeClipY
    sharpEdgeClipY = -7.5;
    tcu([-200, -400+supportTubeOffsetY+supportTubeOD/2+sharpEdgeClipY, -200], 400);

    topMarker();
}

module topMarker(y=-extraBetweenSupportAndMountY, z=wallFitttingZ/2)
{
    // Mark to designate the top:
    translate([screwHoleTopX+7, y+1.5, z]) rotate([90,0,0]) cylinder(d1=0, d2=10, h=5);
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

module drillGuide()
{
    difference()
    {
        hull()
        {
            drillGuideCorner(topCtr1X + extDia/2);
            drillGuideCorner(botCtrX - extDia/2);
        }

        // The support-tube:
        translate([0, -30, 0]) rotate([0,90,0]) tcy([0, 0, -200], d=supportTubeOD, h=400);

        // The Screw holes:
        drillGuideScrewHole(screwHoleTopX);
        drillGuideScrewHole(screwHoleBotX);

        topMarker(y=-8.1, z=0);
    }
}

module drillGuideCorner(nominalX)
{
    echo(str("drillGuideCorner() nominalX = ", nominalX));
    dgDia = 10;
    dgZ = 45;
    x = (nominalX > 0) ? nominalX - dgDia/2 : nominalX + dgDia/2;
    echo(str("drillGuideCorner() x = ", x));
    
    doubleZ() translate([x, 5, dgZ/2-dgDia/2]) rotate([90,0,0]) cylinder(d=dgDia, h=30);
}

module drillGuideScrewHole(x)
{
    translate([x,0,0]) rotate([90,0,0]) tcy([0,0,-50], d=1.8, h=100);
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
    // display() drillGuide();
    // displayGhost() translate([150, 0,0]) mount1();
    // displayGhost() translate([-150,0,0]) mount2();

    // display() mount2();
    // displayGhost() difference()
    // {
    //     mount1();
    //     tcu([-200, -200, wallFitttingZ/2], 400);
    // }
    // oXY = 1.4;
    // displayGhost() tcy([-oXY,tubeCtrY2-oXY,0], d=41, h=200);
    // displayGhost() translate([150, 0,0]) mount1();

	// display() mount1();
    // displayGhost() tcy([25,tubeCtrY2-2,0], d=41, h=200);
    // displayGhost() tcy([ 0,tubeCtrY1+2,0], d=41, h=200);

    displayGhost() mount2();
    displayGhost() translate([0, 0, -65]) mount1();
    displayGhost() tcy([ 0, tubeCtrY1+2, -200], d=41, h=400);
    display() translate([0, 0, 80]) drillGuide();

    // display() bungieRetainer();
}
else
{
    if(makeMount1) rotate([0,0,180]) mount1();
    if(makeMount2) rotate([0,0,180]) mount2();
    if(makeBungieRetainer) rotate([0,0,180]) bungieRetainer();
	if(makeDrillGuide) rotate([-90,0,0]) drillGuide();
}