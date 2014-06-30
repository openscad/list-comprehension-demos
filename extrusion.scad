use <scad-utils/transformations.scad>
use <scad-utils/lists.scad>
use <scad-utils/shapes.scad>

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

// Skin a set of profiles with a polyhedral mesh
module skin(profiles, loop=false /* unimplemented */) {
	P = max_len(profiles);
	N = len(profiles);

	profiles = [ 
		for (p = profiles)
			for (pp = augment_profile(to_3d(p),P))
				pp
	];

	function quad(i,P,o) = [[o+i, o+i+P, o+i%P+P+1], [o+i, o+i%P+P+1, o+i%P+1]];

	function profile_triangles(tindex) = [
		for (index = [0:P-1]) 
			let (qs = quad(index+1, P, P*(tindex-1)-1)) 
				for (q = qs) q
	];

    triangles = [ 
		for(index = [1:N-1])
        	for(t = profile_triangles(index)) 
				t
	];
	
	start_cap = [range([0:P-1])];
	end_cap   = [range([P*N-1 : -1 : P*(N-1)])];

	polyhedron(points=profiles, faces=concat(start_cap, triangles, end_cap));
}

//// Some random generic functions

// Generates an array with n copies of value (default 0)
function dup(value=0,n) = [for (i = [1:n]) value];

// Find the index of the maximum element of arr
function max_element(arr,ma_,ma_i_=-1,i_=0) = i_ >= len(arr) ? ma_i_ :
	i_ == 0 || arr[i_] > ma_ ? max_element(arr,arr[i_],i_,i_+1) : max_element(arr,ma_,ma_i_,i_+1);
// Alernative, using list comprehensions:
//function max_element(arr) = let (m=max(arr)) [for (i=[0:len(arr)-1]) if (arr[i]==m) i][0];

//// Range functions

// Augments the profile with steiner points making the total number of vertices n 
function augment_profile(profile, n) = 
	subdivide(profile,insert_extra_vertices_0([profile_lengths(profile),dup(0,len(profile))],n-len(profile))[1]);

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

function profile_segment_length(profile,i) = norm(profile[(i+1)%len(profile)] - profile[i]);

function profile_lengths(profile) = [ 
	for (i = [0:len(profile)-1])
		profile_segment_length(profile,i)
];

function profile_length(profile,i=0) = i >= len(profile) ? 0 :
	 profile_segment_length(profile, i) + profile_length(profile, i+1);

function expand_profile_vertices(profile,n=32) = len(profile) >= n ? profile : expand_profile_vertices_0(profile,profile_length(profile),n);

function increment(arr,i,x=1) = set(arr,i,arr[i]+x);

function distribute_extra_vertex(lengths_count,ma_=-1) =
ma_<0 ?
distribute_extra_vertex(lengths_count, max_element(lengths_count[0])) :
concat(
    [set(lengths_count[0],
         ma_,
         lengths_count[0][ma_] * (lengths_count[1][ma_]+1) / (lengths_count[1][ma_]+2))
    ],
    [increment(lengths_count[1],max_element(lengths_count[0]),1)]
);

function insert_extra_vertices_0(lengths_count,n_extra) = n_extra <= 0 ? lengths_count : 
	insert_extra_vertices_0(distribute_extra_vertex(lengths_count),n_extra-1);

function max_len(arr) = max([for (i=arr) len(i)]);

function interpolate(a,b,subdivisions) = [
	for (index = [0:subdivisions-1])
		let(t = index/subdivisions)
			a*(1-t)+b*t
];

function subdivide(profile,subdivisions) = let (N=len(profile)) [
	for (i = [0:N-1])
		let(n = len(subdivisions)>0 ? subdivisions[i] : subdivisions)
			for (p = interpolate(profile[i],profile[(i+1)%N],n+1))
				p
];
