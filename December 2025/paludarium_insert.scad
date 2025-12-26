// Paludarium Insert with False Bottom, Serpentine River, and Waterfall
// Dimensions based on paludarium: 23.6" x 14.17" x 5.51"(front) to 14.17"(back)
// Optimized for faster OpenSCAD rendering

/* [Main Dimensions] */
// Overall length (X axis) in mm
length = 599;  // 23.6 inches
// Overall width (Y axis) in mm
width = 360;   // 14.17 inches
// Front height in mm
front_height = 140;  // 5.51 inches
// Back height in mm
back_height = 360;   // 14.17 inches

/* [False Bottom] */
// Height of water reservoir in mm
reservoir_height = 102;  // ~4 inches
// Egg crate grid cell size
grid_cell_size = 30;  // Larger cells = faster render
// Egg crate wall thickness
grid_wall_thickness = 4;
// False bottom plate thickness
plate_thickness = 5;

/* [Structure] */
// Wall thickness for main structure
wall_thickness = 4;
// Terrain surface thickness
terrain_thickness = 8;

/* [Rock Shelves] */
// Number of rock shelves on each side of river
num_shelves = 4;
// Shelf depth into terrain
shelf_depth = 60;
// Shelf lip height (retaining edge)
shelf_lip = 15;
// Minimum shelf width
shelf_width_min = 80;
// Maximum shelf width
shelf_width_max = 150;

/* [Serpentine River] */
// River channel width
river_width = 50;
// River channel depth
river_depth = 28;
// Number of serpentine curves (more = more winding)
river_curves = 4;
// Amplitude of serpentine (how far it swings left/right) - INCREASED
river_amplitude = 120;
// River segments (lower = faster render, higher = smoother)
river_segments = 40;

/* [Waterfall Channel] */
// Inner diameter of tube channel
tube_inner_diameter = 20;  // Fits 3/4" tubing
// Wall thickness around tube
tube_wall = 3;
// Tube exit height from top
tube_exit_offset = 30;
// Waterfall spout width
spout_width = 50;
// Waterfall spout depth
spout_depth = 15;

/* [Modularity - for splitting later] */
// Number of sections along X axis
sections_x = 3;
// Number of sections along Y axis
sections_y = 2;

/* [Rendering Quality] */
// Global resolution (lower = faster preview)
$fn = 16;

// Small value for boolean operations
eps = 0.1;

// ==================== HELPER FUNCTIONS ====================

// Get height at any Y position along the slope
function height_at_y(y) = front_height + (back_height - front_height) * (y / width);

// Get the river X position at any Y (serpentine path) - more dramatic curves
function river_x_at_y(y) =
    length/2 + river_amplitude * sin((y / width) * river_curves * 360 + 45);

// ==================== MODULES ====================

// Egg crate false bottom - simplified
module egg_crate_bottom() {
    cell_with_wall = grid_cell_size + grid_wall_thickness;

    // Base plate with grid cutouts
    difference() {
        cube([length, width, plate_thickness]);

        // Grid cutouts - use larger cells
        for (x = [grid_wall_thickness : cell_with_wall : length - grid_cell_size]) {
            for (y = [grid_wall_thickness : cell_with_wall : width - grid_cell_size]) {
                translate([x, y, -eps])
                    cube([grid_cell_size, grid_cell_size, plate_thickness + 2*eps]);
            }
        }
    }

    // Simplified support grid - just walls, no legs
    leg_spacing = 100;  // Wider spacing
    leg_width = 4;

    for (x = [0 : leg_spacing : length]) {
        translate([x, 0, -reservoir_height + plate_thickness])
            cube([leg_width, width, reservoir_height - plate_thickness]);
    }
    for (y = [0 : leg_spacing : width]) {
        translate([0, y, -reservoir_height + plate_thickness])
            cube([length, leg_width, reservoir_height - plate_thickness]);
    }
}

// Cross section of river channel (rounded bottom)
module river_cross_section() {
    hull() {
        translate([-river_width/2 + 8, 0, river_depth - 8])
            sphere(r = 8, $fn = 12);
        translate([river_width/2 - 8, 0, river_depth - 8])
            sphere(r = 8, $fn = 12);
        translate([-river_width/2, 0, river_depth + 10])
            cube([river_width, eps, 30]);
    }
}

// Serpentine river channel
module river_channel() {
    segments = 50;
    segment_length = width / segments;

    for (i = [0 : segments - 1]) {
        y1 = i * segment_length;
        y2 = (i + 1) * segment_length;
        x1 = river_x_at_y(y1);
        x2 = river_x_at_y(y2);
        z1 = height_at_y(y1) - river_depth;
        z2 = height_at_y(y2) - river_depth;

        hull() {
            translate([x1, y1, z1])
                river_cross_section();
            translate([x2, y2, z2])
                river_cross_section();
        }
    }
}

// Cascading pools along the river
module river_pools() {
    pool_count = 5;
    pool_spacing = width / (pool_count + 1);

