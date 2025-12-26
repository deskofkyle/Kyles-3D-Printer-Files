// Layered Acrylic Light Panel - Pixel Grid Gradient
// 10 layers of 3mm satinice acrylic (30mm total)
// Grid of square cells - more layers in center = darker, fewer at edges = lighter

// ============== PARAMETERS ==============

// Panel dimensions
panel_size = 200;         // Square panel size
layer_thickness = 3;      // 3mm satinice acrylic

// Grid parameters
grid_cells = 16;          // Number of cells per row/column (16x16 grid)
cell_gap = 1;             // Gap between cells (0 for no gap)

// Number of layers
num_layers = 10;          // 10 layers x 3mm = 30mm total

// Visualization
layer_spacing = 5;        // Gap between layers for exploded view
exploded_view = true;    // Set true to see layers separated

// ============== CALCULATED VALUES ==============

cell_size = (panel_size - (grid_cells + 1) * cell_gap) / grid_cells;
max_distance = sqrt(2) * (grid_cells / 2);  // Corner to center distance

// ============== OVERLAPPING RECTANGLES PATTERN ==============

// Define rectangles as [center_col, center_row, width, height, max_layer]
// max_layer = highest layer this rectangle appears on (0 = only layer 0, 9 = all layers)
// Higher max_layer = appears on more layers = darker
// Layer 0 is bottom (largest), Layer 9 is top (smallest)

// === ABSTRACT INTERSECTING BARS DESIGN ===
// Asymmetric offset bars - NOT a centered cross

rectangles = [
    // ---- VERTICAL BAR (shifted left, longer on top) ----
    [5.5, 1, 4, 4, 0],      // Top extension (light)
    [5.5, 4, 4, 4, 2],      // Upper section
    [5.5, 8, 4, 6, 4],      // Middle section (darker)
    [5.5, 13, 4, 4, 1],     // Bottom section (shorter, lighter)

    // ---- HORIZONTAL BAR (shifted down, longer on right) ----
    [1, 9.5, 4, 4, 0],      // Left end (light)
    [4.5, 9.5, 5, 4, 2],    // Left-center
    [9, 9.5, 6, 4, 4],      // Right-center (darker)
    [14, 9.5, 4, 4, 1],     // Right extension

    // ---- SECONDARY DIAGONAL ACCENT BAR ----
    [10, 4, 4, 3, 2],       // Upper right accent
    [11, 6, 3, 4, 3],       // Connects down

    // ---- H-SHAPED ELEMENTS (asymmetric placement) ----
    // Upper-left H (larger)
    [3, 2, 2, 5, 6],        // Left vertical
    [7, 2, 2, 5, 6],        // Right vertical
    [5, 2.5, 6, 2, 5],      // Connector

    // Lower-right H (smaller, offset)
    [11, 13, 2, 4, 6],      // Left vertical
    [14, 13, 2, 4, 6],      // Right vertical
    [12.5, 13.5, 5, 2, 5],  // Connector

    // Right-side rotated H
    [13, 5, 4, 2, 5],       // Top bar
    [13, 8, 4, 2, 5],       // Bottom bar
    [14, 6.5, 2, 5, 6],     // Connector

    // ---- CENTER BUILDUP (darkest point centered) ----
    [7.5, 7.5, 6, 6, 5],    // Center region
    [7.5, 7.5, 5, 5, 6],    // Inner region
    [7.5, 7.5, 4, 4, 7],    // Core
    [7.5, 7.5, 3, 3, 8],    // Inner core
    [7.5, 7.5, 2, 2, 9],    // Darkest point (centered)
];

// === BLUE MOSAIC TILES (gradient scatter - more at edges) ===
// Format: [col, row, size, max_layer]
// More tiles at edges, fewer toward center, various depths

