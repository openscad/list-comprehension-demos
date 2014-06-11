use <sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>

function func0(x)= 1;
function func1(x) = 30 * sin(180 * x);
function func2(x) = -30 * sin(180 * x);
function func3(x) = (sin(270 * (1 - x) - 90) * sqrt(6 * (1 - x)) + 2);
function func4(x) = 180 * x / 2;
function func5(x) = 2 * 180 * x * x * x;
function func6(x) = 3 - 2.5 * x;

pathstep = 1;
height = 100;

shape_points = square(10);
path_transforms1 = [for (i=[0:pathstep:height]) let(t=i/height) translation([func1(t),func1(t),i]) * rotation([0,0,func4(t)])];
path_transforms2 = [for (i=[0:pathstep:height]) let(t=i/height) translation([func2(t),func2(t),i]) * rotation([0,0,func4(t)])];
path_transforms3 = [for (i=[0:pathstep:height]) let(t=i/height) translation([func1(t),func2(t),i]) * rotation([0,0,func4(t)])];
path_transforms4 = [for (i=[0:pathstep:height]) let(t=i/height) translation([func2(t),func1(t),i]) * rotation([0,0,func4(t)])];
sweep(shape_points, path_transforms1);
sweep(shape_points, path_transforms2);
sweep(shape_points, path_transforms3);
sweep(shape_points, path_transforms4);


path_transforms5 = [for (i=[0:pathstep:height]) let(t=i/height) translation([0,0,i]) * scaling([func3(t),func3(t),i]) * rotation([0,0,func4(t)])];
translate([100, 0, 0]) sweep(shape_points, path_transforms5);


path_transforms6 = [for (i=[0:pathstep:height]) let(t=i/height) translation([0,0,i]) * scaling([func6(t),func6(t),i]) * rotation([0,0,func5(t)])];
translate([-100, 0, 0]) sweep(shape_points, path_transforms6);
