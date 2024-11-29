include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

makeMount1 = false;
makeMount2 = false;
// makeDrillGuide = false;

mastTubeHoleDia = 41 + 6; // #3 mast section

wallFitttingZ = 25;
wallFittingCZ=3;

extDia = 25;

twoByFourNarrow = 1.5 * 25.4;
overlapWith2By4 = twoByFourNarrow - 2;

mountX = 2*48;;
topCtrX = mountX/2 - extDia/2;
botCtrX = -topCtrX;

extraY = overlapWith2By4 - extDia/2;

interior_dh = 1;
interior_cz = wallFittingCZ + interior_dh;

tubeCtr2X = 0;
tubeCtr2Y = mastTubeHoleDia/2 + 6;
echo(str("tubeCtr2X = ", tubeCtr2X));

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

        ext2Dia = mastTubeHoleDia + 20;
        tsccde(
            t = [tubeCtr2X, tubeCtr2Y, 0],
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

        // 2x4:
        tcu([-200,-400, twoByfourOffsetZ], 400);
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

        // 2x4:
        tcu([-200, -400, twoByfourOffsetZ], 400);
    }


    // Screw recess sacrificial layer:
    mount2ScrewHoleXform() tcy([0, 0, screwHeadClearanceHoleZ], d=6, h=layerThickness);
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

module drillGuide()
{
    // difference()
    // {
    //     hull()
    //     {
    //         drillGuideCorner(topCtrX + extDia/2);
    //         drillGuideCorner(botCtrX - extDia/2);
    //     }

    //     // The Screw holes:
    //     drillGuideScrewHole(screwHoleTopX);
    //     drillGuideScrewHole(screwHoleBotX);
    // }
}

// module drillGuideCorner(nominalX)
// {
//     echo(str("drillGuideCorner() nominalX = ", nominalX));
//     dgDia = 10;
//     dgZ = 45;
//     x = (nominalX > 0) ? nominalX - dgDia/2 : nominalX + dgDia/2;
//     echo(str("drillGuideCorner() x = ", x));
    
//     doubleZ() translate([x, 5, dgZ/2-dgDia/2]) rotate([90,0,0]) cylinder(d=dgDia, h=30);
// }

// module drillGuideScrewHole(x)
// {
//     translate([x,0,0]) rotate([90,0,0]) tcy([0,0,-50], d=1.8, h=100);
// }

module clip(d=0)
{
	// tcu([-200, -200, wallFitttingZ/2-d], 400);

    // Through screw holes:
    // tcu([-200, screwHoleCtrY-400-d, -200], 400);

    // Trim +X:
    // tcu([0, -200, -200], 400);
}

if(developmentRender)
{
    // display() mount1();
    // // Mast:
    // displayGhost() tcy([0,32.3,-100], d=41, h=200);
    // // 2x4:
    // displayGhost() twoByFourGhost();

    display() mount2();

    displayGhost() translate([130,0,0]) mount1();
    // Mast:
    displayGhost() tcy([0,32.3,-100], d=41, h=200);
    // 2x4:
    displayGhost() twoByFourGhost(400, -10);
}
else
{
    if(makeMount1) rotate([0,0,180]) mount1();
    if(makeMount2) rotate([0,0,180]) mount2();
	// if(makeDrillGuide) rotate([-90,0,0]) drillGuide();
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