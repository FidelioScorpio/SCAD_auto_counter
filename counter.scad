// based on https://www.thingiverse.com/thing:1290507
// and https://www.thingiverse.com/thing:3396213

// small modifications was made in these libraries
use <geneva.scad>
use <publicDomainGearV1.1.scad>

generate = 1; // [1:main parts, 2:wheel numbers, 3:logos, 4:perimeter blockers, 5:test - assembly]
generate_mainparts = 3; // [1:moon_wheel, 2:star_wheel, 3:thumb_wheel, 4:case_bottom, 5:case_top]
quality = 100; // [15:fast, 30:draft, 100:super smooth]
layer_height = 0.1; // [0.15:0.15, 0.2:0.2, 0.3:0.3]


with_top_logo = false;
top_logo_file = "OSH-top.svg";
// tenths of mm to expand top logo
top_logo_expand = 0;
with_bottom_logo = false;
bottom_logo_file = "OSH-bottom.svg";
// tenths of mm to expand bottom logo
bottom_logo_expand = 0;
// generate perimeter blockers for logos
with_logos_perimeter_blockers = false;
// number wheels size
wheel_radius = 16;
// wheel "spacer" on the axis
spacer_radius = 4;
// geneva parameter
pin_diameter = 2;
// geneva parameter
star_padding = 1;
// wheel segment height (3 segments on number wheels)
wheel_base_height = 2;
// gear parameter
mm_per_tooth = 2;
// all wheels axis diameter
hole_diameter = 3;
// global tolerance
clearance = 0.2;
// wheel numbers size
font_size = 5;
// wheel numbers font & style
font_style = "Liberation Sans:style=Bold";	// recommended, available on all platforms but FreeSans:style=Bold on Linux looks better
// case expand & roundness
case_roundness = 3.2;
// thumb spring
spring_thickness = 2.1;
// manual support for number holes in top part
support_thickness = 1.1;
// how round the holes for the letters are
letter_hole_roundness = 4;

//rotations for the assembly mode:
unit_rotate = -28 * 7; // multiply by the number of units wanted
tens_rotate = -36 * 0 + 180; // multiply by the number of tens wanted

generate_module();

// to test individual parts
//moon_wheel();
//star_wheel();
//star_numbers();
//star_blocker();
//thumb_wheel();
//thumb_numbers();
//case_bottom();
//thumb_blocker();
//case_top();
//case_rim();
//top_logo_blocker();
//bottom_logo_blocker();
//case_base(10);

module generate_module() {
	if (generate == 1)
		main_parts_();
	else if (generate == 2)
		wheel_numbers();
	else if (generate == 3)
		logos();
	else if (generate == 4)
		perimeter_blockers();
	else
		assembly();
}

$fn = quality;
moon_radius = 5;
tooth_compensation = 7;
thumb_wheel_rotation = 180;
thumb_slot_position = 3.5 * wheel_radius + 0.75 * case_roundness;
embos_cutout = 5 * layer_height;
spacer_height = layer_height;
thumb_slot_radius = thumb_slot_position / 2;
number_of_teeth = floor(moon_radius * 3.5 * 3.14 / mm_per_tooth);
geneva_distance = geneva_center_distance(moon_radius = moon_radius, count = 10);
geneva_star_radius = geneva_star_radius(moon_radius = moon_radius, count = 10);
gear_distance = 2 * pitch_radius(mm_per_tooth, number_of_teeth);
sizeX = geneva_distance + gear_distance + 2 * case_roundness;
sizeY = wheel_radius + 2 * case_roundness;
wheel_height = 3 * wheel_base_height;
hole_radius = hole_diameter / 2;
inner_cutout = case_roundness / 2 - spacer_height - clearance;
bottom_height = 2 * wheel_base_height + case_roundness / 2 - 2 * layer_height;
top_height = wheel_base_height + case_roundness / 2 + 2 * layer_height;
rim_height = 1.5 * wheel_base_height;
spring_height = wheel_base_height - clearance;
top_logo_expand_float = top_logo_expand / 10;
bottom_logo_expand_float = bottom_logo_expand / 10;

