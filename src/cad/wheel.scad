$fn = 100;

wheel_r = 30;
wheel_h = 35;

groove_depth = 10;
groove_width = 15;

disc_r = 11;

wall = 1.2;

wheel_inner_r = wheel_r - groove_depth - wall;

center_hole_r = 3.1;

screw_holes = 4;
screw_hole_r = 1.5;
screw_hole_offset = 7;

tire_thickness = 6;
tire_r = 40;

module wheel_cross() {
    difference() {
        translate([0, -wheel_h / 2]) {
            square([wheel_r, wheel_h], center = false);
        }
        translate([wheel_r, 0]) {
            polygon([[0, -wheel_h / 2],
                [0, wheel_h / 2],
                [-groove_depth, groove_width / 2],
                [-groove_depth, -groove_width / 2]]);
        }
    }
}

module wheel_cross_hollow() {
    difference() {
        wheel_cross();
        offset(delta = -wall) {
            wheel_cross();
        }
        square([center_hole_r * 2, wheel_h], center = true);
        translate([0, wheel_h / 2 - wall]) {
            square([wheel_r - wall * 2, wall], center = false);
        }
    }
    translate([wheel_inner_r, -wheel_h / 2]) {
        square([wall, wheel_h / 2], center = false);
    }
}

module screw_holes() {
    for (i = [1:screw_holes]) {
        rotate([0, 0, i * 360 / screw_holes]) {
            translate([screw_hole_offset, 0, -wheel_h / 2]) {
                cylinder(h = wall, r = screw_hole_r);
            }
        }
    }
}

module spoke_holes() {
    hole_outer_r = wheel_inner_r;
    hole_inner_r = disc_r + 3;
    holes = 5;
    for(i = [1:holes]) {
        rotate([0, 0, i * 360 / holes]) {
            rotate_extrude(angle = 360 / holes * 0.5) {
                translate([hole_inner_r, -wheel_h / 2]) {
                    square([hole_outer_r - hole_inner_r, wall]);
                }
            }
        }
    }
}

module wheel() {
    difference() {
        rotate_extrude(angle = 360) {
            wheel_cross_hollow();
        }
        spoke_holes();
        screw_holes();
    }
}

module mold_base() {
    cross_section = [
        (tire_r - wheel_inner_r - tire_thickness) * 2,
        wheel_h - tire_thickness * 2
    ];
    intersection() {
        cylinder(h = wheel_h, r = tire_r + wall, center = true);
        rotate_extrude(angle = 180) {
            translate([tire_r + wall, 0]) {
                resize(cross_section) {
                    circle([wheel_r, wheel_h]);
                }
            }
        }
    }
}

module mold() {
    bubbles = 6;
    bubble_size = [20, 15, 7];
    bubble_z = wheel_h / 2 - tire_thickness;
    difference() {
        mold_base();
        for(i = [1:bubbles]) {
            rotate([0, 0, (0.5 - i) * 180 / bubbles]) {
                translate([-tire_r + groove_depth, 0, bubble_z]) {
                    resize(bubble_size) {
                        sphere(r = 1);
                    }
                }
                translate([-tire_r + groove_depth, 0, -bubble_z]) {
                    resize(bubble_size) {
                        sphere(r = 1);
                    }
                }
                translate([-wheel_inner_r - tire_thickness, 0, 0]) {
                    rotate([0, 90, 0]) {
                        resize(bubble_size * 0.7) {
                            sphere(r = 1);
                        }
                    }
                }
            }
        }
    }
}

module ring() {
    difference() {
        cylinder(h = tire_thickness, r = tire_r + wall, center = true);
        cylinder(h = tire_thickness, r = tire_r, center = true);
    }
}

module vessel_cross() {
    intersection() {
        minkowski() {
            wheel_cross_hollow();
            square([tire_r, 0.0001]);
        }
        square([(tire_r + wall) * 2, wheel_h], center = true);
    }
}

module vessel_cross_hollow() {
    tolerance = 0.5;
    difference() {
        offset(delta = wall + tolerance) {
            vessel_cross();
        }
        offset(delta = tolerance) {
            vessel_cross();
        }
        translate([0, -wheel_h / 2 - wall - tolerance]) {
            square([tire_r + wall * 2 + tolerance, wall + tolerance],
                center = false);
            square([wheel_inner_r - wall - tolerance, wheel_h / 2],
                center = false);
        }
    }
}

module vessel() {
    rotate_extrude(angle = 360) {
        vessel_cross_hollow();
    }
}

module preview() {
    difference() {
        cylinder(h = wheel_h, r = tire_r, center = true);
        mold();
        rotate([0, 0, 180]) {
            mold();
        }
        rotate_extrude(angle = 360) {
            wheel_cross();
        }
    }
}
