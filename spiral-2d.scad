include <list-comprehension-demos/sweep.scad>
include <scad-utils/shapes.scad>

sweep(square(10),
      [for(t = [0:0.001:1]) rotation(t*7200) * translation([10+500*t,0,0])]);
