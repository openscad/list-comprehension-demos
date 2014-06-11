use <sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>

function drop(t) = 100 * 0.5 * (1 - cos(180 * t)) * sin(180 * t) + 1;
function path(t) = [0, 0, 80 + 80 * cos(180 * t)];
function rotate(t) = 180 * pow((1 - t), 3);

$fn=12;
function shape() = circle(1);

step = 0.01;
path_transforms = [for (t=[0:step:1-step]) translation(path(t)) * rotation([0,0,rotate(t)]) * scaling([drop(t), drop(t), 1])];
sweep(shape(), path_transforms);
