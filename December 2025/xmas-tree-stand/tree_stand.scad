// Christmas Tree Stand
// Ring with flat top plate

// Ring parameters
ring_inner_diameter = 120;  // mm
ring_thickness = 6;         // wall thickness in mm
ring_height = 10;           // height of the ring (adjust as needed)
ring_outer_diameter = ring_inner_diameter + (2 * ring_thickness);  // 140mm

// Top plate parameters
plate_diameter = 200;       // mm
plate_thickness = 3;        // mm

// Ring (hollow cylinder)
difference() {
    cylinder(d = ring_outer_diameter, h = ring_height, $fn = 100);
    translate([0, 0, -0.1])
        cylinder(d = ring_inner_diameter, h = ring_height + 0.2, $fn = 100);
}

// Top flat plate (sits on top of the ring)
translate([0, 0, ring_height])
    cylinder(d = plate_diameter, h = plate_thickness, $fn = 100);
