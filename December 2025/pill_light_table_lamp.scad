// Pill-Shaped Light Sculpture - TABLE LAMP VERSION
// 20 sheets of 3mm satinice acrylic
// Scales from 50% at ends to 100% at center
// Electronics exit through bottom for table lamp stand
//
// === Mathematical Easter Egg ===
// Golden Ratio (φ): Length/Width ratio = 1.618...

// === Parameters ===
phi = (1 + sqrt(5)) / 2;  // Golden ratio φ ≈ 1.618033988749895

// Golden ratio proportions: length = width * φ
max_width = 150;                  // Base width
max_length = max_width * phi;     // Length follows golden ratio (~242.7mm)
sheet_thickness = 3;     // Thickness of each acrylic sheet
num_sheets = 20;         // Number of sheets
min_scale_length = 1/2;  // Scale factor for length/X at ends (50%)
min_scale_width = 1/3;   // Scale factor for width/Y at ends (33%)

// Calculated values
total_depth = num_sheets * sheet_thickness;  // 60mm total

// Back plate settings
mounting_hole_diameter = 4;      // M4 screws
mounting_hole_inset = 15;        // Distance from edge to hole center
hollow_wall_thickness = 10;      // Wall thickness for back plate hollow
ring_wall_thickness = 15;        // Wall thickness for ring layers (enough for overlap)

// === LED H-Structure Parameters ===
h_pole_size = 5;                                    // 5mm x 5mm square poles
h_pole_wall = 1.2;                                  // Wall thickness for hollow poles
h_bar_length = max_width * 0.65;                    // Top/bottom bars along X (65% of width = 97.5mm)
h_crossbar_span = total_depth * 0.65 * 1.35;        // Crossbar along Y (~53mm)
h_vertical_spacing = 20;                            // Vertical pole connecting two H's
h_stand_pole_length = 80;                           // Length of pole extending down for lamp stand

// === Lamp Base Parameters ===
base_size = 80;                                     // Size of square base
base_height = 25;                                   // Height/thickness of base
base_pole_socket_depth = 15;                        // How deep the pole sits into the base

// === Visibility Toggles ===
show_base = true;                // Toggle base visibility
show_sculpture = true;           // Toggle sculpture visibility
show_led_structure = true;       // Toggle H structure visibility
show_bottom_half = false;         // Toggle bottom 10 layers (0-9)
show_top_half = true;            // Toggle top 10 layers (10-19)

// Check if layer should be visible based on toggles
function is_visible(index, total) =
    (show_bottom_half && index < 10) || (show_top_half && index >= 10);

// === Modules ===

// Pill shape (stadium/discorectangle)
module pill_shape(length, width, thickness) {
    radius = width / 2;
    linear_length = length - width;  // Length of the straight section

    linear_extrude(height = thickness) {
        hull() {
            // Left semicircle
            translate([-linear_length/2, 0, 0])
                circle(r = radius, $fn = 64);
            // Right semicircle
            translate([linear_length/2, 0, 0])
                circle(r = radius, $fn = 64);
        }
    }
}

// Calculate scale factor for a given sheet index
// Uses sine interpolation for smooth transition
function get_scale(index, total, min_scale) =
    min_scale + (1 - min_scale) * sin(index / (total - 1) * 180);

// Ring layer - hollow pill for interior layers
module ring_layer(length, width, thickness) {
    difference() {
        pill_shape(length, width, thickness);

        inner_length = length - 2 * ring_wall_thickness;
        inner_width = width - 2 * ring_wall_thickness;
        translate([0, 0, -0.1])
            pill_shape(inner_length, inner_width, thickness + 0.2);
    }
}

// Center layer - outer pill with H-shaped interior (single cut piece)
// The interior cutout leaves solid material where the H structure bars are
module ring_layer_with_screw_holes(length, width, thickness) {
    screw_hole_d = 3;  // M3 screw holes
    tab_width = 15;    // Width of H-bar mounting areas

    // Positions for H bars
    top_bar_y = h_crossbar_span/2 - h_pole_size/2;
    bottom_bar_y = -h_crossbar_span/2 + h_pole_size/2;