    for (i = [1 : pool_count]) {
        y_pos = i * pool_spacing;
        x_pos = river_x_at_y(y_pos);
        z_pos = height_at_y(y_pos);

        translate([x_pos, y_pos, z_pos - river_depth - 10])
            scale([1.5, 1, 0.5])
                sphere(r = river_width * 0.7, $fn = 16);
    }
}

// Solid river bed - ensures water doesn't fall through
module river_bed() {
    segments = 50;
    segment_length = width / segments;
    bed_width = river_width + 20;  // Slightly wider than river for support

    for (i = [0 : segments - 1]) {
        y1 = i * segment_length;
        y2 = (i + 1) * segment_length;
        x1 = river_x_at_y(y1);
        x2 = river_x_at_y(y2);

        // Extend from reservoir all the way up to river floor + overlap
        // This guarantees no gaps regardless of hollowing
        z1_bottom = reservoir_height;
        z2_bottom = reservoir_height;
        z1_top = height_at_y(y1) - 10;  // Overlap into river channel
        z2_top = height_at_y(y2) - 10;

        hull() {
            translate([x1 - bed_width/2, y1, z1_bottom])
                cube([bed_width, eps, z1_top - z1_bottom]);
            translate([x2 - bed_width/2, y2, z2_bottom])
                cube([bed_width, eps, z2_top - z2_bottom]);
        }
    }

    // Also add solid floors under the pools
    pool_count = 5;
    pool_spacing = width / (pool_count + 1);

    for (i = [1 : pool_count]) {
        y_pos = i * pool_spacing;
        x_pos = river_x_at_y(y_pos);
        z_pos = height_at_y(y_pos);

        // Pool floors - full height columns
        translate([x_pos, y_pos, reservoir_height])
            cylinder(h = z_pos - reservoir_height - 5, d = river_width * 1.8, $fn = 24);
    }
}

// Main terrain slope - simplified
module terrain_slope() {
    difference() {
        // Solid sloped terrain body using polyhedron for speed
        hull() {
            translate([0, 0, reservoir_height])
                cube([length, eps, front_height - reservoir_height]);
            translate([0, width - eps, reservoir_height])
                cube([length, eps, back_height - reservoir_height]);
        }

        // Carve out the river channel
        river_channel();

        // Pool areas
        river_pools();

        // Hollow underneath - simple box
        translate([wall_thickness * 3, wall_thickness * 3, reservoir_height + wall_thickness])
            hull() {
                cube([length - wall_thickness * 6, eps, front_height - reservoir_height - terrain_thickness * 2]);
                translate([0, width - wall_thickness * 6, 0])
                    cube([length - wall_thickness * 6, eps, back_height - reservoir_height - terrain_thickness * 3]);
            }
    }
}

// Rock shelf - simplified geometry
module rock_shelf(w, d, z, side) {
    translate([0, 0, z - shelf_depth]) {
        difference() {
            // Simple box platform
            cube([d, w, shelf_depth]);

            // Bowl using cylinder (faster than sphere)
            translate([d/2, w/2, shelf_depth - 15])
                cylinder(h = 20, d1 = min(d, w) * 0.7, d2 = min(d, w) * 0.9);
        }

        // Retaining lip
        if (side == "left") {
            translate([d - 5, 0, 0])
                cube([5, w, shelf_lip]);
        } else {
            cube([5, w, shelf_lip]);
        }
    }
}

// Rock shelves positioned along river
module rock_shelves() {
    shelf_spacing = width / (num_shelves + 1);

    for (i = [1 : num_shelves]) {
        y_pos = i * shelf_spacing;
        river_x = river_x_at_y(y_pos);
        z_base = height_at_y(y_pos);

        shelf_w = shelf_width_min + (shelf_width_max - shelf_width_min) * ((i % 2 == 0) ? 0.3 : 0.8);

        // Left side shelf
        left_space = river_x - river_width/2 - wall_thickness;
        if (left_space > 60) {
            shelf_d = min(left_space - 30, 120);
            translate([wall_thickness + 10, y_pos - shelf_w/2, 0])
                rock_shelf(shelf_w, shelf_d, z_base, "left");
        }

        // Right side shelf
        right_space = length - river_x - river_width/2 - wall_thickness;
        if (right_space > 60) {
            shelf_d = min(right_space - 30, 120);
            translate([river_x + river_width/2 + 20, y_pos - shelf_w/2, 0])
                rock_shelf(shelf_w, shelf_d, z_base, "right");
        }
    }
}

// Corner rock areas - simplified
module corner_rock_areas() {
    corner_size = 100;

    // Front-left corner
    translate([wall_thickness, wall_thickness, reservoir_height])
    difference() {
        cube([corner_size, corner_size, 35]);
        translate([corner_size/2, corner_size/2, 15])
            cylinder(h = 25, d1 = 60, d2 = 80);
    }

    // Front-right corner
    translate([length - wall_thickness - corner_size, wall_thickness, reservoir_height])
    difference() {
        cube([corner_size, corner_size, 35]);
        translate([corner_size/2, corner_size/2, 15])
            cylinder(h = 25, d1 = 60, d2 = 80);
    }

