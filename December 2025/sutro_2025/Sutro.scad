    // ===========================================
// Sutro-like 3-Leg Tower - 3 ft Scale Model
// - Strong structural legs (optionally hollow with rod bore)
// - 5 triangular ring levels (with central holes)
// - Triangle "wire" X-bracing between legs (cosmetic)
// - Top platform has slight overhang beyond tower triangle
// - Optional base pads under legs
// - Segments can be toggled for separate printing
// ===========================================

// ---------------------------
// GLOBAL PARAMETERS
// ---------------------------

// Target overall model height (top of antennas)
total_model_height_mm = 914;     // ~3 ft

// Real tower height in feet (Sutro Tower)
real_tower_height_ft  = 977;

// Scale factor: mm of model per ft of real tower
FT = total_model_height_mm / real_tower_height_ft;  // ≈ 0.9355 mm/ft

// Structural member sizes
leg_diameter       = 10.0;   // outer diameter of main legs (or truss width)
leg_bore_diameter  = 3.5;    // inner bore for rods (0 = solid legs)
plate_thick        = 3.0;    // thickness of the triangular levels
antenna_radius     = 6.0;    // top antennas outer radius
antenna_bore_diameter = 3.0; // inner bore for wire routing (0 = solid antennas)
antenna_connector  = true;   // add solid connector between antennas for easy removal
antenna_connector_thickness = 3.0;  // height/thickness of the connector ring
antenna_connector_width = 4.0;      // width of the ring bars

// Truss settings for legs
use_truss_legs     = true;   // true = truss structure, false = simple rods
truss_member_dia   = 2.5;    // diameter of individual truss members
truss_divisions    = 4;      // number of horizontal divisions for cross-bracing

// Wire hole through legs (for LED wiring)
add_wire_holes         = true;   // cut continuous holes through leg centers
wire_hole_dia          = 4.0;    // diameter of wire passage hole

// ------------------------------------
// WIRE/BRACE PARAMETERS
// ------------------------------------
use_braces         = true;   // turn bracket wires on/off
use_hooks          = false;  // if true, replace triangle supports with hook mounts
brace_diameter     = 4.0;    // thickness of the wires
brace_fn           = 16;     // smoothness for braces (optional if you want different from cyl_fn)
hook_diameter      = 6.0;    // diameter of hook mounting rings
hook_thickness     = 2.0;    // thickness of hook ring

// Triangular ring cut-out:
// 0.0 = solid; 0.9 = very thin ring
plate_inner_scale  = 0.65;   // good "big hole, strong frame" ratio
use_plate_trusses  = true;   // add truss structure to ring plates

// Top overhang factor:
// 1.0 = no overhang, >1.0 = platform extends beyond tower triangle
top_overhang_scale = 1.6;    // 1.6 = 60% wider than inner triangle

// Base pads under each leg (only used in bottom segment)
add_base_pads      = true;
base_pad_radius    = 15;     // radius of each pad
base_pad_height    = 3;      // height of each pad
base_pad_flat      = true;   // true = flat base at z=0, false = tower starts at z=0

// Cylinder smoothness
cyl_fn = 32;

// ---------------------------
// SEGMENT TOGGLES
// ---------------------------
//
// Segment 1 = Bay 1 + base pads
// Segment 2 = Bay 2
// Segment 3 = Bay 3
// Segment 4 = Bay 4
// Segment 5 = Bay 5 + top platform
// Segment 6 = Antennas
//
show_segment_1 = true;
show_segment_2 = false;
show_segment_3 = false;
show_segment_4 = false;
show_segment_5 = false;
show_segment_6 = false;

// Electronics base box toggle
show_base_box = false;

// ---------------------------
// BASE BOX PARAMETERS
// ---------------------------
// Simple electronics enclosure at tower base
base_box_width = 60;             // box width (X)
base_box_depth = 45;             // box depth (Y)
base_box_height = 25;            // box height (Z)
base_box_wall = 2.0;             // wall thickness
base_box_corner_radius = 3;      // rounded corner radius

// Lid
base_box_show_lid = true;        // true = show lid, false = show base only
base_box_lid_thickness = 2;      // lid plate thickness
base_box_lip_height = 4;         // inner lip that fits into base
base_box_lip_width = 1.5;        // lip wall thickness
base_box_lid_tolerance = 0.3;    // gap for lid fit

