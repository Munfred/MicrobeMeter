// MicrobeMeter
// Designed by Andrea Martinez-Vernon, Kalesh Sasidharan and Orkun S Soyer
// Date		: 2018/07/02
// Version	: 1.0
// This is the casing of the complete MicrobeMeter, which is divided into two parts due to the size and stability limitations of 3D-printers.

// This material is provided under the MicrobeMeter non-commercial, academic and personal use licence. By using this material, you agree to abide by the MicrobeMeter Terms and Conditions outlined on https://humanetechnologies.co.uk/terms-and-conditions-of-products/.

// © 2018 Humane Technologies Limited. All rights reserved.

{  // PARAMETERS (all units are in mm)
    {   // Height of Arduino Mega compartment
    totalHeight = 150; // Main cylinder container
    }
    {   // Cylinder parameters
    bottomCylinderH   = 60;
    bottomCylinderRad = 59; // to fit in cylinder container
    bottomCylinderCutH   = 57.5;
    bottomCylinderCutRad = bottomCylinderRad-2.5-1.5; // 2.5 mm thickness
    }
    {   // Hungate Tube parameters
    tubeHeight = 110;
    tubeInnerRad = 9.25;
    tubeOuterRad = tubeInnerRad+1.2; // 1.2 mm thickness
    tubePositionZ = 6;
    tubeHolderThick = 4; // thickness from bottom of the tube
    }
    {   // LED parameters -- outer hole
    LED_innerLength = 10+2.5;
    LED_innerRad    = 3.1;
    LED_outerLength = 12+2.5;
    LED_outerRad    = 5.1;
    }
    {   // Photodiode (PD) parameters -- inner hole
    PD_innerLength = 6.2;
    PD_innerRad    = 5.4;
    PD_outerLength = 9;
    PD_outerRad    = 6.9;
    }
    {   // Light path parameters
    lightExcessL = 6; // Make sure light path protrudes
    lightL = LED_outerLength+tubeInnerRad*2+PD_outerLength+lightExcessL;
    lightRad = 1;
    lightZ = 25.9; // Absolute height
    }
    {   // Battery Cutout parameters
    batteryCut_InnerW = 44;
    batteryCut_OuterW = batteryCut_InnerW+4;
    batteryCut_InnerL = 44;
    batteryCut_OuterL = batteryCut_InnerL+4;
    batteryCut_InnerH = 81;
    batteryCut_OuterH = batteryCut_InnerH-10;
    }
    {   // Battery Screw Holder parameters
    batteryScrewHolderW = 15;
    batteryScrewHolderL = 17;
    batteryScrewHolderH = 14;
    batteryScrewHolderAngle = 225;
    batteryScrewHolderZ = bottomCylinderH+batteryCut_OuterH-batteryScrewHolderH;
    batteryScrewHolderX = -(17-2)*2-pow(48,0.5)+12; // empirically determined
    batteryScrewHolderY = -(22-2)*2-pow(48,0.5)+10; // empirically determined
    }
    {   // Battery Screw Cutout parameters
    batteryScrewCutW = 6;
    batteryScrewCutL = 11;
    batteryScrewCutH = 18;
    batteryScrewCutAngle = 225;
    batteryScrewCutX = batteryScrewHolderX+(batteryScrewHolderL-batteryScrewCutL)/2-3;
    batteryScrewCutY = batteryScrewHolderY-1+(22-batteryScrewCutW)/2-3;
    batteryScrewCutZ = 115;
    }
    {   // Battery Screw Hole parameters
    batteryScrewHoleRad = 3.2;
    batteryScrewHoleH = 22*2;
    }
    {   // Arduino Mega Holder parameters
    mega_InnerH = 111;
    mega_InnerL = 56;
    mega_InnerW = 23;
    mega_OuterH = mega_InnerH+2;
    mega_OuterL = mega_InnerL+2.4;
    mega_OuterW = mega_InnerW+2.4;

    // Parameters needed for translating Arduino Mega holder (geometry: rectangle rotated 45 degrees)
    lengthA = mega_OuterL/sqrt(2)-1.5;  // the length of the other sides of the triangle made by the rectangle and the origin
    lengthX = sqrt(2)*mega_OuterW/2; // the length of the bottom side of the triangle made by the rectangle and the edge of the circle
    lengthY = lengthX; // Y length of the triangle made from the rotated Arduino Mega holder. Because it has 45 degree angles, both sides measure the same
    lengthC = 1.3; // empirically determined
    displacementX = lengthA - lengthC;
    displacementY = -lengthC-1.5;
    }
    {   // Arduino Mega cutouts inner
    megaCutW = mega_InnerW*2/3;
    megaCutL = mega_InnerL*2/3;
    megaCutH = bottomCylinderCutH*3/5;
    }
    {   // Arduino Mega lip cutout
    lipCutW = mega_OuterW;
    lipCutL = mega_OuterL*1.2;
    lipCutH = 62;
    sep = 0;
    // Have both rectangles aligned at the centre. use trig to figure out offsets
    // 0.7071068 = sin(45) = cos(45)
    displacement_lipCut_X = displacementX+0.7071068*mega_OuterW-0.7071068*(mega_OuterL-lipCutL)/2+0.7071068*sep;
    displacement_lipCut_Y = displacementY+0.7071068*mega_OuterW+0.7071068*(mega_OuterL-lipCutL)/2+0.7071068*sep;
    }
    {   // Mega cutouts outer
    megaCut_outW = mega_InnerW*1/3;
    megaCut_outL = mega_InnerL*2/5;
    megaCut_outH = 10;
    overlap = -5;
    megaCut_outX = displacementX+0.7071068*mega_OuterW-0.7071068*(mega_OuterL-megaCut_outL)/2+0.7071068*overlap;
    megaCut_outY = displacementY+0.7071068*mega_OuterW+0.7071068*(mega_OuterL-megaCut_outL)/2+0.7071068*overlap;
    }
    {   // Sensor system placement
    LEDOuter_X = -tubeInnerRad;
    LEDOuter_Y = 0;
    PDOuter_X = tubeInnerRad;
    PDOuter_Y = 0;
    LEDInner_X = -(tubeInnerRad+LED_outerLength-LED_innerLength);
    LEDInner_Y = 0;
    PDInner_X = tubeInnerRad+(PD_outerLength-PD_innerLength);
    PDInner_Y = 0;
    lightX = -tubeInnerRad-LED_outerLength-lightExcessL/2;
    lightY = 0;
    centreTubeCentre = batteryCut_InnerL/2+tubeOuterRad;
    tubePositionX = [-centreTubeCentre,0,centreTubeCentre,0];
    tubePositionY = [0,-centreTubeCentre,0,centreTubeCentre];
    // Sensors
    correctionY = [-tubePositionX[0]/2,-tubePositionX[1]/2,-tubePositionX[2]/2,-tubePositionX[3]/2]; // correct for rotation on X axis
    correctionX = [tubePositionY[0]/2,tubePositionY[1]/2,tubePositionY[2]/2,tubePositionY[3]/2]; // correct for rotation on Y axis
    }
    {   // Tube displacement to fit Arduino Mega Holder
        tubeDisplacementX = [0,0,0,-(tubeOuterRad+3)];
        tubeDisplacementY = [0,0,-(tubeOuterRad+3),0];
        thicknessBatteryHolder = (batteryCut_OuterW-batteryCut_InnerW)/2;
        thicknessTubeHolder = (tubeOuterRad-tubeInnerRad);
    }
    {   // Cable cut parameters
    LED_cableCutH   = lightZ+LED_innerRad/2;
    LED_cableCutRad = 2.5;
    LED_cableCutBottomH = 10;
    LED_cableCutBottomL = 8;
    LED_cableCutBottomW = 12;
    middle_cableCutR = 4+1;
    middle_cableCutH = 30;
    adjust = 5;
    holePositionX = [-(batteryCut_OuterW/2+adjust),-(batteryCut_OuterW/2+adjust),-(batteryCut_OuterW/2-adjust),batteryCut_OuterW/2-adjust,batteryCut_OuterW/2+adjust-1,2];
    holePositionY = [batteryCut_OuterW/2-adjust,-(batteryCut_OuterW/2-adjust),-(batteryCut_OuterW/2+adjust),-(batteryCut_OuterW/2+adjust),2,(batteryCut_OuterW/2+adjust-1)];
    }
    {   // Cut version - screw top and bottom
    screwR = 1.5;
    screwH = 30;
    screwDist = 5.65;
    screwHoldCutR = screwDist*2;
    screwHoldCutH = bottomCylinderCutH+1;
    screwZ = 45;
    // Positions
    screwAngle = 45;
    screwX = [(bottomCylinderRad-screwDist)*sin(screwAngle),-(bottomCylinderRad-screwDist)*sin(screwAngle)];
    screwY = [-(bottomCylinderRad-screwDist)*cos(screwAngle),(bottomCylinderRad-screwDist)*cos(screwAngle)];
    screwHoldCutX = [bottomCylinderRad*sin(screwAngle),-bottomCylinderRad*sin(screwAngle)];
    screwHoldCutY = [-bottomCylinderRad*cos(screwAngle),bottomCylinderRad*cos(screwAngle)];
    }
}

