// by Les Hall
// started 4-16-2014
// Generalized to use sweep() by Marius Kintel

use <sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <scad-utils/linalg.scad>
use <draw-helpers.scad>

amplitude = 1.5;
margin = 0.1;
numRings = 4;
numRolls = 3;
separationAngle = 360 / numRings;
shapeRadius = amplitude * sin(separationAngle/2) - 2*margin;
ringDiameter = 14.88 + amplitude + shapeRadius;
numSegments = 100;

function shape() = circle(shapeRadius, $fn=16);

function f(t, i) = take3(
    rotation([0,0,t*360]) *
    translation([ringDiameter/2, 0, 0]) *
    rotation([-90,0,0]) *
    rotation([0,0,i*separationAngle + t*360*numRolls]) *
    translation([amplitude, 0, 0]) * [0,0,0,1]);

for (i=[0:numRings-1]) {
  assign (path = [ for (t = [0:1/numSegments:1]) f(t, i) ]) {
      assign(path_transforms = construct_transform_path(path)) {
        sweep(shape(), path_transforms, true);
      }
  }
}
