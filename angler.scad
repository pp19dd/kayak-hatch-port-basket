// perfect circle makes everything easier

hatch_diameter = 175;   
hatch_depth = 140;
wall_thickness = 2;
bottom_thickness = 2;
brim_thickness = 1;
brim_overhang = 5;

hole_diameter = 9;
space_between_holes = 3;

// circle accuracy - greater is more circular but slower to draw
// at 60 / 20 the render time was 6 minutes
MAIN_FN = 60;
HOLE_FN = 20;

// camera settings, ignore
$vpr = [31.9, 0.00, 354.20];
$vpd = 760.50;

module main_cylinder_with_bottom() {
    $fn = MAIN_FN;
    difference() {
        cylinder(
            h = hatch_depth,
            d = hatch_diameter,
            center = true
        );
        translate([0,0,bottom_thickness])
        cylinder(
            h = hatch_depth,
            d = hatch_diameter - (wall_thickness*2),
            center = true
        );
    }
}

module side_holes() {
    
    // hole and its safe build space
    hole = hole_diameter + space_between_holes;
    
    remaining_space = hatch_depth - brim_thickness - bottom_thickness - hole;
    num_levels = floor(remaining_space / hole);

    module hole() {
        $fn = HOLE_FN;
        
        rotate([0, 90, 0])
        cylinder(
            h = wall_thickness * 4,
            d = hole_diameter,
            center = true
        );
    }

    // how many holes can we put in this ring?
    perimeter = 2 * PI * (hatch_diameter/2);
    num_holes = floor(perimeter / hole);

    module circuit() {

        for( a = [0 : 360 / num_holes : 360]) {
            rotate([0,0,a])
            translate([hatch_diameter/2,0,0])
            hole();
        }

    }
    
    for( level = [1 : 1 : num_levels] ) {
        translate([0, 0, -hatch_depth/2])
        translate([0, 0, hole/2])
        translate([0, 0, (hole * level)])
        rotate([0,0,level * hole])
        circuit();
    }
    
}

module bottom_holes() {
    
    // hole and its safe build space
    hole = hole_diameter + space_between_holes;
    
    remaining_space = (hatch_diameter / 2) - (hole);
    num_rings = floor(remaining_space / hole);
    
    module hole() {
        $fn = HOLE_FN;
        
        cylinder(
            h=bottom_thickness*4,
            d=hole_diameter,
            center=true
        );
    }    
    
    module circuit(radius) {
        // how many holes can we put in this ring?
        perimeter = 2 * PI * radius;
        
        num_holes = floor(perimeter / hole);
        
        for( i = [0 : 360 / num_holes : 360] ) {
            rotate([0,0,i])
            translate([radius, 0, 0])
            hole();
        }
    }
    
    translate([0,0,-hatch_depth/2]) {
        for( ring = [0 : 1 : num_rings] ) {
            circuit( ring * hole );
        }
    }
    
}

module brim() {
    $fn = MAIN_FN;
    
    translate([0,0,hatch_depth/2])
    translate([0,0,-brim_thickness])
    difference() {
        cylinder(
            h = brim_thickness,
            d = hatch_diameter + (brim_overhang*2)
        );
        translate([0,0,-1])
        cylinder(
            h = brim_thickness + 2,
            d = hatch_diameter
        );
    }
}

difference() {
    main_cylinder_with_bottom();
    union() {
        side_holes();
        bottom_holes();
    }
}

brim();
