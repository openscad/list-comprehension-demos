use <sweep.scad>
use <scad-utils/shapes.scad>

function f(a,b,t) =   // rolling knot 
 [ a * cos (3 * t) / (1 - b* sin (2 *t)), 
   a * sin( 3 * t) / (1 - b* sin (2 *t)), 
   1.8 * b * cos (2 * t) /(1 - b* sin (2 *t)) 
 ]; 

a = 0.8; 
b = sqrt (1 - a * a); 

function shape() = circle(60, $fn=48);

step = 0.005;
path = [for (t=[0:step:1-step]) 200 * f(a,b,t*360)];
path_transforms = construct_transform_path(path);
sweep(shape(), path_transforms, true);
