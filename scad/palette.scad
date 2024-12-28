$fn = $preview ? 8 : 16;

// PARAMETERS
//size of pan
panDimensions = [20, 30, 10]; // ~full pan
//panDimensions = [16, 19, 10]; // ~half pan

panRows = 2; // number of rows of pans
panColumns = 5; // number of columns of pans
sideMagnets = 4; // number of magnets on side
mixSections = 3; // number of mixing wells

magnetDimensions = [2, 2.5]; // height, radius of magnet

// dimensions of bevel for opening the body
openGapDimensions = [30, 4, 4];
openGapPoint = 10;

zMargin = 2; // thickness of wall at bottom of pan
xyMargin = magnetDimensions[0] * 2 + 5; // thickness of wall around pan section


panWallDepth = .6; // wall thickness around each pan

panBevelDimensions = [2, 2, 2]; // roundness of pan corners
bodyBevelDimensions = [4, 4, 2]; // roundness of body outer corners
mixSectionBevelDimensions = [4, 4, 2]; // roundness of mixing well corners

// END PARAMETERS


bodyDimensions = [
  panColumns * panDimensions[0] + 2 * xyMargin,
  panRows * panDimensions[1] + 2 * xyMargin,
  max(panDimensions[2], magnetDimensions[1]) + zMargin
];

sideMagnetGap = (panColumns * panDimensions[0] - magnetDimensions[1] * 4) / (sideMagnets - 1);

mixSectionDimensions = [
  panColumns * panDimensions[0] / mixSections,
  panRows * panDimensions[1],
  6
];

xyMagnetPositions = [
  [(bodyDimensions[0] - xyMargin) / 2, (bodyDimensions[1] - xyMargin) / 2, 0],
  [-(bodyDimensions[0] - xyMargin) / 2, (bodyDimensions[1] - xyMargin) / 2, 0],
  [-(bodyDimensions[0] - xyMargin) / 2, -(bodyDimensions[1] - xyMargin) / 2, 0],
  [(bodyDimensions[0] - xyMargin) / 2, -(bodyDimensions[1] - xyMargin) / 2, 0],
];

function offsetToCenter(width, sections) = -(sections - 1) * width / 2;

function calcCubeBevelOffset(cubeDimensions, bevelDimensions) = [
  [cubeDimensions[0] / 2 - bevelDimensions[0], cubeDimensions[1] / 2 - bevelDimensions[1], cubeDimensions[2] / 2 - bevelDimensions[2]],
  [-cubeDimensions[0] / 2 + bevelDimensions[0], cubeDimensions[1] / 2 - bevelDimensions[1], cubeDimensions[2] / 2 - bevelDimensions[2]],
  [-cubeDimensions[0] / 2 + bevelDimensions[0], -cubeDimensions[1] / 2 + bevelDimensions[1], cubeDimensions[2] / 2 - bevelDimensions[2]],
  [cubeDimensions[0] / 2 - bevelDimensions[0], -cubeDimensions[1] / 2 + bevelDimensions[1], cubeDimensions[2] / 2 - bevelDimensions[2]],
  [cubeDimensions[0] / 2 - bevelDimensions[0], cubeDimensions[1] / 2 - bevelDimensions[1], -cubeDimensions[2] / 2 + bevelDimensions[2]],
  [-cubeDimensions[0] / 2 + bevelDimensions[0], cubeDimensions[1] / 2 - bevelDimensions[1], -cubeDimensions[2] / 2 + bevelDimensions[2]],
  [-cubeDimensions[0] / 2 + bevelDimensions[0], -cubeDimensions[1] / 2 + bevelDimensions[1], -cubeDimensions[2] / 2 + bevelDimensions[2]],
  [cubeDimensions[0] / 2 - bevelDimensions[0], -cubeDimensions[1] / 2 + bevelDimensions[1], -cubeDimensions[2] / 2 + bevelDimensions[2]],
];

module RoundedCube(cubeDimensions, bevelDimensions) {
  let (bevelPositions = calcCubeBevelOffset(cubeDimensions, bevelDimensions)) {
    hull() {
      for(index = [0 : len(bevelPositions) - 1])
        translate(bevelPositions[index])
          scale(bevelDimensions) sphere(1);  
    };
  };
};

