use <scad-utils/transformations.scad>
use <sweep.scad>

r = 10;
h = 20;
w = 2;
s = 2;
step = 4;

shape = [[0,0,0], [w,0,0], [w,1,0], [0,1,0]];

path = [for (a=[0:step:360-step])
    rotation([90,0,a]) * translation([r,0,0]) * scaling([1,h+s*sin(a*6), 1])
];

sweep(shape, path, true);
