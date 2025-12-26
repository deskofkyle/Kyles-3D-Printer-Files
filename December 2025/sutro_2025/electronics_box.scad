// Electronics Box for ElectroCookie 1/4 Breadboard
// Dimensions: 2" x 1.6" (50.8mm x 40.6mm)
// Features: Removable lid, USB-C port on short end

/* [Box Dimensions] */
// Inner dimensions (slightly larger than breadboard for clearance)
inner_length = 54;      // mm (breadboard is 50.8mm)
inner_width = 44;       // mm (breadboard is 40.6mm)
inner_height = 25;      // mm - adjust based on component height

/* [Wall Thickness] */
wall = 2;               // mm
lid_thickness = 2;      // mm

/* [Tolerances] */
lid_tolerance = 0.3;    // mm gap for lid fit

/* [USB-C Port] */
usbc_width = 9.5;       // mm (USB-C connector width)
usbc_height = 3.5;      // mm (USB-C connector height)
usbc_z_offset = 8;      // mm from bottom of inner floor

/* [Mounting] */
standoff_height = 3;    // mm
standoff_diameter = 5;  // mm
screw_hole_diameter = 2.2; // mm (M2 screws)
// Breadboard hole spacing from edges (approximate)
mount_inset_x = 3.2;    // mm from edge
mount_inset_y = 3.2;    // mm from edge

/* [Lid Lip] */
lip_height = 4;         // mm
lip_width = 1.5;        // mm

// Calculated dimensions
outer_length = inner_length + 2 * wall;
outer_width = inner_width + 2 * wall;
outer_height = inner_height + wall; // bottom wall only, lid separate

$fn = 32;

module rounded_box(length, width, height, radius) {
    hull() {
        for (x = [radius, length - radius]) {
            for (y = [radius, width - radius]) {
                translate([x, y, 0])
                    cylinder(r = radius, h = height);
            }
        }
    }
}

module box_base() {
    corner_radius = 3;

    difference() {
        // Outer shell
        rounded_box(outer_length, outer_width, outer_height, corner_radius);

        // Inner cavity
        translate([wall, wall, wall])
            rounded_box(inner_length, inner_width, inner_height + 1, corner_radius - wall/2);

        // USB-C cutout on short end (X = outer_length side)
        translate([outer_length - wall - 1, outer_width/2 - usbc_width/2, wall + usbc_z_offset])
            cube([wall + 2, usbc_width, usbc_height]);
    }

    // Mounting standoffs for breadboard
    translate([wall, wall, wall]) {
        // Four corners based on breadboard mounting holes
        for (x = [mount_inset_x, inner_length - mount_inset_x]) {
            for (y = [mount_inset_y, inner_width - mount_inset_y]) {
                translate([x, y, 0]) {
                    difference() {
                        cylinder(d = standoff_diameter, h = standoff_height);
                        cylinder(d = screw_hole_diameter, h = standoff_height + 1);
                    }
                }
            }
        }
    }
}

module lid() {
    corner_radius = 3;

    // Main lid plate
    difference() {
        rounded_box(outer_length, outer_width, lid_thickness, corner_radius);

        // Optional: ventilation holes (commented out)
        // for (x = [10 : 8 : outer_length - 10]) {
        //     for (y = [10 : 8 : outer_width - 10]) {
        //         translate([x, y, -1])
        //             cylinder(d = 3, h = lid_thickness + 2);
        //     }
        // }
    }

    // Inner lip that fits inside the box
    translate([wall + lid_tolerance, wall + lid_tolerance, -lip_height])
        difference() {
            rounded_box(inner_length - 2*lid_tolerance, inner_width - 2*lid_tolerance, lip_height, corner_radius - wall/2);
            translate([lip_width, lip_width, -1])
                rounded_box(inner_length - 2*lid_tolerance - 2*lip_width, inner_width - 2*lid_tolerance - 2*lip_width, lip_height + 2, corner_radius - wall);
        }
}

// Render
// Box base
box_base();

// Lid - positioned to the side for printing
translate([outer_length + 10, 0, lid_thickness])
    rotate([180, 0, 0])
        lid();

// Uncomment below to see lid in place (for visualization)
// translate([0, 0, outer_height])
//     lid();
