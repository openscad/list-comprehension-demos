use <sweep.scad>

function f(t) = [
    (t / 1.5 + 0.5) * 100 * cos(6 * 360 * t),
    (t / 1.5 + 0.5) * 100 * sin(6 * 360 * t),
    200 * (1 - t)
];

function shape() = [
    [-10, -1],
    [-10,  6],
    [ -7,  6],
    [ -7,  1],
    [  7,  1],
    [  7,  6],
    [ 10,  6],
    [ 10, -1]];

step = 0.005;
path = [for (t=[0:step:1-step]) f(t)];
path_transforms = construct_transform_path(path);
sweep(shape(), path_transforms);