module OpenGap() {
  polyhedron(
    [
      [-openGapDimensions[0] / 2 - openGapPoint, 0, 0],
      [-openGapDimensions[0] / 2, openGapDimensions[1], 0],
      [-openGapDimensions[0] / 2, 0, openGapDimensions[2]],
      [-openGapDimensions[0] / 2, -openGapDimensions[1], 0],
      [-openGapDimensions[0] / 2, 0, -openGapDimensions[2]],
      [openGapDimensions[0] / 2 + openGapPoint, 0, 0],
      [openGapDimensions[0] / 2, openGapDimensions[1], 0],
      [openGapDimensions[0] / 2, 0, openGapDimensions[2]],
      [openGapDimensions[0] / 2, -openGapDimensions[1], 0],
      [openGapDimensions[0] / 2, 0, -openGapDimensions[2]],
    ],
    [
      [0, 1, 2],
      [0, 2, 3],
      [0, 3, 4],
      [0, 4, 1],
      [5, 7, 6],
      [5, 8, 7],
      [5, 9, 8],
      [5, 6, 9],
      [2, 1, 6, 7],
      [3, 2, 7, 8],
      [4, 3, 8, 9],
      [1, 4, 9, 6],
    ]
  );
};

module Body() {
  translate([0, 0, bodyBevelDimensions[2] / 2]) // offset for top bevel
  union(){ // debug
    difference() {
      RoundedCube([bodyDimensions[0], bodyDimensions[1], bodyDimensions[2] + bodyBevelDimensions[2]], bodyBevelDimensions);
      translate([0, 0, bodyDimensions[2] / 2 + bodyBevelDimensions[2] / 2])
        cube([bodyDimensions[0] + 1, bodyDimensions[1] + 1, bodyBevelDimensions[2] * 2], true);
      for(index = [0 : len(xyMagnetPositions) - 1])
        translate(xyMagnetPositions[index])
        // double check depth of magnets
        translate([0, 0, bodyDimensions[2] / 2 - (magnetDimensions[0] + 1) / 2])
          cylinder(magnetDimensions[0] + 1, magnetDimensions[1], magnetDimensions[1], true);
      translate([-(panColumns) * panDimensions[0] / 2 + magnetDimensions[1] * 2, bodyDimensions[1] / 2 - (magnetDimensions[0] - 1) / 2, 0])
      for(index = [0 : sideMagnets - 1])
        translate([index * sideMagnetGap, 0, 0]) // doublecheck magnet depth
        rotate([90, 0, 0])
          cylinder(magnetDimensions[0] + 1, magnetDimensions[1], magnetDimensions[1], true);
      translate([0, -bodyDimensions[1] / 2, bodyDimensions[2] / 2 - bodyBevelDimensions[2] / 2])
        OpenGap();
    };
  };
};


// pan body
translate([0, -bodyDimensions[1] / 2 - 8, 0])
  difference() {
    Body();
    translate([offsetToCenter(panDimensions[0], panColumns), offsetToCenter(panDimensions[1], panRows), bodyDimensions[2] / 2 - panDimensions[2] / 2 + panBevelDimensions[2] / 2]) // doublecheck hole depth
      for(indexR = [0 : panRows - 1])
        for(indexC = [0 : panColumns - 1])
          translate([indexC * panDimensions[0], indexR * panDimensions[1], 0])
            RoundedCube([panDimensions[0] - 2 * panWallDepth, panDimensions[1] - 2 * panWallDepth, panDimensions[2] + panBevelDimensions[2]], panBevelDimensions);
  };

// mix body
mirror([0, 1, 0])
translate([0, -bodyDimensions[1] / 2 - 8, 0])
  difference() {
  //union() {
    Body();
    translate([offsetToCenter(mixSectionDimensions[0], mixSections), 0, 0])
      for(index = [0 : mixSections - 1])
        translate([index * mixSectionDimensions[0], 0, bodyDimensions[2] / 2 - (mixSectionDimensions[2] - mixSectionBevelDimensions[2]) / 2]) // doublecheck hole depth
          RoundedCube([mixSectionDimensions[0] - 2 * panWallDepth, mixSectionDimensions[1] - 2 * panWallDepth, mixSectionDimensions[2] + mixSectionBevelDimensions[2]], mixSectionBevelDimensions);
  };
  
// output dimensions
echo("WIDTH: ", bodyDimensions[0]);
echo("DEPTH: ", bodyDimensions[1]);
echo("HEIGHT: ", 2 * bodyDimensions[2]);