module main_parts_() 
{
    if (generate_mainparts == 1)
		moon_wheel();
    else if (generate_mainparts == 2)
        star_wheel();
	else if (generate_mainparts == 3)
		rotate([0, 0, thumb_wheel_rotation])
			thumb_wheel();
	else if (generate_mainparts == 4)
		case_bottom();
	else if (generate_mainparts == 5)
		case_top();
};

module main_parts() 
{
    // [1:moon_wheel, 2:star_wheel, 4:thumb_wheel, 8:case_bottom, 16:case_top]
    if (generate_mainparts)
	translate([-1.5 * sizeX, 0, 0])
		moon_wheel();
	translate([-1.5 * sizeX, 0.75 * gear_distance + geneva_distance, 0])
		star_wheel();
	translate([-1.5 * sizeX, -1.5 * sizeY, 0])
		rotate([0, 0, thumb_wheel_rotation])
			thumb_wheel();
	translate([0, -sizeY, bottom_height])
		rotate([0, 180, 180])
			case_bottom();
	translate([0, sizeY, top_height])
		rotate([0, 180, 180])
			case_top();
	translate([-1.5 * sizeX, geneva_distance, 0])
		rotate([0, 0, 90])
			case_rim();
};

module wheel_numbers() {
	translate([-1.5 * sizeX, 0.75 * gear_distance + geneva_distance, 0])
		star_numbers();
	translate([-1.5 * sizeX, -1.5 * sizeY, 0])
		rotate([0, 0, thumb_wheel_rotation])
			thumb_numbers();
};

module perimeter_blockers() {
	translate([-1.5 * sizeX, 0.75 * gear_distance + geneva_distance, 0])
		star_blocker();
	translate([-1.5 * sizeX, -1.5 * sizeY, 0])
		rotate([0, 0, thumb_wheel_rotation])
			thumb_blocker();
	if (with_logos_perimeter_blockers) {
		if (with_top_logo)
			translate([0, sizeY, top_height])
				rotate([0, 180, 180])
					top_logo_blocker();
		if (with_bottom_logo)
			translate([0, -sizeY, bottom_height])
				rotate([0, 180, 180])
					bottom_logo_blocker();
	}
};

module logos() {
	if (with_top_logo)
		translate([0, sizeY, top_height])
			rotate([0, 180, 180])
				top_logo();
	if (with_bottom_logo)
		translate([0, -sizeY, bottom_height])
			rotate([0, 180, 180])
				bottom_logo();
}

module assembly() {
	rot = atan(geneva_star_radius / moon_radius) + tooth_compensation;
	wheel_z = case_roundness / 2;
	intersection() 
    {
		union() {
			translate([0, 0, wheel_z])
				rotate([0, 0, rot])
					color("orange")
						moon_wheel();
			translate([geneva_distance, 0, wheel_z + wheel_height])
				rotate([0, 180, tens_rotate])//rotate([0, 180, 180])
					color("orange")
						star_wheel();
			translate([-gear_distance, 0, wheel_z + wheel_height])
				rotate([0, 180, unit_rotate])
					color("orange")
						thumb_wheel();
			color("lightblue")
					case_bottom();
			translate([0, 0, bottom_height + top_height])
				rotate([0, 180, 180])
					color("lightblue")
						case_top();
			
		}
//		translate([0, sizeY, wheel_height])
//			cube([5 * sizeX, 2 * sizeY, 2.2 * wheel_height], center = true);
	}
};

module case_base(height) {
	intersection() 
    {
		translate([0, 0, case_roundness]) minkowski() 
        {
			difference() 
            {
				inner(wheel_height - case_roundness);
				translate([-thumb_slot_position, 0, -clearance])
					cylinder(h = wheel_height - case_roundness + 2 * clearance,
							 r = thumb_slot_radius);
			}
			sphere(case_roundness);
		}
		translate([-sizeX, -sizeY, 0])
			cube([2 * sizeX, 2 * sizeY, height]);
	}
};

