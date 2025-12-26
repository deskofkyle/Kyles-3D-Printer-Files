// Compartment Box with Internal Dividers - 10 Design Variations
// Change DESIGN_NUMBER (1-10) to switch between layouts

DESIGN_NUMBER = 1;  // <-- CHANGE THIS (1-10) to select design

// Main parameters
// Golden ratio: width / length = 1.618
box_width = 120;
box_length = box_width / 1.618;  // ≈ 74.17
box_depth = 25;
wall_thickness = 1;
divider_thickness = 1.5;

// Eno-style light control parameters
divider_height_tall = 22;      // Almost touches diffuser - clean separation
divider_height_medium = 16;    // Moderate glow
divider_height_short = 10;     // Brighter, more diffused

chamfer_size = 1.5;            // Softens light edges
mixing_gap = 2;                // Gap between dividers and walls for light bleed
mixing_hole_size = 0;          // Small tunnels between compartments

curve_radius = 8;

// Wire hole parameters
wire_hole_diameter = 3;
back_hole_count = 3;
internal_wire_hole_diameter = 5;  // Holes in dividers for routing wires

// ============== HELPER MODULES ==============

module wire_hole() {
    cylinder(h = wall_thickness + 2, d = wire_hole_diameter, $fn = 24);
}

// Internal wire hole for routing through dividers
module internal_wire_hole() {
    cylinder(h = divider_thickness + 2, d = internal_wire_hole_diameter, $fn = 32);
}

// Simple chamfered top bar
module chamfered_top(width, length, height, chamfer) {
    cube([width, length, height]);
}

// Rounded rect divider - simple flat top version
module rounded_rect_divider(width, length, height, radius) {
    r = max(0.1, radius);
    linear_extrude(height = height)
        difference() {
            offset(r = r) offset(r = -r) square([width, length]);
            translate([divider_thickness, divider_thickness])
                offset(r = max(0.1, r - divider_thickness))
                offset(r = -max(0.1, r - divider_thickness))
                    square([width - divider_thickness * 2, length - divider_thickness * 2]);
        }
}

// U-shape opening downward (closed at bottom)
module curved_u_divider(width, length, height, radius) {
    linear_extrude(height = height)
        difference() {
            square([width, length]);
            translate([divider_thickness + radius, divider_thickness, 0])
                square([width - divider_thickness * 2 - radius * 2, length]);
            translate([divider_thickness + radius, divider_thickness + radius, 0])
                circle(r = radius, $fn = 32);
            translate([width - divider_thickness - radius, divider_thickness + radius, 0])
                circle(r = radius, $fn = 32);
            translate([divider_thickness, divider_thickness + radius, 0])
                square([radius, length]);
            translate([width - divider_thickness - radius, divider_thickness + radius, 0])
                square([radius, length]);
        }
}

// U-shape opening upward (closed at top)
module curved_u_up(width, length, height, radius) {
    linear_extrude(height = height)
        difference() {
            square([width, length]);
            translate([divider_thickness + radius, -0.1, 0])
                square([width - divider_thickness * 2 - radius * 2, length - divider_thickness]);
            translate([divider_thickness + radius, length - divider_thickness - radius, 0])
                circle(r = radius, $fn = 32);
            translate([width - divider_thickness - radius, length - divider_thickness - radius, 0])
                circle(r = radius, $fn = 32);
            translate([divider_thickness, -0.1, 0])
                square([radius, length - divider_thickness - radius]);
            translate([width - divider_thickness - radius, -0.1, 0])
                square([radius, length - divider_thickness - radius]);
        }
}

// Light mixing hole - small tunnel at base for subtle color blending
module mixing_hole(len) {
    rotate([-90, 0, 0])
        cylinder(h = len, d = mixing_hole_size, $fn = 16);
}

// Outer box with mixing gaps (slightly inset dividers)
module outer_box() {
    difference() {
        cube([box_width, box_length, box_depth]);
        translate([wall_thickness, wall_thickness, wall_thickness])
            cube([box_width - wall_thickness * 2, box_length - wall_thickness * 2, box_depth]);
        // Wire holes in back
        for (i = [1 : back_hole_count]) {
            translate([box_width * i / (back_hole_count + 1), -1, box_depth / 2])
                rotate([-90, 0, 0])
                    wire_hole();
        }
    }
}

// ============== DESIGN 1: Original Layout with Depth Variation ==============
module design_1() {
    outer_box();
    g = mixing_gap;
    edge_margin = 5;  // Extra margin from box edges

