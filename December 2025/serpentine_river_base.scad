// Serpentine River Base Plate
// Base: 3mm thick at 35 degree angle
// River channel: 20mm wide serpentine path

// Parameters - adjust these as needed
base_length = 177.8;    // Length of the base plate (7 inches)
base_width = 127;       // Width of the base plate (5 inches)
base_thickness = 3;     // Thickness of the base plate (mm)
tilt_angle = 35;        // Angle of the base plate (degrees)

top_layer_height = 12;  // Height of the top layer with river channel (mm)
river_width = 6;        // Width of the river channel (mm)
river_depth = 10;       // Depth of the river channel (mm)

// Serpentine parameters
wave_amplitude = 55;    // How far the river meanders side to side (mm)
wave_frequency = 4;     // Number of large snake-like bends
river_segments = 150;   // Smoothness of the curve

$fn = 50;  // Resolution for curved surfaces

// Main assembly - rotated to the specified angle
rotate([tilt_angle, 0, 0]) {
    // Base plate
    color("SlateGray")
    cube([base_length, base_width, base_thickness]);

    // Top layer with river channel
    translate([0, 0, base_thickness])
    difference() {
        union() {
            // Solid top layer
            color("SaddleBrown")
            cube([base_length, base_width, top_layer_height]);

            // Add organic terrain surface
            color("Gray")
            translate([0, 0, top_layer_height])
            organic_terrain();
        }

        // Serpentine river channel (carved out through rocks too)
        color("DodgerBlue")
        translate([0, 0, top_layer_height - river_depth])
        serpentine_river();
    }
}

// Terrain parameters
terrain_resolution = 8;     // Grid spacing in mm (smaller = more detail, slower render)
terrain_max_height = 6;     // Maximum terrain height variation (mm)

// Organic terrain height function - layered noise for natural look
function terrain_height(x, y) =
    // Large rolling hills
    terrain_max_height * 0.5 * (
        sin(x * 0.04 * 360 + 30) * sin(y * 0.05 * 360 + 45) +
        0.5 * sin(x * 0.08 * 360 + 120) * sin(y * 0.07 * 360 + 80)
    ) +
    // Medium undulations
    terrain_max_height * 0.3 * (
        sin(x * 0.12 * 360 + 200) * sin(y * 0.15 * 360 + 150) +
        0.4 * sin(x * 0.18 * 360 + 60) * cos(y * 0.14 * 360 + 90)
    ) +
    // Fine texture
    terrain_max_height * 0.15 * (
        sin(x * 0.3 * 360 + 45) * sin(y * 0.25 * 360 + 30)
    ) +
    // Base offset to keep terrain above surface
    terrain_max_height * 0.6;

// Module to create organic terrain as a mesh of quadrilaterals
module organic_terrain() {
    grid_x = floor(base_length / terrain_resolution);
    grid_y = floor(base_width / terrain_resolution);

    for (ix = [0 : grid_x - 1]) {
        for (iy = [0 : grid_y - 1]) {
            x0 = ix * terrain_resolution;
            x1 = (ix + 1) * terrain_resolution;
            y0 = iy * terrain_resolution;
            y1 = (iy + 1) * terrain_resolution;

            // Get heights at four corners
            h00 = terrain_height(x0, y0);
            h10 = terrain_height(x1, y0);
            h01 = terrain_height(x0, y1);
            h11 = terrain_height(x1, y1);

            // Create terrain cell as a polyhedron
            terrain_cell(x0, y0, x1, y1, h00, h10, h01, h11);
        }
    }
}

// Single terrain cell as a solid from base to height
module terrain_cell(x0, y0, x1, y1, h00, h10, h01, h11) {
    base_z = -1;  // Extend below to ensure solid connection

    polyhedron(
        points = [
            // Bottom face (at base_z)
            [x0, y0, base_z],  // 0
            [x1, y0, base_z],  // 1
            [x1, y1, base_z],  // 2
            [x0, y1, base_z],  // 3
            // Top face (at terrain heights)
            [x0, y0, h00],     // 4
            [x1, y0, h10],     // 5
            [x1, y1, h11],     // 6
            [x0, y1, h01]      // 7
        ],
        faces = [
            [0, 1, 2, 3],     // Bottom
            [4, 7, 6, 5],     // Top
            [0, 4, 5, 1],     // Front
            [1, 5, 6, 2],     // Right
            [2, 6, 7, 3],     // Back
            [3, 7, 4, 0]      // Left
        ]
    );
}

// Function to create natural meandering offset using layered waves
function meander_offset(t) =
    wave_amplitude * 0.4 * sin(t * 360 * wave_frequency) +                // Primary meander
    wave_amplitude * 0.2 * sin(t * 360 * wave_frequency * 2.3 + 45) +     // Secondary variation
    wave_amplitude * 0.1 * sin(t * 360 * wave_frequency * 0.7 - 30) +     // Slow drift
    wave_amplitude * 0.08 * sin(t * 360 * wave_frequency * 4.1 + 120);    // Small wiggles

// X position: linear from 0 to base_length, plus natural meandering
function river_x(t) =
    t * base_length +                                                      // Diagonal from (0) to (base_length)
    meander_offset(t) * (1 - abs(2*t - 1));                               // Meander tapers at start/end

// Function to vary river width naturally
function natural_width(t) =
    river_width * (0.8 + 0.4 * sin(t * 360 * 3.7 + 60));  // Width varies 80%-120%

// Module to create the serpentine river path (flows top to bottom, starting top-left)
module serpentine_river() {
    // Create the river as a series of connected segments
    for (i = [0 : river_segments - 1]) {
        t1 = i / river_segments;
        t2 = (i + 1) / river_segments;

        // Y goes from base_width (top) down to 0 (bottom)
        y1 = base_width * (1 - t1);
        y2 = base_width * (1 - t2);

        // X position: starts at 0, ends at base_length, meanders in between
        x1 = river_x(t1);
        x2 = river_x(t2);

        // Varying width for natural look
        w1 = natural_width(t1);
        w2 = natural_width(t2);

        // Create a hull between two circles to form smooth river segments
        hull() {
            translate([x1, y1, 0])
            cylinder(h = river_depth + 1, d = w1);

            translate([x2, y2, 0])
            cylinder(h = river_depth + 1, d = w2);
        }
    }
}