// USB-C port
base_box_usb_port = true;        // add USB-C port hole
base_box_usb_width = 10.0;       // USB-C with clearance
base_box_usb_height = 4.0;       // USB-C with clearance
base_box_usb_z = 8;              // height from inner floor

// ---------------------------
// BAY GEOMETRY (REAL FEET)
// ---------------------------
//
// Approximate from Sutro Tower:
//   Levels: 0, 180, 375, 550, 650, 755, 762, 977 ft
//   Side spans: base 150 ft, waist 60 ft, top 100 ft

// bays: [bottom_ft, top_ft, bottom_side_ft, top_side_ft, has_plate]
bays = [
    [   0, 180, 150, 120, true ],  // Bay 1
    [ 180, 375, 120,  90, true ],  // Bay 2
    [ 375, 550,  90,  70, true ],  // Bay 3
    [ 550, 650,  70,  60, true ],  // Bay 4 (waist)
    [ 650, 755,  60, 100, true ]   // Bay 5 (flare to near top)
];

top_platform_ft       = 762;
top_platform_side_ft  = 100;  // nominal tower triangle at top

antenna_base_ft       = 762;
antenna_tip_ft        = 900;

// ---------------------------
// MAIN ENTRY
// ---------------------------

sutro_tower();

// ---------------------------
// MAIN TOWER MODULE (SEGMENTED)
// ---------------------------

module sutro_tower() {
    difference() {
        union() {
            if (show_segment_1) segment_1();
            if (show_segment_2) segment_2();
            if (show_segment_3) segment_3();
            if (show_segment_4) segment_4();
            if (show_segment_5) segment_5();
            if (show_segment_6) segment_6();
        }

        // Cut continuous wire holes through entire tower
        if (add_wire_holes) {
            wire_passage_holes();
        }
    }

    // Base box is separate (not part of difference)
    if (show_base_box) electronics_base_box();
}

// ---------------------------
// SEGMENTS
// ---------------------------

// Helper: render a bay by index (0..4)
module bay_by_index(idx) {
    bottom_ft      = bays[idx][0];
    top_ft         = bays[idx][1];
    bottom_side_ft = bays[idx][2];
    top_side_ft    = bays[idx][3];
    has_plate      = bays[idx][4];

    h_mm        = (top_ft - bottom_ft) * FT;
    base_side   = bottom_side_ft * FT;
    top_side    = top_side_ft    * FT;
    z_offset_mm = bottom_ft * FT;

    // Add base pad height offset if using flat pads on segment 1
    pad_offset = (idx == 0 && add_base_pads && base_pad_flat) ? base_pad_height : 0;

    translate([0, 0, z_offset_mm + pad_offset])
        sutro_bay(
            h_mm,
            base_side,
            top_side,
            leg_diameter,
            plate_thick,
            has_plate,
            use_braces,
            brace_diameter
        );
}

// Segment 1: Bay 1 + base pads
module segment_1() {
    // Bay index 0
    bay_by_index(0);
    if (add_base_pads) {
        add_foot_pads();
    }
}

// Segment 2: Bay 2
module segment_2() {
    bay_by_index(1);
}

// Segment 3: Bay 3
module segment_3() {
    bay_by_index(2);
}

// Segment 4: Bay 4 (waist)
module segment_4() {
    bay_by_index(3);
}

// Segment 5: Bay 5 + top platform (simplified)
module segment_5() {
    bay_by_index(4);

    // Add base pad offset if using flat pads
    pad_offset = (add_base_pads && base_pad_flat) ? base_pad_height : 0;

    // Bay 5 ends at 755 ft - place platform directly on top
    bay5_top_ft = bays[4][1];  // 755 ft
    platform_z = bay5_top_ft * FT + pad_offset;
    platform_inner_side = top_platform_side_ft * FT;

    translate([0, 0, platform_z])
        top_platform(platform_inner_side, plate_thick);
}

// Segment 6: Antennas
module segment_6() {
    antennas();
}

// ---------------------------
// ANTENNAS
// ---------------------------

module antennas() {
    // Add base pad offset if using flat pads
    pad_offset = (add_base_pads && base_pad_flat) ? base_pad_height : 0;
    
