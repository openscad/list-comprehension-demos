use <scad-utils/lists.scad>

size = 20;
step = 0.5;

function f0(x, y) = sin(sqrt(pow(x, 2) + pow(y, 2)) * 180 / PI) + 2;
function f1(x, y) = sqrt(pow(x, 2) + pow(y, 2) + 3);

function f(x, y) = 20 * f0(x, y) / f1(x, y) + 4;

function p(x, y) = [ x, y, f(x, y) ];
function p0(x, y) = [ x, y, 0 ];
function rev(b, v) = b ? v : [ v[3], v[2], v[1], v[0] ];
function face(x, y) = [ p(x, y + step), p(x + step, y + step), p(x + step, y), p(x + step, y), p(x, y), p(x, y + step) ];
function fan(a, i) = 
      a == 0 ? [ [ 0, 0, 0 ], [ i, -size, 0 ], [ i + step, -size, 0 ] ]
    : a == 1 ? [ [ 0, 0, 0 ], [ i + step,  size, 0 ], [ i,  size, 0 ] ]
    : a == 2 ? [ [ 0, 0, 0 ], [ -size, i + step, 0 ], [ -size, i, 0 ] ]
    :          [ [ 0, 0, 0 ], [  size, i, 0 ], [  size, i + step, 0 ] ];
function sidex(x, y) = [ p0(x, y), p(x, y), p(x + step, y), p0(x + step, y) ];
function sidey(x, y) = [ p0(x, y), p(x, y), p(x, y + step), p0(x, y + step) ];

points = flatten(concat(
    // top surface
    [ for (x = [ -size : step : size - step ], y = [ -size : step : size - step ]) face(x, y) ],
    // bottom surface as triangle fan
    [ for (a = [ 0 : 3 ], i = [ -size : step : size - step ]) fan(a, i) ],
    // sides
    [ for (x = [ -size : step : size - step ], y = [ -size, size ]) rev(y < 0, sidex(x, y)) ],
    [ for (y = [ -size : step : size - step ], x = [ -size, size ]) rev(x > 0, sidey(x, y)) ]
));

tcount = 2 * pow(2 * size / step, 2) + 8 * size / step;
scount = 8 * size / step;

tfaces = [ for (a = [ 0 : 3 : 3 * (tcount - 1) ] ) [ a, a + 1, a + 2 ] ];
sfaces = [ for (a = [ 3 * tcount : 4 : 3 * tcount + 4 * scount ] ) [ a, a + 1, a + 2, a + 3 ] ];
faces = concat(tfaces, sfaces);

polyhedron(points, faces, convexity = 8);

// Written in 2015 by Torsten Paul <Torsten.Paul@gmx.de>
//
// To the extent possible under law, the author(s) have dedicated all
// copyright and related and neighboring rights to this software to the
// public domain worldwide. This software is distributed without any
// warranty.
//
// For details of the CC0 Public Domain Dedication see
// <http://creativecommons.org/publicdomain/zero/1.0/>.
