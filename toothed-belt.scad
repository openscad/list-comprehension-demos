use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <skin.scad>

// Path
path_definition = [
    trajectory(forward = 100, roll  =  180),
    trajectory(forward =  50, pitch = -150),
    trajectory(forward = 100, roll  = -180),
    trajectory(forward = 168, pitch =  210)
];

// Belt parameters
teeth = 40;
belt_width = 12;
tooth_height = 9;
belt_thickness = 3;

path = quantize_trajectories(path_definition, steps=teeth*4, loop=true, start_position=$t*4);

belt = [ for (i=[0:len(path)-1]) let(tooth=floor(i/2)%2)
    transform(path[i] *
              scaling([tooth?(tooth_height/belt_thickness):1,1,1]) *
              translation([belt_thickness/2,0,0]),
              rectangle_profile([belt_thickness,belt_width])
    )
];

looped_belt = concat(belt,[belt[0]]);
skin(looped_belt);