    // Start antennas from top of Bay 5 + platform thickness
    bay5_top_ft = bays[4][1];  // 755 ft
    base_z = bay5_top_ft * FT + pad_offset + plate_thick;
    ant_h_mm  = (antenna_tip_ft - antenna_base_ft) * FT;

    // Antenna triangle matches platform inner side (tower triangle)
    inner_side_mm = top_platform_side_ft * FT;
    pts           = tri_points(inner_side_mm);

    for (p = pts) {
        translate([p[0], p[1], base_z]) {
            if (antenna_bore_diameter <= 0 || antenna_bore_diameter >= antenna_radius * 2) {
                // Solid antenna
                cylinder(h = ant_h_mm, r = antenna_radius, $fn = cyl_fn);
            } else {
                // Hollow antenna with bore for wire
                difference() {
                    cylinder(h = ant_h_mm, r = antenna_radius, $fn = cyl_fn);
                    cylinder(h = ant_h_mm + 1, r = antenna_bore_diameter / 2, $fn = cyl_fn);
                }
            }
        }
    }

    // Solid connector at base of antennas for easy build plate removal
    if (antenna_connector) {
        connector_z = base_z + antenna_connector_thickness / 2;
        antenna_solid_connector(pts, connector_z, antenna_connector_thickness, antenna_connector_width);
    }
}

// Solid triangular ring connector between antennas
// Provides a grip to pull antennas off the build plate
module antenna_solid_connector(pts, z_pos, thick, width) {
    translate([0, 0, z_pos]) {
        // Three solid bars forming a triangular ring
        for (i = [0:2]) {
            next_i = (i + 1) % 3;
            
            // Calculate bar direction and length
            dx = pts[next_i][0] - pts[i][0];
            dy = pts[next_i][1] - pts[i][1];
            bar_length = sqrt(dx*dx + dy*dy);
            bar_angle = atan2(dy, dx);
            
            // Solid rectangular bar between antennas
            translate([(pts[i][0] + pts[next_i][0])/2, (pts[i][1] + pts[next_i][1])/2, 0])
                rotate([0, 0, bar_angle])
                    cube([bar_length, width, thick], center = true);
        }
    }
}

// ---------------------------
// TOWER BAY (LEGS + RING PLATE + OPTIONAL WIRES)
// ---------------------------

module sutro_bay(h, base_side, top_side, leg_d, plate_t, with_plate, with_braces, brace_d) {
    base_pts = tri_points(base_side);
    top_pts  = tri_points(top_side);

    // ---- LEGS (STRUCTURAL) ----
    for (i = [0:2]) {
        leg(base_pts[i], top_pts[i], h, leg_d);
    }

    // ---- WIRE-LIKE X-BRACING (COSMETIC) OR HOOKS ----
    if (use_hooks) {
        // Hook mounting points instead of X-bracing
        // Place hooks at multiple heights along each face
        num_hook_levels = use_truss_legs ? truss_divisions : 3;

        brace_pairs = [
            [0,1],
            [1,2],
            [2,0]
        ];

        for (pair = brace_pairs) {
            i = pair[0];
            j = pair[1];

            // Place hooks at multiple heights
            for (level = [1:num_hook_levels]) {
                t = level / (num_hook_levels + 1);  // distribute evenly
                hook_h = h * t;

                // Interpolated positions of leg centers at this height
                corner_i_x = base_pts[i][0] + t * (top_pts[i][0] - base_pts[i][0]);
                corner_i_y = base_pts[i][1] + t * (top_pts[i][1] - base_pts[i][1]);
                corner_j_x = base_pts[j][0] + t * (top_pts[j][0] - base_pts[j][0]);
                corner_j_y = base_pts[j][1] + t * (top_pts[j][1] - base_pts[j][1]);

                // Midpoint between the two leg centers
                mid_x = (corner_i_x + corner_j_x) / 2;
                mid_y = (corner_i_y + corner_j_y) / 2;

                // Calculate angle to orient hook
                dx = corner_j_x - corner_i_x;
                dy = corner_j_y - corner_i_y;
                angle = atan2(dy, dx);

                // Place and orient hook
                translate([mid_x, mid_y, hook_h])
                    rotate([0, 0, angle])
                        hook_mount();
            }
        }
    } else if (with_braces) {
        // Original X-bracing
        brace_pairs = [
            [0,1],
            [1,2],
            [2,0]
        ];

        for (pair = brace_pairs) {
            i = pair[0];
            j = pair[1];

            // Diagonal A: bottom of i to top of j
            brace(
                [ base_pts[i][0], base_pts[i][1], 0 ],
                [ top_pts[j][0],  top_pts[j][1],  h ],
                brace_d
            );

            // Diagonal B: bottom of j to top of i
            brace(
                [ base_pts[j][0], base_pts[j][1], 0 ],
                [ top_pts[i][0],  top_pts[i][1],  h ],
                brace_d
            );
        }
    }