blue_tiles = [
    // Corner clusters (deepest blue presence at edges)
    [0, 0, 2, 7],    [1, 2, 1, 5],    [2, 1, 1, 6],
    [0, 14, 2, 7],   [1, 12, 1, 5],   [2, 14, 1, 6],
    [14, 0, 2, 7],   [13, 2, 1, 5],   [14, 1, 1, 4],
    [14, 14, 2, 7],  [12, 13, 1, 5],  [13, 14, 1, 6],

    // Edge accents (medium depth)
    [0, 5, 1, 4],    [0, 10, 1, 5],
    [15, 4, 1, 4],   [15, 11, 1, 5],
    [4, 0, 1, 4],    [11, 0, 1, 5],
    [5, 15, 1, 4],   [10, 15, 1, 5],

    // Mid-edge scattered (lighter presence)
    [3, 3, 1, 3],    [12, 3, 1, 3],
    [3, 12, 1, 3],   [12, 12, 1, 3],

    // Sparse inner ring (very light blue hints)
    [4, 5, 1, 2],    [11, 5, 1, 2],
    [4, 10, 1, 2],   [11, 10, 1, 2],
    [5, 4, 1, 1],    [10, 4, 1, 1],
    [5, 11, 1, 1],   [10, 11, 1, 1],
];

// Check if cell is inside a rectangle
function in_rect(col, row, rect) =
    let(cx = rect[0], cy = rect[1], w = rect[2], h = rect[3])
    col >= cx - w/2 && col <= cx + w/2 &&
    row >= cy - h/2 && row <= cy + h/2;

// Check if cell is a blue tile
function in_blue_tile(col, row, tile) =
    let(tx = tile[0], ty = tile[1], sz = tile[2])
    col >= tx && col < tx + sz && row >= ty && row < ty + sz;

// Check if cell is blue on this layer
function is_blue_cell(col, row, layer) =
    len([for (t = blue_tiles) if (in_blue_tile(col, row, t) && t[3] >= layer) 1]) > 0;

// Cell appears on this layer if it's in a rectangle with max_layer >= layer
function cell_on_layer(col, row, layer) =
    len([for (r = rectangles) if (in_rect(col, row, r) && r[4] >= layer) 1]) > 0;

// ============== MODULES ==============

// Single cell at grid position
module cell_at(col, row) {
    x = cell_gap + col * (cell_size + cell_gap) - panel_size/2 + cell_size/2;
    y = cell_gap + row * (cell_size + cell_gap) - panel_size/2 + cell_size/2;

    translate([x, y, 0])
        square([cell_size, cell_size], center = true);
}

// Full panel square
module full_panel() {
    square([panel_size, panel_size], center = true);
}

// Satinice (frosted) cells for a layer - excludes blue tiles
module satinice_layer(layer_num) {
    linear_extrude(height = layer_thickness)
        for (col = [0 : grid_cells - 1]) {
            for (row = [0 : grid_cells - 1]) {
                if (cell_on_layer(col, row, layer_num) && !is_blue_cell(col, row, layer_num)) {
                    cell_at(col, row);
                }
            }
        }
}

// Blue acrylic tiles for a layer
module blue_layer(layer_num) {
    linear_extrude(height = layer_thickness)
        for (col = [0 : grid_cells - 1]) {
            for (row = [0 : grid_cells - 1]) {
                if (is_blue_cell(col, row, layer_num)) {
                    cell_at(col, row);
                }
            }
        }
}

// Clear acrylic filler (inverse of satinice and blue) for a layer
module clear_layer(layer_num) {
    linear_extrude(height = layer_thickness)
        difference() {
            full_panel();
            // Remove satinice cells
            for (col = [0 : grid_cells - 1]) {
                for (row = [0 : grid_cells - 1]) {
                    if (cell_on_layer(col, row, layer_num) && !is_blue_cell(col, row, layer_num)) {
                        cell_at(col, row);
                    }
                }
            }
            // Remove blue cells
            for (col = [0 : grid_cells - 1]) {
                for (row = [0 : grid_cells - 1]) {
                    if (is_blue_cell(col, row, layer_num)) {
                        cell_at(col, row);
                    }
                }
            }
        }
}

// Complete layer (satinice + clear = full square)
module complete_layer(layer_num) {
    satinice_layer(layer_num);
    clear_layer(layer_num);
}

// Legacy alias
module pixel_layer(layer_num) {
    satinice_layer(layer_num);
}

// ============== VISUALIZATION ==============

// Toggle to show clear acrylic filler
show_clear_acrylic = false;

// Full stack of all layers (satinice only)
module full_stack() {
    for (i = [0 : num_layers - 1]) {
        z_offset = exploded_view ? i * (layer_thickness + layer_spacing) : i * layer_thickness;

        // Color gradient for visualization
        color_val = 0.85 - (i / num_layers) * 0.3;

        translate([0, 0, z_offset])
            color([color_val, color_val, color_val + 0.05, 0.75])
                satinice_layer(i);
    }
}

