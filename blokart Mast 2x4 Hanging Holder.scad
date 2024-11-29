include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

makeMount1 = false;
makeDrillGuide = false;

mastTubeHoleDia = 41 + 4; // #3 mast section
belowMastTubeY = 9;

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
tubeCtr2Y = mastTubeHoleDia/2 + 10;
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

        ext2Dia = mastTubeHoleDia + 25;
        tsccde(
            t = [tubeCtr2X, tubeCtr2Y, 0],
            d = ext2Dia
        );
    }
}

module interior1()
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

module mount1()
{
    difference()
    {
        exterior1();
        interior1();

        screwHoles();

        // 2x4:
        tcu([-200,-400, 12], 400);
    }
}

module screwHoles()
{
    screwCleanceHoleDia = 4.5; // #8 Sheet-metal screw

    doubleX() tcy([30, -overlapWith2By4/2, -100], d=screwCleanceHoleDia, h=200);
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

    // Trim +X:
    // tcu([0, -200, -200], 400);
}

if(developmentRender)
{
    display() mount1();
    displayGhost() tcy([0,35.8,-100], d=41, h=200);
}
else
{
    if(makeMount1) rotate([0,0,180]) mount1();
	if(makeDrillGuide) rotate([-90,0,0]) drillGuide();
}