    // ---- RING PLATE AT TOP OF BAY ----
    if (with_plate) {
        translate([0, 0, h])
            ring_plate(top_side, plate_t, plate_inner_scale);
    }
}

// ---------------------------
// PLATFORMS / RING PLATES
// ---------------------------

// Triangular ring with a cut-out center
// Includes corner notches at leg positions for printability
module ring_plate(side_outer, thick, inner_scale) {
    side_inner = side_outer * inner_scale;
    leg_pts = tri_points(side_outer);

    // Notch size - large enough to clear leg/wire area
    notch_r = leg_diameter/2 + 3;

    difference() {
        ring_plate_with_inner_outer(side_outer, side_inner, thick);

        // Cut notches at corners where legs pass through
        for (p = leg_pts) {
            translate([p[0], p[1], -1])
                cylinder(h = thick + 2, r = notch_r, $fn = cyl_fn);
        }
    }

    // Add truss structure if enabled
    if (use_plate_trusses) {
        ring_plate_truss(side_inner, side_outer, thick);
    }
}

// Top platform: overhanging ring with truss structure
// - inner triangular opening is set by plate_inner_scale
// - outer triangle is scaled by top_overhang_scale
// Includes corner notches at antenna positions for printability
module top_platform(inner_nominal_side, thick) {
    // legs + antenna triangle ≈ inner_nominal_side
    outer_side = inner_nominal_side * top_overhang_scale;
    hole_side  = outer_side * plate_inner_scale;
    antenna_pts = tri_points(inner_nominal_side);

    // Notch size - large enough to clear antenna/wire area
    notch_r = antenna_radius + 3;

    difference() {
        ring_plate_with_inner_outer(outer_side, hole_side, thick);

        // Cut notches at antenna positions
        for (p = antenna_pts) {
            translate([p[0], p[1], -1])
                cylinder(h = thick + 2, r = notch_r, $fn = cyl_fn);
        }
    }

    // Add truss structure on overhang
    top_platform_truss(inner_nominal_side, outer_side, thick);
}

// Truss structure for ring plates
// Wire holes are cut globally by wire_passage_holes() in sutro_tower()
module ring_plate_truss(inner_side, outer_side, thick) {
    inner_pts = tri_points(inner_side);
    outer_pts = tri_points(outer_side);

    truss_dia = brace_diameter * 0.8;  // slightly thinner than main braces

    // Radial trusses from inner to outer corners
    for (i = [0:2]) {
        brace(
            [inner_pts[i][0], inner_pts[i][1], thick/2],
            [outer_pts[i][0], outer_pts[i][1], thick/2],
            truss_dia
        );
    }

    // Diagonal cross-bracing on each face
    for (i = [0:2]) {
        next_i = (i + 1) % 3;

        // Cross brace A: inner corner i to outer corner next_i
        brace(
            [inner_pts[i][0], inner_pts[i][1], thick/2],
            [outer_pts[next_i][0], outer_pts[next_i][1], thick/2],
            truss_dia
        );

        // Cross brace B: inner corner next_i to outer corner i
        brace(
            [inner_pts[next_i][0], inner_pts[next_i][1], thick/2],
            [outer_pts[i][0], outer_pts[i][1], thick/2],
            truss_dia
        );
    }
}

// Truss structure for top platform overhang
// Wire holes are cut globally by wire_passage_holes() in sutro_tower()
module top_platform_truss(inner_side, outer_side, thick) {
    inner_pts = tri_points(inner_side);
    outer_pts = tri_points(outer_side);

    truss_dia = brace_diameter * 0.8;  // slightly thinner than main braces