    difference() {
        // Outer pill shape
        pill_shape(length, width, thickness);

        // Cut 4 quadrant holes instead of one big center hole
        // This leaves an H-pattern of solid material

        // Top-left quadrant cutout
        translate([-(h_bar_length/2 + ring_wall_thickness)/2, (top_bar_y + tab_width/2 + ring_wall_thickness)/2, -0.1])
            cube([h_bar_length/2, top_bar_y - tab_width/2, thickness + 0.2], center=true);

        // Top-right quadrant cutout
        translate([(h_bar_length/2 + ring_wall_thickness)/2, (top_bar_y + tab_width/2 + ring_wall_thickness)/2, -0.1])
            cube([h_bar_length/2, top_bar_y - tab_width/2, thickness + 0.2], center=true);

        // Bottom-left quadrant cutout
        translate([-(h_bar_length/2 + ring_wall_thickness)/2, (bottom_bar_y - tab_width/2 - ring_wall_thickness)/2, -0.1])
            cube([h_bar_length/2, abs(bottom_bar_y) - tab_width/2, thickness + 0.2], center=true);

        // Bottom-right quadrant cutout
        translate([(h_bar_length/2 + ring_wall_thickness)/2, (bottom_bar_y - tab_width/2 - ring_wall_thickness)/2, -0.1])
            cube([h_bar_length/2, abs(bottom_bar_y) - tab_width/2, thickness + 0.2], center=true);

        // Screw holes along top H bar
        for (x = [-h_bar_length/3, 0, h_bar_length/3]) {
            translate([x, top_bar_y, -0.1])
                cylinder(h = thickness + 0.2, d = screw_hole_d, $fn = 16);
        }

        // Screw holes along bottom H bar
        for (x = [-h_bar_length/3, 0, h_bar_length/3]) {
            translate([x, bottom_bar_y, -0.1])
                cylinder(h = thickness + 0.2, d = screw_hole_d, $fn = 16);
        }
    }
}

// Bottom plate with hole for stand pole (no mounting holes needed for table lamp)
module bottom_plate(length, width, thickness) {
    difference() {
        // Outer pill shape
        pill_shape(length, width, thickness);

        // Hollow center
        inner_length = length - 2 * hollow_wall_thickness;
        inner_width = width - 2 * hollow_wall_thickness;
        translate([0, 0, -0.1])
            pill_shape(inner_length, inner_width, thickness + 0.2);

        // Center hole for stand pole
        translate([0, 0, -0.1])
            cylinder(h = thickness + 0.2, d = h_pole_size + 1, $fn = 32);
    }
}

// === LED H-Structure Module ===

// Hollow square pole module
module hollow_pole(length, width, height) {
    inner = h_pole_size - 2*h_pole_wall;
    difference() {
        cube([length, width, height], center=true);
        cube([length + 0.1, inner, inner], center=true);
        cube([inner, width + 0.1, inner], center=true);
        cube([inner, inner, height + 0.1], center=true);
    }
}

// Lamp base - square base with socket for stand pole
module lamp_base() {
    difference() {
        // Main base cube (centered on X/Y)
        translate([-base_size/2, -base_size/2, 0])
            cube([base_size, base_size, base_height]);

        // Socket hole for stand pole
        translate([0, 0, base_height - base_pole_socket_depth])
            cylinder(h = base_pole_socket_depth + 0.1, d = h_pole_size + 0.5, $fn = 32);

        // Wire channel through center
        translate([0, 0, -0.1])
            cylinder(h = base_height - base_pole_socket_depth + 0.2, d = 8, $fn = 32);
    }
}

// Single H shape from hollow square poles
// Viewed from top-down (Z axis): H shape in X-Y plane
//   -----      <- top bar along X
//     |        <- crossbar along Y
//   -----      <- bottom bar along X
module single_h() {
    // Top horizontal bar (runs along X)
    translate([0, h_crossbar_span/2 - h_pole_size/2, 0])
        hollow_pole(h_bar_length, h_pole_size, h_pole_size);

    // Bottom horizontal bar (runs along X)
    translate([0, -h_crossbar_span/2 + h_pole_size/2, 0])
        hollow_pole(h_bar_length, h_pole_size, h_pole_size);

    // Vertical crossbar (runs along Y, connects top and bottom)
    hollow_pole(h_pole_size, h_crossbar_span, h_pole_size);
}


// === Color Settings ===
outer_color = [0.3, 0.5, 0.9, 0.8];  // Blue for outer layers
inner_color = [1, 0.6, 0.2, 0.8];    // Orange for inner layers
outer_layer_count = 4;               // Number of layers on each end considered "outer"

// Calculate color blend based on position (0 = outer, 1 = inner)
function get_color_blend(index, total) =
    let(center = (total - 1) / 2)
    let(distance_from_center = abs(index - center))
    let(max_distance = center)
    let(blend = 1 - (distance_from_center / max_distance))
    blend;