    // Back-left corner (larger)
    translate([wall_thickness, width - wall_thickness - corner_size * 1.3, reservoir_height])
    difference() {
        cube([corner_size * 1.2, corner_size * 1.3, back_height - reservoir_height - 60]);
        // Rock pockets using cylinders
        for (dx = [0.3, 0.7]) {
            for (dy = [0.35, 0.7]) {
                translate([corner_size * 1.2 * dx, corner_size * 1.3 * dy, 40])
                    cylinder(h = back_height, d = 70);
            }
        }
    }

    // Back-right corner
    translate([length - wall_thickness - corner_size, width - wall_thickness - corner_size * 1.2, reservoir_height])
    difference() {
        cube([corner_size, corner_size * 1.2, back_height - reservoir_height - 80]);
        for (dx = [0.35, 0.65]) {
            translate([corner_size * dx, corner_size * 0.6, 30])
                cylinder(h = back_height, d = 60);
        }
    }
}

// Waterfall tube channel - simplified
module tube_channel() {
    tube_outer = tube_inner_diameter + 2 * tube_wall;

    // Position at back where river starts
    channel_x = river_x_at_y(width - 10);
    channel_y = width - tube_outer/2 - wall_thickness - 5;

    difference() {
        union() {
            // Vertical tube housing
            translate([channel_x, channel_y, 0])
                cylinder(h = back_height - tube_exit_offset, d = tube_outer);

            // Spout body
            translate([channel_x - spout_width/2, channel_y - 25, back_height - tube_exit_offset - 10])
                cube([spout_width, 30, 15]);

            // Spout lip
            translate([channel_x - spout_width/2 + 5, channel_y - 45, back_height - tube_exit_offset - 20])
                cube([spout_width - 10, 25, 12]);
        }

        // Inner tube cavity
        translate([channel_x, channel_y, -eps])
            cylinder(h = back_height, d = tube_inner_diameter);

        // Spout channel
        translate([channel_x - spout_width/2 + 8, channel_y - 50, back_height - tube_exit_offset - 18])
            cube([spout_width - 16, 50, 8]);

        // Bottom entry hole
        translate([channel_x, channel_y, -eps])
            cylinder(h = reservoir_height + 2*eps, d = tube_inner_diameter + 5);
    }
}

// Basin drain where river ends
module basin_drain() {
    drain_x = river_x_at_y(0);

    translate([drain_x, wall_thickness, reservoir_height])
    difference() {
        cylinder(h = 25, d1 = river_width + 30, d2 = river_width);
        translate([0, 0, -eps])
            cylinder(h = 30, d1 = river_width + 10, d2 = river_width - 15);
    }
}

// Basin perimeter walls
module basin_walls() {
    difference() {
        cube([length, width, reservoir_height]);
        translate([wall_thickness, wall_thickness, wall_thickness])
            cube([length - 2*wall_thickness, width - 2*wall_thickness, reservoir_height]);
    }
}

// Section cutter for modularity
module section_cutter(sx, sy) {
    section_length = length / sections_x;
    section_width = width / sections_y;

    translate([section_length * sx, section_width * sy, -eps])
        cube([section_length, section_width, back_height + 2*eps]);
}

// ==================== ASSEMBLY ====================

module complete_insert() {
    union() {
        // BASE (toggled off for now)
        // color("SteelBlue", 0.9)
        //     basin_walls();

        // color("SlateGray", 0.8)
        // translate([0, 0, reservoir_height - plate_thickness])
        //     egg_crate_bottom();

        // SURFACE
        color("SaddleBrown", 0.85)
            terrain_slope();

        // Solid river bed floor
        color("SaddleBrown", 0.9)
            river_bed();

        color("Sienna", 0.9)
            rock_shelves();

        color("Peru", 0.9)
            corner_rock_areas();

        // color("SteelBlue", 0.9)
        //     basin_drain();

        color("DarkSlateGray", 0.9)
            tube_channel();
    }
}

module get_section(sx, sy) {
    intersection() {
        complete_insert();
        section_cutter(sx, sy);
    }
}

// Visualize just the river path
module show_river_path() {
    color("DodgerBlue", 0.8)
        river_channel();
    color("RoyalBlue", 0.8)
        river_pools();
}

// Show only top surface (no side walls)
module surface_only() {
    inset = wall_thickness + 5;  // How much to clip from edges

    intersection() {
        complete_insert();

        // Clipping box - removes outer walls
        translate([inset, inset, reservoir_height + 10])
            cube([length - 2*inset, width - 2*inset, back_height]);
    }
}

// ==================== RENDER ====================

// Full assembly
// complete_insert();

// Surface only (no side walls) - ACTIVE
surface_only();

// River path only - uncomment to visualize flow
// show_river_path();

// Individual sections for printing:
// get_section(0, 0);  // Front-left
// get_section(1, 0);  // Front-middle
// get_section(2, 0);  // Front-right
// get_section(0, 1);  // Back-left
// get_section(1, 1);  // Back-middle
// get_section(2, 1);  // Back-right