    // Radial trusses from inner to outer corners
    for (i = [0:2]) {
        brace(
            [inner_pts[i][0], inner_pts[i][1], thick/2],
            [outer_pts[i][0], outer_pts[i][1], thick/2],
            truss_dia
        );
    }

    // Diagonal cross-bracing on each overhang face
    for (i = [0:2]) {
        next_i = (i + 1) % 3;

        // Cross brace A: inner corner i to outer corner next_i
        brace(
            [inner_pts[i][0], inner_pts[i][1], thick/2],
            [outer_pts[next_i][0], outer_pts[next_i][1], thick/2],
            truss_dia
        );

        // Cross brace B: inner corner next_i to outer corner i
        brace(
            [inner_pts[next_i][0], inner_pts[next_i][1], thick/2],
            [outer_pts[i][0], outer_pts[i][1], thick/2],
            truss_dia
        );
    }
}

// Generic ring between an outer and inner triangle
module ring_plate_with_inner_outer(outer_side, inner_side, thick) {
    linear_extrude(height = thick)
        difference() {
            polygon(points = tri_points(outer_side));  // outer triangle
            polygon(points = tri_points(inner_side));  // inner cut-out
        }
}

// ---------------------------
// CONNECTOR LEGS (for gap between Bay 5 and top platform)
// ---------------------------

// Vertical connector legs between Bay 5 top and platform
module connector_legs(bottom_side, top_side, h, dia_outer) {
    base_pts = tri_points(bottom_side);
    top_pts  = tri_points(top_side);

    // Create three connector legs matching the main leg style
    for (i = [0:2]) {
        leg(base_pts[i], top_pts[i], h, dia_outer);
    }
}

// ---------------------------
// PRIMITIVES: LEGS & BRACES
// ---------------------------

// Leg between two 2D points, from z=0 to z=h
// - Uses truss structure if use_truss_legs is true
// - Otherwise uses solid or hollow rod
module leg(p_bottom, p_top, h, dia_outer) {
    v0 = [p_bottom[0], p_bottom[1], 0];
    v1 = [p_top[0],    p_top[1],    h];

    if (use_truss_legs) {
        // Truss-style leg with triangular cross-section
        truss_leg(p_bottom, p_top, h, dia_outer);
    } else {
        if (leg_bore_diameter <= 0 || leg_bore_diameter >= dia_outer) {
            // Solid leg
            tapered_rod(v0, v1, dia_outer);
        } else {
            // Hollow leg with bore
            difference() {
                tapered_rod(v0, v1, dia_outer);
                tapered_rod(v0, v1, leg_bore_diameter);
            }
        }
    }
}

// Truss leg with triangular cross-section and diagonal bracing
// Optionally includes a central hollow conduit for wire routing
module truss_leg(p_bottom, p_top, h, truss_width) {
    // Create three corner members in triangular arrangement
    // relative to the leg centerline
    corner_offsets = tri_points(truss_width);

    // Draw three vertical corner members
    for (offset = corner_offsets) {
        v0 = [p_bottom[0] + offset[0], p_bottom[1] + offset[1], 0];
        v1 = [p_top[0] + offset[0], p_top[1] + offset[1], h];
        tapered_rod(v0, v1, truss_member_dia);
    }

    // Add horizontal and diagonal cross-bracing
    step_h = h / truss_divisions;
    for (i = [0:truss_divisions-1]) {
        z_bottom = i * step_h;
        z_top = (i + 1) * step_h;

        // Interpolate positions along the tapered leg
        t_bottom = z_bottom / h;
        t_top = z_top / h;

        for (j = [0:2]) {
            next_j = (j + 1) % 3;

            // Bottom ring at this level
            p0_bottom = [
                p_bottom[0] + corner_offsets[j][0] + (p_top[0] - p_bottom[0]) * t_bottom,
                p_bottom[1] + corner_offsets[j][1] + (p_top[1] - p_bottom[1]) * t_bottom,
                z_bottom
            ];
            p1_bottom = [
                p_bottom[0] + corner_offsets[next_j][0] + (p_top[0] - p_bottom[0]) * t_bottom,
                p_bottom[1] + corner_offsets[next_j][1] + (p_top[1] - p_bottom[1]) * t_bottom,
                z_bottom
            ];

            // Top ring at this level
            p0_top = [
                p_bottom[0] + corner_offsets[j][0] + (p_top[0] - p_bottom[0]) * t_top,
                p_bottom[1] + corner_offsets[j][1] + (p_top[1] - p_bottom[1]) * t_top,
                z_top
            ];
            p1_top = [
                p_bottom[0] + corner_offsets[next_j][0] + (p_top[0] - p_bottom[0]) * t_top,
                p_bottom[1] + corner_offsets[next_j][1] + (p_top[1] - p_bottom[1]) * t_top,
                z_top
            ];

            // Horizontal member at bottom of this section
            brace(p0_bottom, p1_bottom, truss_member_dia * 0.7);

            // Diagonal cross-bracing
            brace(p0_bottom, p1_top, truss_member_dia * 0.7);
            brace(p1_bottom, p0_top, truss_member_dia * 0.7);
        }
    }
    // Note: wire holes are cut globally by wire_passage_holes() in sutro_tower()
}

