use <scad-utils/transformations.scad>
use <scad-utils/lists.scad>
use <scad-utils/shapes.scad>
use <skin.scad>

fn=32;
r=50;
height=140;
layers = 10;
holesize = 80; //percent
difference() {
  skin([for (i=[0:layers-1]) 
	transform(translation([0,0,i*height/layers]) * rotation([0,0,-30*i]), circle($fn=6,r=r))]);
  translate([0,0,height/layers]) cylinder(r=r*holesize/100, h=height);
}
