/*
	Parametric Geneva Mechanism, v1.0
	Written by Jesse Donaldson, 2012
	
	This file defines the following useful stuff:
	
	module geneva_wheel(): 
		Used to create matching moon & star wheels for a geneva mechanism.
		e.g., Make a moon wheel: geneva_wheel(star:false, count:5, moon_radius:30);
		      Make a star wheel: geneva_wheel(star:true, count:5, moon_radius:30);
		
		See the module definition below for other supported arguments.
	

	function geneva_center_distance():
		Returns the proper center distance between wheels, based on the pitch radius of the moon wheel, and the notch count of the star wheel.
		e.g., geneva_center_distance(moon_radius:30, count:5)
	
	function geneva_star_radius():
		Returns the radius of the star wheel matching the given moon wheel pitch radius, and star wheel notch count.
		e.g., geneva_star_radius(moon_radius:30, count:5)
	
	function geneva_moon_outer_radius(moon_radius, pin_diameter)
		Returns the outer radius of the moon wheel, given the pitch radius and pin diameter.
		e.g., geneva_moon_outer_radius(moon_radius:30, pin_diameter:5)

*/


// An example showing the wheels arranged properly:
//geneva_screen_demo();

// A printable example with base & snap-on wheels:
geneva_printable_wheels();
geneva_printable_base();


// ***********
// * Examples:
// ***********

$fn=100;

test_count=5;		// 5 notches on star wheel
test_radius = 25;	// ~25mm moon wheel
test_pin = 10;		// large 10mm pin for demo purposes

// *** Screen demo:
module geneva_screen_demo() {
	translate([geneva_center_distance(moon_radius=test_radius, count=test_count),0,0]) 
		rotate([0,0,180+atan(geneva_star_radius(moon_radius=test_radius, count=test_count)/test_radius)])
			geneva_wheel(star=false, count=test_count, moon_radius=test_radius, pin_diameter=test_pin);
	geneva_wheel(count=test_count, moon_radius=test_radius, pin_diameter=test_pin);

}

// *** Printable wheels:
module geneva_printable_wheels() {

	// Make a moon wheel, add a handle, and move it off to the side:
	translate([test_radius + geneva_star_radius(moon_radius=test_radius, count=test_count)+test_pin,0,0]) 
		rotate([0,0,180+atan(geneva_star_radius(moon_radius=test_radius, count=test_count)/test_radius)])
			union() {
				geneva_wheel(star=false, count=test_count, moon_radius=test_radius, pin_diameter=test_pin);
				translate([-test_radius+6+test_pin/2,0,0]) {
					cylinder(h=20, r=2);
					translate([0,0,17]) sphere(r=5);
				}
			}
	
	// Make a star wheel and flip it upside down for printing:
	translate([0,0,6]) 
		rotate([0,180,0]) 
			geneva_wheel(count=test_count, moon_radius=test_radius, pin_diameter=test_pin);
	
}

// *** Printable base:
module geneva_printable_base() {
	// Make a base plate to hold the wheels:
	base_length=2*(geneva_star_radius(moon_radius=test_radius, count=test_count)+test_radius);
	base_width=2*max(geneva_star_radius(moon_radius=test_radius, count=test_count), test_radius);
	center_dist=geneva_center_distance(moon_radius=test_radius, count=test_count);
	base_height=3;
		
	translate([center_dist,base_width+4,base_height/2]) difference() { 
		union() {
			cube(size=[base_length, base_width, base_height], center=true);
			
			translate([center_dist/2,0,base_height/2]) geneva_snap_pivot(r=2, h=6);
			translate([-center_dist/2,0,base_height/2]) geneva_snap_pivot(r=2, h=6);
			
			// Optional skirt to help prevent warping.
			//cube(size=[base_length*1.1,base_width*1.2,0.2], center=true);
		}
	}
}


module geneva_snap_pivot(r, h) { // for the base
	h=h+0.35; // add a bit of vertical clearance.
	ridge_size=0.5;
	difference() {
		union() {
			cylinder(r=r, h=h+(2*ridge_size));
			translate([0,0,h+ridge_size]) rotate_extrude() {
				translate([r,0,0]) circle(r=ridge_size);
			}
			translate([0,0,h+ridge_size]) difference() {
				sphere(r=r+ridge_size);
				translate([0,0,-3*r/2]) cube(size=[3*r, 3*r, 3*r], center=true);
			}
		}
		slot_height=h+r+(2*ridge_size);
		translate([0,0,slot_height/1.25 ]) cube(size=[2*ridge_size, r*3, slot_height], center=true);
	}
}