module inner(height, mod = 0) {
	radius = 1.075 * wheel_radius + clearance + mod;
	hull() {
		translate([geneva_distance, 0, 0]) cylinder(h = height, r = radius);
		translate([-gear_distance, 0, 0]) cylinder(h = height, r = radius);
	}
};

module case_rim() 
{
    let(fsc_rim_height = rim_height + 2 * clearance)
	difference() 
    {
        union()
        {
            // Original shape
            inner(fsc_rim_height, 0.5 * case_roundness - clearance);
            
            difference()
            {
                // Enlarged bottom to fuse with the case_bottom
                inner(fsc_rim_height, 0.5 * case_roundness);
                
                translate([0, 0, 2 * clearance + rim_height / 2])
                    inner(fsc_rim_height, case_roundness);
            }
        }
		
        // Thumb cutout
        translate([-thumb_slot_position - case_roundness / 2, 0, -0.05 * fsc_rim_height])
			cylinder(h = 1.1 * fsc_rim_height, r = thumb_slot_radius);
		
        // internal hole (bottom)
        translate([0, 0, -0.05 * fsc_rim_height]) difference() 
        {
			inner(1.1 * fsc_rim_height);
			translate([-thumb_slot_position, 0, -0.05 * fsc_rim_height])
				cylinder(h = 1.2 * fsc_rim_height, r = thumb_slot_radius);
		}
        
        // internal hole (top)
		translate([0, 0, fsc_rim_height / 2 + clearance])
			inner(fsc_rim_height);
            
        // lever
		translate([-gear_distance, 0, 2 * clearance - spring_height])
            rotate(a = 18, v=[0, 0, 1])
                translate([0, 0.72 * wheel_radius - spring_thickness / 2 - clearance, 0])
                    cube([2 * wheel_radius, spring_thickness + 2 * clearance, 2 * spring_height]);
	}
};

module case_top() {
	difference() {
		case_base(top_height);
		// inner cutout
		difference() {
			translate([0, 0, inner_cutout])
				inner(top_height);
			//number_holes(support_thickness);
		}
		// rim cutout
		translate([0, 0, top_height - 2 * clearance - rim_height / 2]) difference() {
			inner(rim_height, case_roundness / 2);
			translate([-thumb_slot_position - case_roundness / 2, 0, -0.05 * rim_height])
				cylinder(h = 1.1 * rim_height, r = thumb_slot_radius);
			number_holes(support_thickness);
		}
		number_holes();
		if (with_top_logo)
			top_logo();
	}
	// wheel pins
	rod_height = top_height - inner_cutout - spacer_height;
	translate([geneva_distance, 0, inner_cutout]) union() {
		translate([0, 0, spacer_height])
			cylinder(h = rod_height, r = hole_radius);
		cylinder(h = spacer_height, r = spacer_radius);
	}
	translate([-gear_distance, 0, inner_cutout]) union() {
		translate([0, 0, spacer_height])
			cylinder(h = rod_height, r = hole_radius);
		cylinder(h = spacer_height, r = spacer_radius);
	}
};

module number_holes(expand = 0) 
{
    module letter_hole(vector, r = 1)
    {
        let(cube_size = [vector.x - r + 0.01, vector.y - r + 0.01, vector.z/2])
        {
            minkowski()
            {
                cube(cube_size);
                translate([r/2, r/2, 0]) 
                  cylinder(d=r, h=vector.z/2);
            }
        }
    }
    let(x = font_size + expand, y = 1.25 * font_size + expand, z = wheel_height)
    {
        translate([geneva_distance - 0.8 * wheel_radius , 0, 0.5 * wheel_height])
            translate([-x/2,-y/2, -z/2]) letter_hole([x,y,z],letter_hole_roundness);
        translate([0.8 * wheel_radius - gear_distance, 0, 0.5 * wheel_height])
            translate([-x/2,-y/2, -z/2]) letter_hole([x,y,z],letter_hole_roundness);
    }
}

module top_logo(do_expand = false) {
	expand = do_expand ? top_logo_expand_float + clearance / 10 : top_logo_expand_float;
	translate([1.25 * geneva_distance, 0, embos_cutout])
		rotate([180, 0, 180])
			linear_extrude(embos_cutout)
				offset(r = expand)
					import(top_logo_file, center = true);
};

