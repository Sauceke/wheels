$fn = 50;

servo_l = 40.5;
servo_w = 20.5;
cable_w = 10;

mount_h = 25;
wall = 2;
spacing = 25;

finger_d = 25;
palm_w = finger_d * 4;

module servo_base() {
    square([servo_l, servo_w], center = true);
}

module ziptie_stopper() {
    stopper_x = -10;
    stopper_groove = 5;
    translate([stopper_x, -servo_w / 2 - 5]) {
        square([wall, 5], center = false);
    }
    translate([stopper_x + stopper_groove + wall, -servo_w / 2 - 5]) {
        square([wall, 5], center = false);
    }
}

module servo_mount() {
    linear_extrude(height = wall) {
        servo_base();
    }
    linear_extrude(height = mount_h) {
        difference() {
            offset(delta = wall) {
                servo_base();
            }
            servo_base();
            translate([servo_l / 2, -cable_w / 2]) {
                square([wall, cable_w], center = false);
            }
        }
        ziptie_stopper();
        mirror([0, 1, 0]) {
            ziptie_stopper();
        }
    }
}

module frame() {
    translate([(servo_l + spacing) / 2, 0, 0]) {
        servo_mount();
    }
    mirror([1, 0, 0]) {
        translate([(servo_l + spacing) / 2, 0, 0]) {
            servo_mount();
        }
    }
    translate([-spacing / 2, -servo_w / 2 - wall, 0]) {
        cube([spacing, servo_w + 2 * wall, mount_h], center = false);
    }
}

module handle_hole_half() {
    brace_slope = 20;
    polygon([
        [-mount_h / 2, palm_w / 2],
        [mount_h / 2 + finger_d, palm_w / 2],
        [mount_h / 2 + finger_d + brace_slope, spacing / 2],
        [mount_h / 2 + finger_d + brace_slope, 0],
        [-mount_h / 2, 0]
    ]);
}

module handle_hole() {
    handle_hole_half();
    mirror([0, 1, 0]) {
        handle_hole_half();
    }
}

module handle() {
    handle_th = 5;
    linear_extrude(height = mount_h, center = true) {
        difference() {
            offset(delta = handle_th) {
                handle_hole();
            }
            handle_hole();
            square([mount_h + handle_th * 2, palm_w], center = true);
        }
    }
    rotate([90, 0, 0]) {
        cylinder(h = palm_w, d = mount_h - 2, center = true);
        for (i = [0 : 10 : 360]) {
            rotate([0, 0, i]) {
                translate([mount_h / 2 - 1, 0, 0]) {
                    cylinder(h = palm_w, d = 2, center = true);
                }
            }
        }
    }
}

module main() {
    handle_y = servo_w / 2 + finger_d + mount_h / 2 + wall + 20 + 5;
    translate([0, handle_y, mount_h / 2]) {
        rotate([0, 0, -90])
        handle();
    }
    frame();
}

main();
