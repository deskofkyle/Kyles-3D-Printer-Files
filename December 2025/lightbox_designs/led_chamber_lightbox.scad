// LED Chamber Lightbox Design
// Box with internal compartments for LED diffusion

// === DESIGN SELECTOR ===
design = 2;  // 1 = angular dividers, 2 = falling rounded squares

// === PARAMETERS ===
// Golden ratio throughout
phi = 1.618033988749;   // Golden ratio

// Overall dimensions (golden ratio rectangle)
box_width = 300;        // Total width (X) - longer side
box_depth = box_width / phi;  // Total depth (Y) ~185.4 - shorter side
box_height = 50;        // Wall height (Z)

// Wall parameters
wall_thickness = 4;     // Wall thickness
floor_thickness = 3;    // Bottom floor thickness

// Mounting holes
mount_hole_diameter = 2.7;  // M2.5 holes with clearance
mount_hole_inset = 12;      // Distance from edges
wiring_hole_diameter = 2.7; // M2.5 wiring holes with clearance

// Layout parameters
inset_percent = 0.20;   // 20% inset from edges for inner compartment

// === GOLDEN RATIO CALCULATED VALUES ===
// Inner compartment is also a golden rectangle
inner_width = box_width * (1 - 2 * inset_percent);  // 60% of outer width
inner_depth = inner_width / phi;                     // Golden ratio proportions

// Corner radius derived from smaller dimension
corner_radius = inner_depth / (phi * 6);  // ~6mm, proportional

// Divider at golden ratio position (61.8% from bottom)
divider_y_ratio = 1 / phi;  // ~0.618

// Gap is golden ratio proportion of divider length (doubled)
divider_gap = inner_width / (phi * 3) * 2;  // ~62mm

// === MODULES ===

// Module for mounting holes
module mounting_holes() {
    // Bottom-left
    translate([mount_hole_inset, mount_hole_inset, -1])
        cylinder(h = floor_thickness + 2, d = mount_hole_diameter, $fn = 32);
    // Bottom-right
    translate([box_width - mount_hole_inset, mount_hole_inset, -1])
        cylinder(h = floor_thickness + 2, d = mount_hole_diameter, $fn = 32);
    // Top-left
    translate([mount_hole_inset, box_depth - mount_hole_inset, -1])
        cylinder(h = floor_thickness + 2, d = mount_hole_diameter, $fn = 32);
    // Top-right
    translate([box_width - mount_hole_inset, box_depth - mount_hole_inset, -1])
        cylinder(h = floor_thickness + 2, d = mount_hole_diameter, $fn = 32);
}

module chamber_lightbox() {
    difference() {
        // Backplate only (no outer walls)
        cube([box_width, box_depth, floor_thickness]);
        mounting_holes();
    }

    // Gap size for light leaks
    gap = 30;
    h_y = box_depth * 0.40;
    v_x = box_width * 0.60;
    v2_x = box_width * 0.25;

    // Horizontal divider (40% from bottom) - gap on right, with wiring holes
    difference() {
        translate([0, h_y - wall_thickness/2, floor_thickness])
            cube([box_width * 0.7, wall_thickness, box_height - floor_thickness]);
        // Wiring holes in horizontal divider
        translate([box_width * 0.15, h_y, floor_thickness + (box_height - floor_thickness)/2])
            rotate([90, 0, 0])
            cylinder(h = wall_thickness + 2, d = wiring_hole_diameter, center = true, $fn = 32);
        translate([box_width * 0.45, h_y, floor_thickness + (box_height - floor_thickness)/2])
            rotate([90, 0, 0])
            cylinder(h = wall_thickness + 2, d = wiring_hole_diameter, center = true, $fn = 32);
    }

    // Vertical divider (60% from left) - gap at bottom, with wiring hole
    difference() {
        translate([v_x - wall_thickness/2, h_y + gap, floor_thickness])
            cube([wall_thickness, box_depth - h_y - gap, box_height - floor_thickness]);
        // Wiring hole
        translate([v_x, box_depth * 0.75, floor_thickness + (box_height - floor_thickness)/2])
            rotate([0, 90, 0])
            cylinder(h = wall_thickness + 2, d = wiring_hole_diameter, center = true, $fn = 32);
    }