module top_logo_blocker() {
	difference() {
		inner(0.75 * layer_height, -support_thickness / 2);
		translate([-thumb_slot_position + support_thickness, 0, -0.05 * layer_height])
			cylinder(h = 1.1 * layer_height, r = thumb_slot_radius);
		translate([0, 0, -0.1 * embos_cutout])
			top_logo(true);
		number_holes(support_thickness);
	}
};

module case_bottom() 
{
    translate([0, 0, bottom_height - 2 * clearance - rim_height / 2])
        case_rim();
	difference() {
		case_base(bottom_height);
		// inner cutout
		translate([0, 0, inner_cutout]) difference() {
			inner(2 * wheel_height);
			translate([-thumb_slot_position, 0, -0.05 * wheel_height])
				cylinder(h = 1.1 * wheel_height, r = thumb_slot_radius);
		}
		// rim cutout
		translate([0, 0, bottom_height - 2 * clearance - rim_height / 2]) difference() {
			inner(rim_height, case_roundness / 2);
			translate([-thumb_slot_position - case_roundness / 2, 0, -0.05 * rim_height])
				cylinder(h = 1.1 * rim_height, r = thumb_slot_radius);
		}
		if (with_bottom_logo)
			bottom_logo();
	}
	// wheel pins
	rod_height = bottom_height - inner_cutout - spacer_height;
	translate([0, 0, inner_cutout]) union() {
		translate([0, 0, spacer_height])
			cylinder(h = rod_height, r = hole_radius);
		cylinder(h = spacer_height, r = spacer_radius);
	}
	translate([geneva_distance, 0, inner_cutout]) union() {
		translate([0, 0, spacer_height])
			cylinder(h = rod_height, r = hole_radius);
		cylinder(h = spacer_height, r = spacer_radius);
	}
	translate([-gear_distance, 0, inner_cutout]) union() {
		translate([0, 0, spacer_height])
			cylinder(h = rod_height, r = hole_radius);
		cylinder(h = spacer_height, r = spacer_radius);
	}
	// thumb wheel spring
	intersection() {
		translate([-gear_distance, 0, bottom_height - spring_height])
		rotate(a = 18, v=[0, 0, 1])
		translate([0, 0.72 * wheel_radius, 0]) union() {
			translate([0, -spring_thickness / 2, 0])
				cylinder(h = spring_height, r = 0.14 * wheel_radius, center = false);
			translate([0, -spring_thickness / 2, 0])
				cube([2 * wheel_radius, spring_thickness, spring_height]);
		}
		inner(wheel_height, case_roundness / 2 + clearance);
	}
};

module bottom_logo(do_expand = false) {
	expand = do_expand ? bottom_logo_expand_float + clearance / 10 : bottom_logo_expand_float;
	translate([0, 0, embos_cutout])
		rotate([180, 0, 180])
			linear_extrude(embos_cutout)
				offset(r = expand)
					import(bottom_logo_file, center = true);
};

module bottom_logo_blocker() {
	difference() {
		inner(0.75 * layer_height, -support_thickness / 2);
		translate([-thumb_slot_position + support_thickness, 0, -0.05 * layer_height])
			cylinder(h = 1.1 * layer_height, r = thumb_slot_radius);
		translate([0, 0, -0.1 * embos_cutout])
			bottom_logo(true);
	}
};

module moon_wheel() {
	difference() {
		union() {
			geneva_wheel(
				star = false,
				moon_radius = moon_radius,
				count = 10,
				height = 2 * wheel_base_height - clearance,
				pin_diameter = pin_diameter,
				spacer_thickness = wheel_base_height,
				arbor_diameter = hole_diameter + clearance,	// for easier movement
				clearance = clearance / 2,
				star_padding = star_padding);
			translate([0, 0, (wheel_base_height - clearance) / 2])
				rotate([0, 0, tooth_compensation])
					gear(mm_per_tooth = mm_per_tooth,
						number_of_teeth = number_of_teeth,
						thickness = wheel_base_height - clearance,
						hole_diameter = hole_diameter,
						clearance = clearance);
		}
		translate([0, 0, -0.05 * wheel_height])
			cylinder(h = 1.1 * wheel_height, r = (hole_diameter + clearance) / 2);
	}
};