// Brace between two 3D points (wire-like)
module brace(v0, v1, dia) {
    hull() {
        translate(v0)
            cylinder(h = dia, r = dia/2, center = true, $fn = brace_fn);
        translate(v1)
            cylinder(h = dia, r = dia/2, center = true, $fn = brace_fn);
    }
}

// Hook mount for string/wire hanging
module hook_mount() {
    difference() {
        // Outer ring
        cylinder(h = hook_thickness, r = hook_diameter/2, center = true, $fn = cyl_fn);

        // Inner hole
        cylinder(h = hook_thickness + 1, r = hook_diameter/2 - hook_thickness, center = true, $fn = cyl_fn);

        // Opening slot for wire to slip in
        translate([0, hook_diameter/4, 0])
            cube([hook_thickness * 1.5, hook_diameter/2, hook_thickness + 1], center = true);
    }
}

// Rod between two 3D points using hull of short cylinders
module tapered_rod(v0, v1, dia) {
    hull() {
        translate(v0)
            cylinder(h = dia, r = dia/2, center = true, $fn = cyl_fn);
        translate(v1)
            cylinder(h = dia, r = dia/2, center = true, $fn = cyl_fn);
    }
}

// ---------------------------
// BASE PADS UNDER LEGS
// ---------------------------

module add_foot_pads() {
    // Use bottom side of first bay as leg triangle
    base_side_ft  = bays[0][2];
    base_side_mm  = base_side_ft * FT;
    base_pts      = tri_points(base_side_mm);

    // Position pads based on base_pad_flat setting
    pad_z = base_pad_flat ? 0 : -base_pad_height;

    for (p = base_pts) {
        translate([p[0], p[1], pad_z])
            cylinder(h = base_pad_height, r = base_pad_radius, $fn = cyl_fn);
    }
    // Note: wire holes are cut through pads by wire_passage_holes() in sutro_tower()
}

// ---------------------------
// GEOMETRY HELPERS
// ---------------------------

// Equilateral triangle points (side length = side), centered
function tri_points(side) =
    let(
        s = side,
        h = (sqrt(3)/2) * s
    )
    [
        [ -s/2, -h/3 ],
        [  s/2, -h/3 ],
        [    0,  2*h/3 ]
    ];

// ---------------------------
// WIRE PASSAGE HOLES
// ---------------------------
// Cuts continuous holes through leg centers, following the actual leg path
// through each bay (including the waist narrowing and top flare)

module wire_passage_holes() {
    pad_offset = (add_base_pads && base_pad_flat) ? base_pad_height : 0;