    // Second vertical divider (25% from left) - bottom section, gap at top, with wiring hole
    difference() {
        translate([v2_x - wall_thickness/2, 0, floor_thickness])
            cube([wall_thickness, h_y - gap, box_height - floor_thickness]);
        // Wiring hole
        translate([v2_x, box_depth * 0.15, floor_thickness + (box_height - floor_thickness)/2])
            rotate([0, 90, 0])
            cylinder(h = wall_thickness + 2, d = wiring_hole_diameter, center = true, $fn = 32);
    }
}

// === DESIGN 2: Falling rounded squares ===
module falling_squares() {
    difference() {
        // Backplate only (no outer walls)
        cube([box_width, box_depth, floor_thickness]);
        mounting_holes();
    }

    // Rounded square parameters
    sq1_size = 70;
    sq2_size = 55;
    corner_r = 10;
    sq_wall = 4;  // Wall thickness for hollow squares
    sq1_x = box_width * 0.36;
    sq1_y = box_depth * 0.68;
    sq2_x = box_width * 0.64;
    sq2_y = box_depth * 0.32;

    // First rounded square - larger, tilted 15 degrees, upper left area (hollow)
    difference() {
        translate([sq1_x, sq1_y, floor_thickness])
            rotate([0, 0, 15])
            linear_extrude(box_height - floor_thickness)
            difference() {
                offset(r = corner_r)
                offset(delta = -corner_r)
                square([sq1_size, sq1_size], center = true);

                offset(r = corner_r - sq_wall)
                offset(delta = -(corner_r - sq_wall))
                square([sq1_size - 2*sq_wall, sq1_size - 2*sq_wall], center = true);
            }
        // Wiring holes on each side of square 1
        translate([sq1_x, sq1_y, floor_thickness + (box_height - floor_thickness)/2])
            rotate([0, 0, 15]) {
                // Top side
                translate([0, sq1_size/2, 0])
                    rotate([90, 0, 0])
                    cylinder(h = sq_wall + 2, d = wiring_hole_diameter, center = true, $fn = 32);
                // Right side
                translate([sq1_size/2, 0, 0])
                    rotate([0, 90, 0])
                    cylinder(h = sq_wall + 2, d = wiring_hole_diameter, center = true, $fn = 32);
            }
    }

    // Second rounded square - smaller, tilted -20 degrees, lower right area (hollow)
    difference() {
        translate([sq2_x, sq2_y, floor_thickness])
            rotate([0, 0, -20])
            linear_extrude(box_height - floor_thickness)
            difference() {
                offset(r = corner_r)
                offset(delta = -corner_r)
                square([sq2_size, sq2_size], center = true);

                offset(r = corner_r - sq_wall)
                offset(delta = -(corner_r - sq_wall))
                square([sq2_size - 2*sq_wall, sq2_size - 2*sq_wall], center = true);
            }
        // Wiring holes on each side of square 2
        translate([sq2_x, sq2_y, floor_thickness + (box_height - floor_thickness)/2])
            rotate([0, 0, -20]) {
                // Bottom side
                translate([0, -sq2_size/2, 0])
                    rotate([90, 0, 0])
                    cylinder(h = sq_wall + 2, d = wiring_hole_diameter, center = true, $fn = 32);
                // Left side
                translate([-sq2_size/2, 0, 0])
                    rotate([0, 90, 0])
                    cylinder(h = sq_wall + 2, d = wiring_hole_diameter, center = true, $fn = 32);
            }
    }
}

// Render based on design selection
if (design == 1) {
    chamber_lightbox();
} else if (design == 2) {
    falling_squares();
}

// === LAYOUT (top-down view) ===
//
//  +---------------------------------------+
//  |                                       |
//  |     (----------------------------)    |
//  |     (                            )    |
//  |     (      CHAMBER A (small)     )    |
//  |     (-------[  gap  ]------------)    |
//  |     (                            )    |
//  |     (                            )    |
//  |     (      CHAMBER B (large)     )    |
//  |     (                            )    |
//  |     (----------------------------)    |
//  |                                       |
//  +---------------------------------------+
//
// Golden ratio applied to:
// - Outer box proportions (width:depth = phi)
// - Box height (depth:height = phi)
// - Inner compartment proportions (golden rectangle)
// - Divider position (61.8% from bottom)
// - Gap size (proportional to phi)
// - Corner radius (proportional to phi)
