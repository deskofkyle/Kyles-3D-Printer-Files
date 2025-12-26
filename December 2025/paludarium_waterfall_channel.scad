// Paludarium Waterfall Channel for UNS 5E
// Simplified cascading design from top-left to bottom-right
// Author: Kyle Ryan
// Date: December 2025

/* [Tank Parameters - UNS 5E] */
tank_length = 360;  // 14.17"
tank_depth = 220;   // 8.66"
tank_back_height = 220;  // 8.66"

/* [Waterfall Path Parameters] */
start_x = 20;
start_y = 20;
start_z = 180;
end_x = 300;
end_y = 180;
end_z = 30;

/* [Channel Parameters] */
channel_width = 30;
wall_height = 10;
wall_thickness = 3;
num_tiers = 4;

/* [Tubing Parameters] */
tubing_od = 8;  // 8mm pump tubing
tubing_channel_dia = tubing_od + 1;  // Slight clearance for tubing

/* [Render Quality] */
$fn = 32;

// === CALCULATED VALUES ===
total_drop = start_z - end_z;
tier_drop = total_drop / num_tiers;
tier_length = 60;  // Fixed tier length for simplicity
tier_width = channel_width + wall_thickness * 2;

echo("=== WATERFALL CHANNEL ===");
echo(str("Total drop: ", total_drop, " mm"));
echo(str("Drop per tier: ", tier_drop, " mm"));

// === MODULES ===

// Channel trough with walls, inlet notch, and pour spout at outlet end
module channel_trough(length, width, height, has_inlet=false) {
    spout_width = 16;

    difference() {
        // Outer shell
        cube([length, width, height]);

        // Inner channel carved out (open top)
        translate([wall_thickness, wall_thickness, wall_thickness])
            cube([length - wall_thickness * 2, width - wall_thickness * 2, height + 1]);

        // Pour spout notch at outlet end (+X end, which is lower due to tilt)
        translate([length - wall_thickness - 1, (width - spout_width) / 2, wall_thickness])
            cube([wall_thickness + 2, spout_width, height + 1]);

        // Inlet notch at receiving end (for water from tier above)
        if (has_inlet) {
            translate([-1, (width - spout_width) / 2, wall_thickness])
                cube([wall_thickness + 2, spout_width, height + 1]);
        }
    }
}

// Support leg from tier down to base
module support_leg(height, top_pos) {
    base_dia = 12;

    // Tapered column
    translate([top_pos[0], top_pos[1], 0])
        cylinder(h = height, d1 = base_dia, d2 = base_dia * 0.7);
}

// Main waterfall assembly
module waterfall_channel() {
    difference() {
        union() {
            // Generate tiers in a diagonal cascade
            for (i = [0 : num_tiers - 1]) {
                progress = i / (num_tiers - 1);

                // Position each tier along diagonal path
                tier_x = start_x + (end_x - start_x - tier_length) * progress;
                tier_y = start_y + (end_y - start_y - tier_width) * progress;
                tier_z = start_z - tier_drop * i - tier_drop;

                // Slight angle offset for visual interest
                tier_angle = i * 5;

                // The tier trough - outlets on all, inlet notch on all except first
                is_first = (i == 0);
                translate([tier_x, tier_y, tier_z])
                    rotate([0, -5, tier_angle])  // Tilt so +X end is lower (where spout is)
                        channel_trough(tier_length, tier_width, wall_height + wall_thickness, has_inlet = !is_first);

                // Support legs - use hull from tier attachment point down to base
                // Attachment points in tier's local coords (before any rotation)
                for (leg_x_local = [10, tier_length - 10]) {
                    hull() {
                        // Top attachment - transformed with the tier
                        translate([tier_x, tier_y, tier_z])
                            rotate([0, -5, tier_angle])
                                translate([leg_x_local, tier_width/2, 0])
                                    cylinder(h = 2, d = 10);
                        // Base - straight down at Z=0
                        translate([tier_x, tier_y, 0])
                            rotate([0, 0, tier_angle])
                                translate([leg_x_local, tier_width/2, 0])
                                    cylinder(h = wall_thickness, d = 12);
                    }
                }

                // Channel connecting to next tier
                if (i < num_tiers - 1) {
                    next_progress = (i + 1) / (num_tiers - 1);
                    next_x = start_x + (end_x - start_x - tier_length) * next_progress;
                    next_y = start_y + (end_y - start_y - tier_width) * next_progress;
                    next_z = start_z - tier_drop * (i + 1) - tier_drop;

                    chute_width = 20;
                    chute_inner = 14;

                    // Connecting chute with walls
                    difference() {
                        // Outer shell of chute
                        hull() {
                            translate([tier_x + tier_length - 5, tier_y + tier_width/2 - chute_width/2, tier_z])
                                cube([10, chute_width, wall_height]);
                            translate([next_x, next_y + tier_width/2 - chute_width/2, next_z + wall_height])
                                cube([10, chute_width, wall_height]);
                        }
                        // Carve inner channel
                        hull() {
                            translate([tier_x + tier_length - 6, tier_y + tier_width/2 - chute_inner/2, tier_z + wall_thickness])
                                cube([12, chute_inner, wall_height]);
                            translate([next_x - 1, next_y + tier_width/2 - chute_inner/2, next_z + wall_height + wall_thickness])
                                cube([12, chute_inner, wall_height]);
                        }
                    }
                }
            }

            // Tubing inlet column at start
            translate([start_x - 15, start_y + tier_width/2, 0]) {
                cylinder(h = start_z, d = tubing_channel_dia + wall_thickness * 3);

                // Connect column to first tier
                hull() {
                    translate([0, 0, start_z - 10])
                        cylinder(h = 10, d = tubing_channel_dia + wall_thickness * 3);
                    translate([20, 0, start_z - tier_drop])
                        cylinder(h = 10, d = 10);
                }
            }

            // Base plate connecting all supports
            linear_extrude(height = wall_thickness) {
                hull() {
                    translate([start_x - 15, start_y + tier_width/2]) circle(d = 20);
                    translate([start_x + 10, start_y + tier_width/2]) circle(d = 15);
                }
                for (i = [0 : num_tiers - 1]) {
                    progress = i / (num_tiers - 1);
                    tier_x = start_x + (end_x - start_x - tier_length) * progress;
                    tier_y = start_y + (end_y - start_y - tier_width) * progress;

                    hull() {
                        translate([tier_x + 10, tier_y + tier_width/2]) circle(d = 15);
                        translate([tier_x + tier_length - 10, tier_y + tier_width/2]) circle(d = 15);
                    }
                }
            }
        }

        // Vertical bore for tubing (starts above base)
        translate([start_x - 15, start_y + tier_width/2, wall_thickness])
            cylinder(h = start_z + 10, d = tubing_channel_dia);

        // Horizontal entry hole at base for pump tubing (comes in from side)
        translate([start_x - 15 - 20, start_y + tier_width/2, wall_thickness + tubing_channel_dia/2 + 2])
            rotate([0, 90, 0])
                cylinder(h = 25, d = tubing_channel_dia);

        // Angled outlet from tubing to first tier
        translate([start_x - 15, start_y + tier_width/2, start_z - 5])
            rotate([0, 60, 30])
                cylinder(h = 35, d = tubing_channel_dia);
    }
}

// === MAIN RENDER ===
waterfall_channel();

// === INFO ===
echo("");
echo("=== PRINT SETTINGS ===");
echo("Material: PETG (aquarium-safe)");
echo("Infill: 50%+");
echo("Walls: 3+ perimeters");
echo("Supports: YES");