// *****************
// * Implementation:
// *****************

	// A right triangle is formed by the lines from the wheel centers to the pin center where it crosses the 
	// star wheel circumference.  The angles adjecent to the hypotenuse depend on the star wheel "count".
	// The first side, radius of the moon wheel, is given as moon_pitch_radius.
	// The second side is the radius of the star wheel.
	// The hypotenuse, between the wheel centers, is the center distance.
function geneva_star_radius(moon_radius, count) = moon_radius/tan(360/count/2);
function geneva_center_distance(moon_radius, count) = sqrt((moon_radius*moon_radius) + (geneva_star_radius(moon_radius, count)*geneva_star_radius(moon_radius, count)));

	// Radius of spacer disk on bottom of moon wheel.  
	// Slightly large to help prevent the star points from snagging on the edge of the moon wheel.
function geneva_moon_outer_radius(moon_radius, pin_diameter) = moon_radius + (pin_diameter/2) + 1;


module geneva_wheel(
	star = true,		// true to generate a star wheel, false to make a moon wheel.
	moon_radius = 25, // The pitch radius of the moon wheel; distance from center of moon wheel to center of pin.
	count = 4, // number of turns of the moon wheel to cause 1 full rotation of the star wheel
	height = 6, // total height of wheels in mm
	pin_diameter = 5, // in mm
	arbor_diameter = 4, // size of center hole, in mm
	spacer_thickness = 2, // thickness of bottom spacer portion of the wheels
	clearance = 0.35, // mm between pin and slot edges, moon & star wheel journal surfaces, etc.	
	star_padding = 2,	// extra space allocated at the ends of star points, so they're not super-thin
	)
{
	
	pin_radius = pin_diameter/2;
	center_distance = geneva_center_distance(moon_radius=moon_radius, count=count);
	star_radius = geneva_star_radius(moon_radius, count)-pin_radius-clearance; // radius of star wheel
	moon_spacer_radius = geneva_moon_outer_radius(moon_radius=moon_radius, pin_diameter=pin_diameter);
	cutout_overlap = 0.1; // Small fudge factor used to ensure proper differences.
		
	difference() { // cut out arbor hole
	
		if(star) {
			//***
			//* Star Wheel
			//***
			
			difference() { // remove round cutouts & arbor hole
				
				union() { // star & spacer
			
					// spacer disk
//					cylinder(h=height, r=center_distance - moon_spacer_radius - clearance);					
					// star disk
					translate([0,0,spacer_thickness+clearance]) {
						cylinder(h=height - spacer_thickness-clearance, r=star_radius);
					}
				}
				
				for(i=[0:count]) { // round cutouts on star wheel
					rotate([0,0,i*(360/count)]) translate([center_distance,0,cutout_overlap]) cylinder(h=height, r=moon_radius-pin_radius-star_padding);
				}
				
				// star wheel slots:
				slot_length = star_radius+moon_radius-center_distance;
				for(i=[0:count]) {		
					rotate([0,0,(i+0.5)*(360/count)]) union() {
						translate([star_radius-(slot_length/2),0,0]) cube(size=[slot_length,pin_diameter, height*3], center=true);
						translate([star_radius-slot_length,0,0]) cylinder(h=height*3, r=pin_radius, center=true);
					}
				}
			}
					
			
		} else {
			
			//***
			//* Moon Wheel
			//***
			
			union() {
//				cylinder(h=spacer_thickness, r=moon_spacer_radius); // large bottom spacer disk
				translate([moon_radius,0,0]) {	// pin
					cylinder(h=height, r=pin_radius - clearance);
				}
	
				// moon disk
				difference() {
					cylinder(h=height, r=moon_radius-pin_radius-star_padding-clearance);
					translate([center_distance, 0, -cutout_overlap]) {
						cylinder(h=height+(2*cutout_overlap), r=star_radius+2*clearance);
					}
				}
			}
		}
		
		// arbor hole
		translate([0,0,-cutout_overlap]) {
			cylinder(h=height+(cutout_overlap*2), r=(arbor_diameter+clearance)/2);
		}
	}
}


