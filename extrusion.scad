use <scad-utils/transformations.scad>
use <scad-utils/lists.scad>
use <scad-utils/shapes.scad>
use <skin.scad>

fn=32;

skin([
	transform(translation([0,0,0]), rounded_rectangle_profile([2,4],fn=fn,r=.5)),
	transform(translation([0,0,2]), rounded_rectangle_profile([2,4],fn=fn,r=.5)),
	transform(translation([0,0,3]), circle($fn=fn,r=0.5)),
	transform(translation([0,0,4]), circle($fn=fn,r=0.5)),
	transform(translation([0,0,4]), circle($fn=fn,r=0.6)),
	transform(translation([0,0,5]), circle($fn=fn,r=0.5)),
	transform(translation([0,0,5]), circle($fn=fn,r=0.6)),
	transform(translation([0,0,6]), circle($fn=fn,r=0.5)),
	transform(translation([0,0,6]), circle($fn=fn,r=0.6)),
	transform(translation([0,0,7]), circle($fn=fn,r=0.5)),
]);


rotate([90,0,0]) translate([0,0,3]) difference() {
	skin(morph(
		profile1=rectangle_profile([2,.2]),
		profile2=transform(translation([0,0,3]), circle($fn=64,r=0.5)),
		slices=40)
	);
	
	skin(morph(
		profile1=transform(translation([0,0,-.01]), rectangle_profile([1.9,0.1])),
		profile2=transform(translation([0,0,3.01]), circle($fn=64,r=0.45)),
		slices=40)
	);
}


function rectangle_profile(size=[1,1]) = [	
	// The first point is the anchor point, put it on the point corresponding to [cos(0),sin(0)]
	[ size[0]/2,  0], 
	[ size[0]/2,  size[1]/2],
	[-size[0]/2,  size[1]/2],
	[-size[0]/2, -size[1]/2],
	[ size[0]/2, -size[1]/2],
];

function rounded_rectangle_profile(size=[1,1],r=1,fn=32) = [
	for (index = [0:fn-1])
		let(a = index/fn*360) 
			r * [cos(a), sin(a)] 
			+ sign_x(index, fn) * [size[0]/2-r,0]
			+ sign_y(index, fn) * [0,size[1]/2-r]
];

function sign_x(i,n) = 
	i < n/4 || i > n-n/4  ?  1 :
	i > n/4 && i < n-n/4  ? -1 :
	0;

function sign_y(i,n) = 
	i > 0 && i < n/2  ?  1 :
	i > n/2 ? -1 :
	0;

function interpolate_profile(profile1, profile2, t) = (1-t) * profile1 + t * profile2;

// Morph two profile
function morph(profile1, profile2, slices=1, fn=0) = morph0(
	augment_profile(to_3d(profile1),max(len(profile1),len(profile2),fn)),
	augment_profile(to_3d(profile2),max(len(profile1),len(profile2),fn)),
	slices
);

function morph0(profile1, profile2, slices=1) = [
	for(index = [0:slices-1])
		interpolate_profile(profile1, profile2, index/(slices-1))
];


// The area of a profile
//function area(p, index_=0) = index_ >= len(p) ? 0 :
function pseudo_centroid(p,index_=0) = index_ >= len(p) ? [0,0,0] :
	p[index_]/len(p) + pseudo_centroid(p,index_+1);


//// Nongeneric helper functions

function profile_distance(p1,p2) = norm(pseudo_centroid(p1) - pseudo_centroid(p2));

function rate(profiles) = [ 
	for (index = [0:len(profiles)-2]) [
		profile_length(profiles[index+1]) - profile_length(profiles[index]), 
     	profile_distance(profiles[index], profiles[index+1])
    ]
];

function profiles_lengths(profiles) = [ for (p = profiles) profile_length(p) ];

function profile_length(profile,i=0) = i >= len(profile) ? 0 :
	 profile_segment_length(profile, i) + profile_length(profile, i+1);

function expand_profile_vertices(profile,n=32) = len(profile) >= n ? profile : expand_profile_vertices_0(profile,profile_length(profile),n);