    difference() {
        union() {
            // Bottom-left U-shape - TALL (clean separation)
            translate([wall_thickness + edge_margin, wall_thickness + edge_margin, wall_thickness])
                curved_u_divider(32 - g, 38 - g, divider_height_tall, curve_radius);

            // Top-left rounded rect - MEDIUM
            translate([wall_thickness + edge_margin, 48, wall_thickness])
                rounded_rect_divider(32 - g * 2, 20 - g, divider_height_medium, curve_radius);

            // Center small rounded square - SHORT (brightest)
            translate([40, 26, wall_thickness])
                rounded_rect_divider(18, 18, divider_height_short, 4);

            // Right large rounded rect - TALL with divider
            translate([64, wall_thickness + edge_margin, wall_thickness])
                rounded_rect_divider(50 - g, 62 - g * 2, divider_height_tall, curve_radius);
            translate([88, 12, wall_thickness])
                chamfered_top(divider_thickness, 46, divider_height_medium, chamfer_size);
        }
        // Wire holes in each shape
        translate([20, wall_thickness + edge_margin + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Bottom-left U
        translate([20, 48 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Top-left rect
        translate([49, 26 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Center square
        translate([89, wall_thickness + edge_margin + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Right rect
    }

    // Mixing holes between sections
    translate([38, 32, wall_thickness + 2])
        mixing_hole(4);
    translate([62, 37, wall_thickness + 2])
        mixing_hole(4);
}

// ============== DESIGN 2: Triple U with Gradient Heights ==============
module design_2() {
    outer_box();
    g = mixing_gap;

    difference() {
        union() {
            // Left U - TALL
            translate([wall_thickness + g, wall_thickness + g, wall_thickness])
                curved_u_divider(38 - g * 2, 68 - g * 2, divider_height_tall, 10);

            // Center U - MEDIUM
            translate([wall_thickness + 40, wall_thickness + g, wall_thickness])
                curved_u_divider(38 - g * 2, 68 - g * 2, divider_height_medium, 10);

            // Right U - SHORT (brightest)
            translate([wall_thickness + 80, wall_thickness + g, wall_thickness])
                curved_u_divider(38 - g * 2, 68 - g * 2, divider_height_short, 10);
        }
        // Wire holes in each U
        translate([20, wall_thickness + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Left U
        translate([60, wall_thickness + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Center U
        translate([100, wall_thickness + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Right U
    }

    // Mixing holes between U's
    translate([39, 35, wall_thickness + 2])
        rotate([0, 90, 0]) cylinder(h = 3, d = mixing_hole_size, $fn = 16);
    translate([79, 35, wall_thickness + 2])
        rotate([0, 90, 0]) cylinder(h = 3, d = mixing_hole_size, $fn = 16);
}

// ============== DESIGN 3: Nested with Depth Gradient ==============
module design_3() {
    outer_box();

    difference() {
        union() {
            // Outer - TALL (darkest ring)
            translate([5, 5, wall_thickness])
                rounded_rect_divider(110, 60, divider_height_tall, 10);

            // Second - MEDIUM-TALL
            translate([15, 12, wall_thickness])
                rounded_rect_divider(90, 46, 19, 8);

            // Third - MEDIUM
            translate([25, 19, wall_thickness])
                rounded_rect_divider(70, 32, divider_height_medium, 6);

            // Inner - SHORT (brightest center)
            translate([35, 26, wall_thickness])
                rounded_rect_divider(50, 18, divider_height_short, 4);
        }
        // Wire holes in each nested rect
        translate([60, 5 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Outer
        translate([60, 12 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Second
        translate([60, 19 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Third
        translate([60, 26 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Inner
    }
}

// ============== DESIGN 4: Quadrants with Alternating Depths ==============
module design_4() {
    outer_box();
    g = mixing_gap;

    difference() {
        union() {
            // Top-left - TALL
            translate([2 + g, 2 + g, wall_thickness])
                rounded_rect_divider(56 - g * 2, 32 - g * 2, divider_height_tall, curve_radius);

            // Top-right - SHORT
            translate([62, 2 + g, wall_thickness])
                rounded_rect_divider(56 - g * 2, 32 - g * 2, divider_height_short, curve_radius);

            // Bottom-left - SHORT
            translate([2 + g, 36, wall_thickness])
                rounded_rect_divider(56 - g * 2, 32 - g * 2, divider_height_short, curve_radius);

            // Bottom-right - TALL
            translate([62, 36, wall_thickness])
                rounded_rect_divider(56 - g * 2, 32 - g * 2, divider_height_tall, curve_radius);
        }
        // Wire holes in each quadrant
        translate([30, 2 + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Top-left
        translate([90, 2 + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Top-right
        translate([30, 36 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Bottom-left
        translate([90, 36 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Bottom-right
    }

    // Mixing holes at corners
    translate([58, 35, wall_thickness + 2])
        mixing_hole(6);
}

// ============== DESIGN 5: Asymmetric with Depth Drama ==============
module design_5() {
    outer_box();
    g = mixing_gap;

    difference() {
        union() {
            // Large rounded rect left - TALL with horizontal divider
            translate([2 + g, 2 + g, wall_thickness])
                rounded_rect_divider(45 - g * 2, 66 - g * 2, divider_height_tall, 10);
            translate([12, 35, wall_thickness])
                chamfered_top(25, divider_thickness, divider_height_medium, chamfer_size);

            // Small rounded square top-right - SHORT (accent bright)
            translate([50, 2 + g, wall_thickness])
                rounded_rect_divider(25, 25 - g, divider_height_short, 6);

            // Tall narrow rounded rect far right - MEDIUM
            translate([78, 2 + g, wall_thickness])
                rounded_rect_divider(40 - g, 25 - g, divider_height_medium, 6);

            // U-shape bottom-right - TALL
            translate([50, 30, wall_thickness])
                curved_u_divider(68 - g, 38 - g, divider_height_tall, curve_radius);
        }
        // Wire holes in each shape
        translate([24, 2 + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Left rect
        translate([62, 2 + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Top-right square
        translate([98, 2 + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Far right rect
        translate([84, 30 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Bottom-right U
    }
}

// ============== DESIGN 6: Spiral with Depth Flow ==============
module design_6() {
    outer_box();
    g = mixing_gap;

    difference() {
        union() {
            // Large outer U - TALL
            translate([2 + g, 2 + g, wall_thickness])
                curved_u_divider(50 - g, 66 - g * 2, divider_height_tall, 12);

            // Medium rounded rect top-right - MEDIUM
            translate([55, 2 + g, wall_thickness])
                rounded_rect_divider(63 - g, 30 - g, divider_height_medium, 8);

            // Small U bottom-right - SHORT
            translate([55, 36, wall_thickness])
                curved_u_up(40, 32 - g, divider_height_short, 8);

            // Tiny rounded square corner - MEDIUM (accent)
            translate([98, 40, wall_thickness])
                rounded_rect_divider(18 - g, 26 - g, divider_height_medium, 5);
        }
        // Wire holes in each shape
        translate([27, 2 + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Outer U
        translate([86, 2 + g + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Top-right rect
        translate([75, 36 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Bottom-right U
        translate([107, 40 + divider_thickness/2, wall_thickness + 6])
            rotate([-90, 0, 0]) internal_wire_hole();  // Corner square
    }

    // Mixing holes for color flow
    translate([53, 20, wall_thickness + 2])
        rotate([0, 90, 0]) cylinder(h = 4, d = mixing_hole_size, $fn = 16);
    translate([53, 50, wall_thickness + 2])
        rotate([0, 90, 0]) cylinder(h = 4, d = mixing_hole_size, $fn = 16);
}

// ============== DESIGN 7: U with Tracks - Eno Style ==============
module design_7() {
    outer_box();
    g = mixing_gap;

    // Large U-shape left - TALL (almost to diffuser)
    translate([2 + g, 2 + g, wall_thickness])
        curved_u_up(36 - g * 2, 66 - g * 2, divider_height_tall, 10);

    // Horizontal track top-right - SHORT (bright bar)
    translate([42, 2 + g, wall_thickness])
        rounded_rect_divider(76 - g, 20 - g, divider_height_short, 10);

    // Two rounded rects bottom-right - MEDIUM with dividers
    translate([42, 26, wall_thickness])
        rounded_rect_divider(35, 42 - g, divider_height_medium, curve_radius);
    translate([59, 34, wall_thickness])
        chamfered_top(divider_thickness, 26, divider_height_tall, chamfer_size);

    translate([81, 26, wall_thickness])
        rounded_rect_divider(37 - g, 42 - g, divider_height_medium, curve_radius);
    translate([99, 34, wall_thickness])
        chamfered_top(divider_thickness, 26, divider_height_tall, chamfer_size);
}

// ============== DESIGN 8: Interlocking U's with Depth Contrast ==============
module design_8() {
    outer_box();
    g = mixing_gap;

    // Left U opening up - TALL
    translate([2 + g, 2 + g, wall_thickness])
        curved_u_up(35 - g, 45 - g, divider_height_tall, 10);

    // Right U opening down - TALL
    translate([83, 23, wall_thickness])
        curved_u_divider(35 - g, 45 - g, divider_height_tall, 10);

    // Center rounded rect bridging - SHORT (focal bright point)
    translate([40, 20, wall_thickness])
        rounded_rect_divider(40, 30, divider_height_short, 8);

    // Top-right small rounded square - MEDIUM
    translate([85, 2 + g, wall_thickness])
        rounded_rect_divider(32 - g, 18 - g, divider_height_medium, 6);

    // Bottom-left small rounded square - MEDIUM
    translate([2 + g, 50, wall_thickness])
        rounded_rect_divider(35 - g, 18 - g, divider_height_medium, 6);

    // Mixing holes connecting center to U's
    translate([38, 35, wall_thickness + 2])
        rotate([0, 90, 0]) cylinder(h = 4, d = mixing_hole_size, $fn = 16);
    translate([78, 35, wall_thickness + 2])
        rotate([0, 90, 0]) cylinder(h = 4, d = mixing_hole_size, $fn = 16);
}

// ============== DESIGN 9: Double U Facing - Eno Gradient ==============
module design_9() {
    outer_box();
    g = mixing_gap;

    // U-shape opening up (bottom-left) - TALL
    translate([2 + g, 2 + g, wall_thickness])
        curved_u_up(56 - g * 2, 32 - g, divider_height_tall, 10);

    // U-shape opening down (top-left) - MEDIUM
    translate([2 + g, 36, wall_thickness])
        curved_u_divider(56 - g * 2, 32 - g, divider_height_medium, 10);

    // Large rounded rect right - SHORT with horizontal divider
    translate([62, 2 + g, wall_thickness])
        rounded_rect_divider(56 - g, 66 - g * 2, divider_height_short, 10);
    translate([72, 35, wall_thickness])
        chamfered_top(36, divider_thickness, divider_height_medium, chamfer_size);

    // Mixing hole between left sections
    translate([30, 34, wall_thickness + 2])
        mixing_hole(4);
}

// ============== DESIGN 10: Golden Ratio with Eno Depth ==============
module design_10() {
    outer_box();
    g = mixing_gap;

    // Golden ratio divisions
    lg_w = box_width / 1.618;
    sm_w = box_width - lg_w - 3;

    // Large rounded rect left - TALL (main chamber, clean separation)
    translate([2 + g, 2 + g, wall_thickness])
        rounded_rect_divider(lg_w - 2 - g, box_length - 4 - g * 2, divider_height_tall, 10);

    right_x = lg_w + 2;

    // Top-right tall U - MEDIUM
    translate([right_x, box_length / 2, wall_thickness])
        curved_u_up(sm_w - g, box_length / 2 - 3 - g, divider_height_medium, 8);

    // Bottom-right: two small squares - SHORT (bright accents)
    sq_size = (sm_w - 3) / 2;
    translate([right_x, 2 + g, wall_thickness])
        rounded_rect_divider(sq_size, box_length / 2 - 4 - g, divider_height_short, 6);

    translate([right_x + sq_size + 3, 2 + g, wall_thickness])
        rounded_rect_divider(sq_size - g, box_length / 2 - 4 - g, divider_height_short, 6);

    // Mixing holes for subtle color bleed
    translate([lg_w - 1, box_length / 2, wall_thickness + 2])
        rotate([0, 90, 0]) cylinder(h = 5, d = mixing_hole_size, $fn = 16);
    translate([right_x + sq_size - 1, box_length / 4, wall_thickness + 2])
        rotate([0, 90, 0]) cylinder(h = 5, d = mixing_hole_size, $fn = 16);
}

// ============== RENDER SELECTED DESIGN ==============
if (DESIGN_NUMBER == 1) design_1();
else if (DESIGN_NUMBER == 2) design_2();
else if (DESIGN_NUMBER == 3) design_3();
else if (DESIGN_NUMBER == 4) design_4();
else if (DESIGN_NUMBER == 5) design_5();
else if (DESIGN_NUMBER == 6) design_6();
else if (DESIGN_NUMBER == 7) design_7();
else if (DESIGN_NUMBER == 8) design_8();
else if (DESIGN_NUMBER == 9) design_9();
else if (DESIGN_NUMBER == 10) design_10();
else if (DESIGN_NUMBER == 11) design_11();
else if (DESIGN_NUMBER == 12) design_12();
else design_1();