    // For each of the 3 leg positions
    for (i = [0:2]) {
        // Cut through base pad (below bay 1)
        base_side = bays[0][2] * FT;
        base_pts = tri_points(base_side);
        translate([base_pts[i][0], base_pts[i][1], -1])
            cylinder(h = pad_offset + 2, r = wire_hole_dia/2, $fn = cyl_fn);

        // Cut through each bay following the leg taper
        for (bay_idx = [0:4]) {
            bottom_ft = bays[bay_idx][0];
            top_ft = bays[bay_idx][1];
            bottom_side = bays[bay_idx][2] * FT;
            top_side = bays[bay_idx][3] * FT;

            bottom_pts = tri_points(bottom_side);
            top_pts = tri_points(top_side);

            // Z positions for this bay
            z_bottom = bottom_ft * FT + pad_offset;
            z_top = top_ft * FT + pad_offset;

            // Hull between bottom and top of this bay segment
            hull() {
                translate([bottom_pts[i][0], bottom_pts[i][1], z_bottom - 1])
                    cylinder(h = 0.1, r = wire_hole_dia/2, $fn = cyl_fn);
                translate([top_pts[i][0], top_pts[i][1], z_top + 1])
                    cylinder(h = 0.1, r = wire_hole_dia/2, $fn = cyl_fn);
            }
        }

        // Cut through top platform and antennas
        top_side = top_platform_side_ft * FT;
        top_pts = tri_points(top_side);
        platform_z = bays[4][1] * FT + pad_offset;  // top of bay 5
        antenna_top_z = antenna_tip_ft * FT + pad_offset;

        hull() {
            translate([top_pts[i][0], top_pts[i][1], platform_z - 1])
                cylinder(h = 0.1, r = wire_hole_dia/2, $fn = cyl_fn);
            translate([top_pts[i][0], top_pts[i][1], antenna_top_z + 10])
                cylinder(h = 0.1, r = wire_hole_dia/2, $fn = cyl_fn);
        }
    }
}

// ---------------------------
// SIMPLE ELECTRONICS BASE BOX
// ---------------------------

module electronics_base_box() {
    pad_offset = (add_base_pads && base_pad_flat) ? base_pad_height : 0;

    // Calculated dimensions
    inner_w = base_box_width - 2 * base_box_wall;
    inner_d = base_box_depth - 2 * base_box_wall;
    inner_h = base_box_height - base_box_wall;  // open top

    // Position box centered under tower
    translate([-base_box_width/2, -base_box_depth/2, pad_offset]) {
        if (base_box_show_lid) {
            // Show lid positioned to the side for printing
            translate([base_box_width + 10, 0, base_box_lid_thickness])
                rotate([180, 0, 0])
                    base_box_lid();
        }

        // Always show the base
        base_box_base();
    }
}

// Rounded box helper
module base_box_rounded(length, width, height, radius) {
    hull() {
        for (x = [radius, length - radius]) {
            for (y = [radius, width - radius]) {
                translate([x, y, 0])
                    cylinder(r = radius, h = height, $fn = cyl_fn);
            }
        }
    }
}

// Base (hollow box with open top)
module base_box_base() {
    inner_w = base_box_width - 2 * base_box_wall;
    inner_d = base_box_depth - 2 * base_box_wall;
    inner_h = base_box_height - base_box_wall;

    difference() {
        // Outer shell
        base_box_rounded(base_box_width, base_box_depth, base_box_height, base_box_corner_radius);

        // Inner cavity
        translate([base_box_wall, base_box_wall, base_box_wall])
            base_box_rounded(inner_w, inner_d, inner_h + 1, base_box_corner_radius - base_box_wall/2);

        // USB-C port on back (Y+ side)
        if (base_box_usb_port) {
            translate([base_box_width/2 - base_box_usb_width/2,
                       base_box_depth - base_box_wall - 1,
                       base_box_wall + base_box_usb_z])
                cube([base_box_usb_width, base_box_wall + 2, base_box_usb_height]);
        }
    }
}

// Lid with inner lip
module base_box_lid() {
    inner_w = base_box_width - 2 * base_box_wall;
    inner_d = base_box_depth - 2 * base_box_wall;
    lip_w = inner_w - 2 * base_box_lid_tolerance;
    lip_d = inner_d - 2 * base_box_lid_tolerance;

    // Main lid plate
    base_box_rounded(base_box_width, base_box_depth, base_box_lid_thickness, base_box_corner_radius);

    // Inner lip that fits inside the box
    translate([base_box_wall + base_box_lid_tolerance,
               base_box_wall + base_box_lid_tolerance,
               -base_box_lip_height]) {
        difference() {
            base_box_rounded(lip_w, lip_d, base_box_lip_height,
                            base_box_corner_radius - base_box_wall/2);
            translate([base_box_lip_width, base_box_lip_width, -1])
                base_box_rounded(lip_w - 2*base_box_lip_width,
                                lip_d - 2*base_box_lip_width,
                                base_box_lip_height + 2,
                                base_box_corner_radius - base_box_wall);
        }
    }
}
