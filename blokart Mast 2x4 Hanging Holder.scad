include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

makeMount1 = false;
makeMount2 = false;
makeMount2a = false;
makeDrillGuide2 = false;

mastTubeHoleDia = 41 + 6; // #3 mast section

wallFitttingZ = 25;
wallFittingCZ = 3;

extDia = 25;

ext2Dia = mastTubeHoleDia + 20;

twoByFourNarrow = 1.5 * 25.4;
overlapWith2By4 = twoByFourNarrow - 2;
echo(str("overlapWith2By4 = ", overlapWith2By4));

mountX = 2*48;;
topCtrX = mountX/2 - extDia/2;
botCtrX = -topCtrX;

extraY = overlapWith2By4 - extDia/2;

interior_dh = 1;
interior_cz = wallFittingCZ + interior_dh;

tubeCtr2X = 0;
tubeCtr2Y = mastTubeHoleDia/2 + 6;
echo(str("tubeCtr2X = ", tubeCtr2X));

mountMaxY = tubeCtr2Y + ext2Dia/2;
echo(str("mountMaxY = ", mountMaxY));

tubeCtr = [tubeCtr2X, tubeCtr2Y, 0];

module exterior1()
{
    hull()
    {
        tsccde(
            t = [topCtrX,0,0],
            d = extDia
        );
        tsccde(
            t = [topCtrX,-extraY,0],
            d = extDia
        );

        tsccde(
            t = [botCtrX,0,0],
            d = extDia
            );
        tsccde(
            t = [botCtrX,-extraY,0],
            d = extDia
        );

        tsccde(
            t = tubeCtr,
            d = ext2Dia
        );
    }
}

module interior1()
{
    interiorPiece([[tubeCtr2X, tubeCtr2Y, 0]]);
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
            h=wallFitttingZ, 
            cz=wallFittingCZ);
}

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

twoByfourOffsetZ = 12;

module mount1()
{
    difference()
    {
        exterior1();
        interior1();

        mount1ScrewHoleXform() screwHole();

        twoByFour();
    }

    // Screw recess sacrificial layer:
    mount1ScrewHoleXform() tcy([0, 0, screwHeadClearanceHoleZ], d=6, h=layerThickness);
}

module mount1ScrewHoleXform()
{
    doubleX() translate([30, screwHoleCtrY, 0]) children();
}

module mount2()
{
    difference()
    {
        hull()
        {
            exterior1();
            secondMountXform() exterior1();
        }
        interior1();
        secondMountXform()  interior1();

        mount2ScrewHoleXform() screwHole();

        twoByFour();
    }

    // Screw recess sacrificial layer:
    mount2ScrewHoleXform() tcy([0, 0, screwHeadClearanceHoleZ], d=6, h=layerThickness);
}

module mount2a()
{
    difference()
    {
        hull()
        {
            exterior1();
            secondMountXform() exterior1();
        }
        mount2aSubtration();
    }

    difference()
    {
        union()
        {
            bungieBump();
            secondMountXform() mirror([1,0,0]) bungieBump();
        }
        mount2aSubtration();
    }

    bungieHook();

    // Screw recess sacrificial layer:
    mount2ScrewHoleXform() tcy([0, 0, screwHeadClearanceHoleZ], d=6, h=layerThickness);
}

bungieHoleDia = 3.7;
bungieBumpDia = bungieHoleDia + wallFittingCZ + 12;
echo(str("bungieBumpDia = ", bungieBumpDia));

module bungieHoles()
{
    bungieHole();
    secondMountXform() mirror([1,0,0]) bungieHole();
}

module mount2aSubtration()
{
    interior1();
    secondMountXform()  interior1();

    mount2ScrewHoleXform() screwHole();

    bungieHoles();

    twoByFour();
}

module bungieHook()
{
    bungieHookOD = 10;
    bungieHookOffsetY = 9;
    bungieHookBaseOffsetX = 10;

    bungieHookBaseZ = wallFitttingZ/2 - 2;
    echo(str("bungieHookBaseZ = ", bungieHookBaseZ));

    bungieHookZ = bungieHookBaseZ + wallFittingCZ + 6 ;

    translate([-secondMountOffsetX/2, mountMaxY, 0])
    {
        translate([0, bungieHookOffsetY, 0]) simpleChamferedCylinderDoubleEnded(
            d=bungieHookOD, 
            h=bungieHookZ, 
            cz=wallFittingCZ);

            hull()
            {
                doubleX() translate([bungieHookBaseOffsetX, -bungieHookOD/2, 0]) simpleChamferedCylinderDoubleEnded(
                    d=bungieHookOD, 
                    h=bungieHookBaseZ, 
                    cz=wallFittingCZ);

                translate([0,bungieHookOffsetY,0]) simpleChamferedCylinderDoubleEnded(
                    d=bungieHookOD, 
                    h=bungieHookBaseZ, 
                    cz=wallFittingCZ);
            }
    }
}

