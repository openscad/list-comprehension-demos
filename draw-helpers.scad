// Needs the obiscad tools from https://github.com/Obijuan/obiscad
use <obiscad/vector.scad>
module draw_path(path, r=1) {
    for (i=[0:len(path)-2]) {
        hull() {
            translate(path[i]) sphere(r);
            translate(path[i+1]) sphere(r);
        }
    }
}

module draw_transforms(transforms, r=1) {
    for (i=[0:len(transforms)-1]) {
        multmatrix(transforms[i]) scale(r/3) frame(10);
    }
}