// Interpolate between two colors
function lerp_color(c1, c2, t) = [
    c1[0] + (c2[0] - c1[0]) * t,
    c1[1] + (c2[1] - c1[1]) * t,
    c1[2] + (c2[2] - c1[2]) * t,
    c1[3] + (c2[3] - c1[3]) * t
];

// === Main Assembly ===

module light_sculpture() {
    for (i = [0 : num_sheets - 1]) {
        if (is_visible(i, num_sheets)) {
            length_scale = get_scale(i, num_sheets, min_scale_length);
            width_scale = get_scale(i, num_sheets, min_scale_width);
            color_blend = get_color_blend(i, num_sheets);
            sheet_color = lerp_color(outer_color, inner_color, color_blend);

            translate([0, 0, i * sheet_thickness]) {
                color(sheet_color)
                if (i == 0) {
                    // Bottom plate with center hole for stand
                    bottom_plate(
                        max_length * length_scale,
                        max_width * width_scale,
                        sheet_thickness
                    );
                } else if (i == num_sheets - 1) {
                    // Top cap - solid
                    pill_shape(
                        max_length * length_scale,
                        max_width * width_scale,
                        sheet_thickness
                    );
                } else if (i == 10) {
                    // Center layer (10) - ring with screw holes for H structure mounting
                    ring_layer_with_screw_holes(
                        max_length * length_scale,
                        max_width * width_scale,
                        sheet_thickness
                    );
                } else {
                    // Other middle layers - regular rings
                    ring_layer(
                        max_length * length_scale,
                        max_width * width_scale,
                        sheet_thickness
                    );
                }
            }
        }
    }
}

// H structure with stand pole extending down (for table lamp)
module h_structure_with_stand(bottom_z) {
    // Bottom H
    single_h();

    // Top H
    translate([0, 0, h_vertical_spacing + h_pole_size])
        single_h();

    // Horizontal crossbar in center of top H (along X)
    translate([0, 0, h_vertical_spacing + h_pole_size])
        hollow_pole(h_bar_length, h_pole_size, h_pole_size);

    // Vertical connecting pole (along Z, between the two H's)
    translate([0, 0, (h_vertical_spacing + h_pole_size) / 2])
        hollow_pole(h_pole_size, h_pole_size, h_vertical_spacing + h_pole_size);

    // Stand pole extending down through bottom and out for lamp base
    // Goes from bottom H down through Z=0 and continues for stand
    stand_total_length = bottom_z + h_pole_size/2 + h_stand_pole_length;
    translate([0, 0, -bottom_z - h_stand_pole_length/2])
        hollow_pole(h_pole_size, h_pole_size, stand_total_length);
}

// Render the sculpture
if (show_sculpture) {
    light_sculpture();
}

// Render H structure (centered within sculpture, stand pole extends down through bottom)
if (show_led_structure) {
    h_total_height = h_vertical_spacing + 2*h_pole_size;
    // Position so H is vertically centered
    h_center_z = total_depth / 2;
    h_bottom_z = h_center_z - h_total_height/2 + h_pole_size/2;

    color([0.2, 0.6, 0.2])
    translate([0, 0, h_bottom_z])
        h_structure_with_stand(h_bottom_z);
}

// Render lamp base
if (show_base) {
    color([0.4, 0.4, 0.4])
    translate([0, 0, -h_stand_pole_length - base_height + base_pole_socket_depth])
        lamp_base();
}

// === Debug/Info ===
echo("=== TABLE LAMP VERSION ===");
echo("Stand pole length:", h_stand_pole_length, "mm");
echo("");
echo("=== MATHEMATICAL PROPERTIES ===");
echo("Golden Ratio (φ):", phi);
echo("Length/Width ratio:", max_length / max_width, "(should equal φ)");
echo("");
echo("=== DIMENSIONS ===");
echo("Total depth:", total_depth, "mm");
echo("Max dimensions:", max_length, "x", max_width, "mm");
echo("");
echo("=== LAYER SIZES ===");
echo("Sheet 0 (bottom):", max_length * get_scale(0, num_sheets, min_scale_length), "x", max_width * get_scale(0, num_sheets, min_scale_width));
echo("Sheet 9-10 (center):", max_length * get_scale(9, num_sheets, min_scale_length), "x", max_width * get_scale(9, num_sheets, min_scale_width));
echo("Sheet 19 (top):", max_length * get_scale(19, num_sheets, min_scale_length), "x", max_width * get_scale(19, num_sheets, min_scale_width));