module bungieBump()
{
    hull()
    {
        exterior1();
        bungieBumpXform() tsccde([0,0,0], bungieBumpDia);
    }
}

module bungieHole()
{
    bungieBumpXform()
    {
        tcy([0,0,-100], d=bungieHoleDia, h=200);
        translate([0,0,-10+bungieHoleDia/2+3.4]) cylinder(d1=20, d2=0, h=10);
    }
}

module bungieBumpXform()
{
    translate(tubeCtr) rotate([0,0,102]) translate([mountMaxY/2+bungieHoleDia/2-0.8, 0, 0]) children();
}

module twoByFour()
{
    tcu([-200, -400, twoByfourOffsetZ], 400);
}

module mount2ScrewHoleXform()
{
    dx = 0;
    translate([dx, screwHoleCtrY, 0]) children();
    translate([-secondMountOffsetX-dx, screwHoleCtrY, 0]) children();
}

secondMountOffsetX = 65;

module secondMountXform()
{
    translate([-secondMountOffsetX,0,0]) children();
}

layerThickness = 0.2;

screwHoleCtrY = -overlapWith2By4/2;
screwCleanceHoleDia = 4.5; // #8 Sheet-metal screw
screwHeadClearanceHoleDia = 8.6; // #8 Pan-Head
screwHeadClearanceHoleZ = 4;

module screwHole() 
{
    tcy([0, 0, -100], d=screwCleanceHoleDia, h=200);
    tcy([0, 0, -100+screwHeadClearanceHoleZ], d=screwHeadClearanceHoleDia, h=100);
    translate([0,0,-10+screwHeadClearanceHoleDia/2+1]) cylinder(d1=20, d2=0, h=10);
}

module mount2DrillGuide()
{
    difference()
    {
        x1 = topCtrX + extDia/2;
        x2 = botCtrX - extDia/2;
        y1 = -overlapWith2By4;
        y2 = 12;
        hull()
        {
            drillGuideCorner(x1, y1);
            drillGuideCorner(x2, y1);
            drillGuideCorner(x1, y2);
            drillGuideCorner(x2, y2);
        }

        twoByFour();

        mount2ScrewHoleXform() tcy([secondMountOffsetX/2,0,-50], d=2, h=100);
    }
}

module drillGuideCorner(nominalX, nominalY)
{
    echo(str("drillGuideCorner() nominalX = ", nominalX));
    dgDia = 10;
    dgZ = 30;

    x = (nominalX > 0) ? nominalX - dgDia/2 : nominalX + dgDia/2;
    echo(str("drillGuideCorner() x = ", x));

    y = (nominalY > 0) ? nominalY - dgDia/2 : nominalY + dgDia/2;
    
    translate([x, y, 0]) cylinder(d=dgDia, h=dgZ);
}

module clip(d=0)
{
	// tcu([-200, -200, wallFitttingZ/2-d], 400);

    // Through screw holes:
    // tcu([-200, screwHoleCtrY-400-d, -200], 400);

    // Trim +X:
    // tcu([0, -200, -200], 400);

    // Trim at bungie hole:
    // tcu([-200, bungieHoleTranslation.y-d, -200], 400);
}

if(developmentRender)
{
    // display() mount1();
    // // Mast:
    // displayGhost() tcy([0,32.3,-100], d=41, h=200);
    // // 2x4:
    // displayGhost() twoByFourGhost();

    // display() mount2();
    // displayGhost() translate([130,0,0]) mount1();
    // // Mast:
    // displayGhost() tcy([0,32.3,-100], d=41, h=200);
    // // 2x4:
    // displayGhost() twoByFourGhost(400, -10);

    display() mount2a();
    displayGhost() twoByFourGhost(500, -130);
    displayGhost() translate([130,0,0]) mount1();
    displayGhost() translate([-190,0,0]) mount2();

    // display() mount2DrillGuide();
    // displayGhost() translate([-130,0,0]) mount2();
    // displayGhost() translate([130,0,0]) mount1();
    // Mast:
    // displayGhost() tcy([0,32.3,-100], d=41, h=200);
    // 2x4:
    // displayGhost() twoByFourGhost(500, -130);
}
else
{
    if(makeMount1) rotate([0,0,180]) mount1();
    if(makeMount2) rotate([0,0,180]) mount2();
    if(makeMount2a) rotate([0,0,180]) mount2a();
	if(makeDrillGuide2) mount2DrillGuide();
}

module twoByFourGhost(x=300, dx=0)
{
    w = 25.4 * 1.5;
    h = 25.4 * 3.5;
    d = 4;
    hull()
    {
        translate([dx, -w/2, twoByfourOffsetZ+h/2]) doubleY() doubleZ() rotate([0,90,0]) tcy([-h/2+d/2, w/2-d/2, -150], d=d, h=x);
    }
}