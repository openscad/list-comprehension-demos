/****************************************************************************
 *  Superformula
 *  (c) 2014 Torsten Paul <Torsten.Paul@gmx.de>
 *  License: CC-BY-SA 3.0
 *
 *  See http://en.wikipedia.org/wiki/Superformula
 */

// Display configuration
gridx = 50;
gridy = 50;
columns = 3;
height = 4;
angle_step = 2;

// Parameters of the superformula (with an additional scale
// factor to make the resulting objects roughly the same size).
a =  [  1,   1, 1,   1,   1,  1, 1000,   1,   3,   1,   1,  4];
b =  [  1,   1, 1,   1,   1,  1,  200, 0.6,   2,   1,   3,  3];
m =  [  3,   1, 5,   8,  16,  6,   52,  30,   6,   6,   6, 30];
n1 = [4.5, 0.5, 2, 0.5, 0.5,  1,    8,  75, 1.5, 0.4, 3.8,  6];
n2 = [ 10, 0.5, 7, 0.5, 0.5,  7,    3, 1.5, 0.5,   0,  16,  7];
n3 = [ 10, 0.5, 7,  10,  16,  8,    2,  35,   2,   6,  10,  3];
f  = [ 10,  22, 8,  12,  10,  2,    3,  10,   8,  15, 0.8,  4]; // scale factor

// helper function
function r1(phi, idx) = pow(abs(cos(m[idx] * phi / 4) / a[idx]), n2[idx]);
function r2(phi, idx) = pow(abs(sin(m[idx] * phi / 4) / b[idx]), n3[idx]);

// main superformula returning the radius for a given angle phi
function r(phi, idx) = f[idx] * pow(abs(r1(phi, idx) + r2(phi, idx)), -1 / n1[idx]);

// convert polar coordinates to cartesian coordinates
function point(phi, idx) = [ r(phi, idx) * cos(phi), r(phi, idx) * sin(phi)];

// function to collect all points in 360 degrees
function points(angle, idx) = [for (i=[0:angle_step:360-angle_step]) point(i, idx)];

for (idx = [0 : len(m) - 1])
	translate([gridx * (idx % columns), gridy * floor(idx / columns), 0])
		linear_extrude(height = height, scale = 0)
			polygon(points(0, idx));