module star_wheel() {
	translate([0, 0, wheel_height]) rotate([0, 180, 0]) difference() {
		union() {
			translate([0, 0, -clearance]) geneva_wheel(
				count = 10,
				moon_radius = moon_radius,
				pin_diameter = pin_diameter,
				height = 2 * (wheel_base_height + clearance),
				spacer_thickness = wheel_base_height,
				arbor_diameter = hole_diameter,
				clearance = clearance / 2,
				star_padding = star_padding);
			cylinder(h = wheel_base_height + clearance, r = spacer_radius);
			translate([0, 0, 2 * wheel_base_height]) difference() {
				cylinder(h = wheel_base_height, r = wheel_radius);
				translate([0, 0, wheel_base_height]) numbers(false);
			}
		}
		translate([0, 0, -0.05 * wheel_height])
			cylinder(h = 1.1 * wheel_height, r = (hole_diameter + clearance) / 2);
	}
};

module thumb_wheel() {
	hh = wheel_base_height + clearance;
	translate([0, 0, wheel_height]) rotate([0, 180, 0]) difference() {
		union() {
			translate([0, 0, hh / 2])
				gear(mm_per_tooth = mm_per_tooth,
					number_of_teeth = number_of_teeth,
					thickness = hh,
					hole_diameter = hole_diameter,
					clearance = clearance);
			translate([0, 0, wheel_base_height]) difference() {
				cylinder(h = hh, r = 0.66 * wheel_radius);
				for (i = [0:9]) rotate(a = 108 + i * 28, v=[0, 0, 1])
					translate([0.72 * wheel_radius, 0, -0.05 * hh])
						cylinder(h = 1.1 * hh,
								r = 0.14 * wheel_radius, center = false);
			}
			translate([0, 0, 2 * wheel_base_height]) union() {
				difference() {
					cylinder(h = wheel_base_height, r = wheel_radius);
					translate([0, 0, wheel_base_height]) numbers(true);
				}
				for (i = [0:36]) rotate(a = i * 10, v=[0, 0, 1])
					translate([wheel_radius, 0, 0])
						cylinder(h = wheel_base_height, r = wheel_radius / 20, center = false);
			}
		}
		translate([0, 0, -0.05 * wheel_height])
			cylinder(h = 1.1 * wheel_height, r = (hole_diameter + clearance) / 2);
	}
};

module star_blocker() {
	difference() {
		cylinder(h = layer_height, r = 0.95 * wheel_radius);
		rotate([0, 180, 0])
			numbers(false, true);
		translate([0, 0, -0.05 * layer_height])
			cylinder(h = 1.1 * layer_height, r = hole_diameter);
	}
};

module thumb_blocker() {
	difference() {
		cylinder(h = layer_height, r = 0.95 * wheel_radius);
		rotate([0, 180, 0])
			numbers(true, true);
		translate([0, 0, -0.05 * layer_height])
			cylinder(h = 1.1 * layer_height, r = hole_diameter);
	}
};

module star_numbers() {
	intersection() {
		cylinder(h = wheel_base_height, r = wheel_radius);
		rotate([0, 180, 0])
			numbers(false);
	}
};

module thumb_numbers() {
	intersection() {
		cylinder(h = wheel_base_height, r = wheel_radius);
		rotate([0, 180, 0])
			numbers(true);
	}
};

module numbers(ascension, expand = false) {
	for (i = [0:9]) rotate(a = i * (ascension ? 28 : 36), v = [0, 0, 1])
		translate([0.8 * wheel_radius, 0, -embos_cutout])
			rotate(a = ascension ? 180 : 0, v = [0, 0, 1])
				linear_extrude(height = embos_cutout + 0.1)
					offset(r = expand ? clearance / 10 : 0)
						text(str(i),
							halign = "center",
							valign = "center",
							font = font_style,
							size = font_size);
};