// Full cube with all three materials
module full_cube() {
    for (i = [0 : num_layers - 1]) {
        z_offset = exploded_view ? i * (layer_thickness + layer_spacing) : i * layer_thickness;

        translate([0, 0, z_offset]) {
            // Satinice (frosted) cells - white/frosted appearance
            color([0.92, 0.92, 0.95, 0.85])
                satinice_layer(i);

            // Blue acrylic tiles - blue tinted
            color([0.3, 0.5, 0.9, 0.85])
                blue_layer(i);

            // Clear acrylic filler - transparent
            if (show_clear_acrylic) {
                color([0.95, 0.98, 1.0, 0.25])
                    clear_layer(i);
            }
        }
    }
}

// LED backlight panel (for visualization)
module led_panel() {
    translate([0, 0, -10])
        color([0.1, 0.1, 0.15])
            linear_extrude(height = 3)
                square([panel_size + 30, panel_size + 30], center = true);
}

// Show layer coverage info
module info() {
    echo("=== Pixel Grid Gradient Panel ===");
    echo(str("Panel size: ", panel_size, "mm x ", panel_size, "mm"));
    echo(str("Grid: ", grid_cells, " x ", grid_cells, " cells"));
    echo(str("Cell size: ", cell_size, "mm"));
    echo(str("Total layers: ", num_layers));
    echo(str("Total thickness: ", num_layers * layer_thickness, "mm"));
}

// ============== INDIVIDUAL LAYER EXPORTS ==============

// Satinice (frosted) layer exports
module export_satinice_0() { satinice_layer(0); }
module export_satinice_1() { satinice_layer(1); }
module export_satinice_2() { satinice_layer(2); }
module export_satinice_3() { satinice_layer(3); }
module export_satinice_4() { satinice_layer(4); }
module export_satinice_5() { satinice_layer(5); }
module export_satinice_6() { satinice_layer(6); }
module export_satinice_7() { satinice_layer(7); }
module export_satinice_8() { satinice_layer(8); }
module export_satinice_9() { satinice_layer(9); }

// Clear acrylic layer exports
module export_clear_0() { clear_layer(0); }
module export_clear_1() { clear_layer(1); }
module export_clear_2() { clear_layer(2); }
module export_clear_3() { clear_layer(3); }
module export_clear_4() { clear_layer(4); }
module export_clear_5() { clear_layer(5); }
module export_clear_6() { clear_layer(6); }
module export_clear_7() { clear_layer(7); }
module export_clear_8() { clear_layer(8); }
module export_clear_9() { clear_layer(9); }

// Blue acrylic layer exports
module export_blue_0() { blue_layer(0); }
module export_blue_1() { blue_layer(1); }
module export_blue_2() { blue_layer(2); }
module export_blue_3() { blue_layer(3); }
module export_blue_4() { blue_layer(4); }
module export_blue_5() { blue_layer(5); }
module export_blue_6() { blue_layer(6); }
module export_blue_7() { blue_layer(7); }
module export_blue_8() { blue_layer(8); }
module export_blue_9() { blue_layer(9); }

// Export all satinice layers laid out flat
module export_all_satinice_flat() {
    spacing = panel_size + 20;
    cols = 5;

    for (i = [0 : num_layers - 1]) {
        col = i % cols;
        row = floor(i / cols);
        translate([col * spacing, row * spacing, 0])
            satinice_layer(i);
    }
}

// Export all clear layers laid out flat
module export_all_clear_flat() {
    spacing = panel_size + 20;
    cols = 5;

    for (i = [0 : num_layers - 1]) {
        col = i % cols;
        row = floor(i / cols);
        translate([col * spacing, row * spacing, 0])
            clear_layer(i);
    }
}

// Export all blue layers laid out flat
module export_all_blue_flat() {
    spacing = panel_size + 20;
    cols = 5;

    for (i = [0 : num_layers - 1]) {
        col = i % cols;
        row = floor(i / cols);
        translate([col * spacing, row * spacing, 0])
            blue_layer(i);
    }
}

// ============== RENDER ==============

info();
led_panel();
full_cube();  // Shows complete cube with satinice + clear acrylic
// full_stack();  // Uncomment to show satinice only

// Uncomment for flat export layouts:
// export_all_satinice_flat();
// export_all_clear_flat();