colours = ["green", "yellow","red","grey","white","black"];
colourslight = ["lightgreen", "lightyellow","pink","lightgrey"];

difference() {
    union() {
        difference() {
            union() {
                {   // Make holder hollow
                    difference () {
                        // Bottom cylinder holder
                        translate([0,0,0]) cylinder(h = bottomCylinderH,r = bottomCylinderRad, $fn=60,centre = true);
                        // Make holder hollow
                        translate([0,0,-1]) color("lightblue") cylinder(h = bottomCylinderCutH+1,r = bottomCylinderCutRad, $fn=60,centre = true);
                        }
                }
                {   // Place tubes
                    for(i=[0:3]) {
                         translate([tubePositionX[i]+tubeDisplacementX[i],tubePositionY[i]+tubeDisplacementY[i],tubePositionZ]) rotate([0,0,90*(i)]) color(colours[i]) cylinder(h=tubeHeight,r=tubeOuterRad,centre=true,$fn=60);
                         }
                     // Add cylinder at bottom to increase wall thickness
                     for(i=[0:3]) {
                         translate([tubePositionX[i]+tubeDisplacementX[i],tubePositionY[i]+tubeDisplacementY[i],tubePositionZ]) rotate([0,0,90*(i)])
                            color(colourslight[i]) cylinder(h=bottomCylinderCutH-tubePositionZ,r=tubeInnerRad+3,centre=true,$fn=60); // Increase wall thickness by 3 mm
                         }
                 }
                 {   // Place LEDs and PDs
                     for(i=[0:3]) {
                        translate([tubePositionX[i]+tubeDisplacementX[i],tubePositionY[i]+tubeDisplacementY[i],lightZ]) rotate([0,0,90*(i)]) {
                            // Add bottom LED
                            translate([LEDOuter_X,LEDOuter_Y,0]) rotate([0,-90,0])color(colourslight[i])  cylinder(h=LED_outerLength,r=LED_outerRad,centre=true,$fn=60);
                            // Add bottom PD
                            translate([PDOuter_X,PDOuter_Y,0]) rotate([0,90,0])color(colours[i]) cylinder(h=PD_outerLength,r=PD_outerRad,centre=true,$fn=60);
                        }
                    }
                 }
                 {   // Place Battery
                     translate([0,0,-14]) {
                         // Battery Cutout
                         translate([-batteryCut_OuterW/2,-batteryCut_OuterL/2,bottomCylinderH-2]) color("blue") cube(size=[batteryCut_OuterW,  batteryCut_OuterL,batteryCut_OuterH],centre=true,$fn=60);
                         //Battery Screw Holder
                         translate([0,0,-5])   translate([batteryScrewHolderX,batteryScrewHolderY,batteryScrewHolderZ]) rotate([0,0,45]) color("orange") cube(size=[batteryScrewHolderW,batteryScrewHolderL,batteryScrewHolderH],centre=true,$fn=60);
                         }
                 }
                 {   // Place Arduino Mega Holder
                     translate([displacementX,displacementY,0]) rotate([0,0,45])
                     color("black") cube(size=[mega_OuterW,mega_OuterL,mega_OuterH],centre=true,$fn=60);
                 }
         } // "union" ends
         
         // SUBTRACT
         {   // Subtract inner tube
             for(i=[0:3]) {
                 translate([tubePositionX[i]+tubeDisplacementX[i],tubePositionY[i]+tubeDisplacementY[i],tubePositionZ+tubeHolderThick]) rotate([0,0,90*(i)])  color(colourslight[i]) cylinder(h=tubeHeight,r=tubeInnerRad,centre=true,$fn=60);
                 }
         }
         {   // Subtract bottom LED and PD holders
             for(i=[0:3]) {
                 translate([tubePositionX[i]+tubeDisplacementX[i],tubePositionY[i]+tubeDisplacementY[i],lightZ]) rotate([0,0,90*(i)]) {
                     // Light path
                     translate([lightX,lightY,0]) rotate([0,90,0])color("pink") cylinder(h=lightL,r=lightRad,centre=true,$fn=60);
                     // inner LED rotated so that an increase in size will be reflected outwards
                     translate([LEDInner_X,LEDInner_Y,0]) rotate([0,-90,0])color("grey") cylinder(h=LED_innerLength+25,r=LED_innerRad,centre=true,$fn=60); // L+1 to make difference visible
                     // inner PD
                     translate([PDInner_X,PDInner_Y,0]) rotate([0,90,0])color("orange") cylinder(h=PD_innerLength+1,r=PD_innerRad,centre=true,$fn=60); // L+1 to make difference visible
                     }
                 }
         }
         {   // Subtract LED cable out
             LED_cableX = -bottomCylinderRad;
             LED_cableY = 0;
             LEDcable_correctX = [0,0,2,2];
             boxCutBottomX = -bottomCylinderRad-3;
             boxCutBottomY = -LED_cableCutBottomL/2;
             
             for(i=[0:3]) {
                 // Side grooves for LED cables
                 translate([tubeDisplacementX[i],tubeDisplacementY[i],-1]) rotate([0,0,90*(i)]) {
                     translate([LED_cableX+LEDcable_correctX[i],LED_cableY,0]) color("yellow")cylinder(h=LED_cableCutH,r=LED_cableCutRad,centre=true,$fn=60);
                     // Remove bottom for LED cables
                     translate([boxCutBottomX,boxCutBottomY,0]) color(colours[i]) cube(size=[LED_cableCutBottomW,LED_cableCutBottomL,LED_cableCutBottomH],centre=true,$fn=60);
                     }
                 }
         }
         {   // Subtract Battery holder
             // Battery Cutout
             translate([0,0,-14]) {
                 translate([-batteryCut_InnerW/2,-batteryCut_InnerL/2,bottomCylinderH]) color("lightblue") cube(size=[   batteryCut_InnerW,batteryCut_InnerL,batteryCut_InnerH],centre=true,$fn=60);
                 // Battery bottom access cutout
                 translate([-batteryCut_OuterW/2*(2/3),-batteryCut_OuterL/2*(2/3),bottomCylinderH-10]) color("blue") cube(size=[batteryCut_OuterW*(2/3),  batteryCut_OuterL*(2/3),batteryCut_OuterH],centre=true,$fn=60);
                 //Battery Screw Holder cutout
                 translate([0,0,-5]) {
                     translate([batteryScrewCutX,batteryScrewCutY,batteryScrewCutZ]) rotate([0,0,45]) color("lightblue") cube(size=[batteryScrewCutW,batteryScrewCutL,batteryScrewCutH],centre=true,$fn=60);
                     //Battery Screw Hole
                     translate([10,10,0]) {
                         translate([(batteryScrewHolderX-batteryScrewHolderW/2)/3-13,batteryScrewHolderY/3-11,batteryScrewHolderZ+ batteryScrewHolderH/2]) rotate([135,90,0]) color("red") cylinder(h=batteryScrewHoleH, r=batteryScrewHoleRad,centre=true,$fn=60);
                         }
                     }
                 }
         }
         {   // Subtract Arduino Mega holder
             translate([displacementX,displacementY,-1]) rotate([0,0,45]) {
                 translate([(mega_OuterW-mega_InnerW)/2,(mega_OuterL-mega_InnerL)/2,0]) color("lightgrey") cube(size=[mega_InnerW,mega_InnerL,mega_InnerH],centre=true,$fn=60);
                 }
                 // Remove inside cutout for cables
                 translate([displacementX-mega_OuterW/2,displacementY,-1]) rotate([0,0,45]) color("red") cube(size=[megaCutW,megaCutL,megaCutH],centre=true,$fn=60);
         }
         {   // Subtract Arduino Mega holder side lip
             translate([displacement_lipCut_X,displacement_lipCut_Y,-1]) rotate([0,0,45]) color("red") cube(size=[lipCutW,lipCutL,65],centre=true,$fn=60);
         }
         {   // Subtract Arduino Mega holder lip bottom cutout
             translate([megaCut_outX,megaCut_outY,-1]) rotate([0,0,45]) color("green") cube(size=[megaCut_outW,megaCut_outL,megaCut_outH],centre=true,$fn=60);
         }
         {   // Subtract cable hole (cutting section)
             for(j=[0]) {
                 translate([holePositionX[j],holePositionY[j],45]) color(colours[j]) cylinder(h=middle_cableCutH,r=middle_cableCutR,centre=true,$fn=60);
                 }
         }
         {   // Cut Version - screws
             for(n=[0:1]) {
                 // Screw hole
                 translate([screwX[n],screwY[n],40]) color("blue") cylinder(r=screwR,h=screwH,centre=true,$fn=60);
                 // Cut to screw nut
                 translate([screwHoldCutX[n],screwHoldCutY[n],-1]) color("white") cylinder(r=screwHoldCutR,h=screwHoldCutH,centre=true,$fn=60);
                 }
                 // Add another screw
                 // Screw hole
                 translate([-screwY[1],screwX[1],40]) color("blue") cylinder(r=screwR,h=screwH,centre=true,$fn=60);
                 // Cut to screw nut
                 translate([-screwHoldCutY[1],screwHoldCutX[1],-1]) color("white") cylinder(r=screwHoldCutR,h=screwHoldCutH,centre=true,$fn=60);
         }
         } // "difference" ends
     } // "union" ends
     
     // This section is for dividing the model into two parts (uncomment TOP or Bottom section at a time)
//     {   // TOP
//         // Remove bottom part
//         translate([0,0,-1]) cylinder(r=bottomCylinderRad+5,h=59,centre=true,$fn=60);
//     }
//     {   // BOTTOM
//         // Remove top part
//         translate([0,0,59]) cylinder(r=bottomCylinderRad+5,h=totalHeight,centre=true,$fn=60);
//     }
     
} // "difference" ends