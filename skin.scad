use <scad-utils/transformations.scad>
use <scad-utils/lists.scad>

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

  polyhedron(convexity=2, points=profiles, faces=concat(start_cap, triangles, end_cap));
}

// Augments the profile with steiner points making the total number of vertices n
function augment_profile(profile, n) =
  subdivide(
    profile,
    insert_extra_vertices_1(
      [profile_lengths(profile),
       dup(0,len(profile))
      ],
      n-len(profile)
    )[1]
  );

function subdivide(profile,subdivisions) = let (N=len(profile)) [
  for (i = [0:N-1])
    let(n = len(subdivisions)>0 ? subdivisions[i] : subdivisions)
      for (p = interpolate(profile[i],profile[(i+1)%N],n+1))
        p
];

function interpolate(a,b,subdivisions) = [
  for (index = [0:subdivisions-1])
    let(t = index/subdivisions)
      a*(1-t)+b*t
];

function distribute_extra_vertex(lengths_count,ma_=-1) =
  ma_<0
	? distribute_extra_vertex(lengths_count, max_element(lengths_count[0]))
  : concat(
      [set(lengths_count[0],ma_,lengths_count[0][ma_] * (lengths_count[1][ma_]+1) / (lengths_count[1][ma_]+2))],
      [increment(lengths_count[1],max_element(lengths_count[0]),1)]);

function insert_extra_vertices_0(lengths_count,n_extra) =
  n_extra <= 0
	? lengths_count
  : insert_extra_vertices_0(
      distribute_extra_vertex(lengths_count),
      n_extra-1
    );



function insert_extra_vertices_1(lengths_count,n_extra) =
  n_extra <= 0 ?
    lengths_count
  :
    insert_extra_vertices_by_length(lengths_count[0], lengths_count[1], sum(lengths_count[0]), 0, n_extra);

function insert_extra_vertices_by_length(lengths, counts, length, curr, n) =
  curr >= n ?
    [lengths, counts]
  :
    insert_extra_vertices_by_length(
      lengths,
      insert_extra_vertex_at_length(lengths,counts,(curr+.5)/n*length),
      length,
      curr+1,
      n);

function insert_extra_vertex_at_length(lengths, counts, length) =
  increment(counts, element_at_length(lengths, length));

function element_at_length(lengths, length, i=0, acc=0) =
  acc+lengths[i] >= length || i >= len(lengths)?
    i
  :
    element_at_length(lengths, length, i+1, acc+lengths[i]);

/*
// unit tests for element_at_length

assert(element_at_length([1,2,1,3], 0)==0);
assert(element_at_length([1,2,1,3], .5)==0);
assert(element_at_length([1,2,1,3], 1)==0);
assert(element_at_length([1,2,1,3], 1.5)==1);
assert(element_at_length([1,2,1,3], 2.5)==1);
assert(element_at_length([1,2,1,3], 3)==1);
assert(element_at_length([1,2,1,3], 3.5)==2);
assert(element_at_length([1,2,1,3], 6.5)==3);
assert(element_at_length([1,2,1,3], 7)==3);
assert(element_at_length([1,2,1,3], 7.5)==4);


function assertion_failed() = (assertion_failed());
module assert(bool, msg = ""){if(bool == false){echo("Assertion Failed: ", msg);
  echo("", assertion_failed());}}
*/




// Find the index of the maximum element of arr
function max_element(arr,ma_,ma_i_=-1,i_=0) = i_ >= len(arr) ? ma_i_ :
  i_ == 0 || arr[i_] > ma_ ? max_element(arr,arr[i_],i_,i_+1) : max_element(arr,ma_,ma_i_,i_+1);

function max_len(arr) = max([for (i=arr) len(i)]);

function increment(arr,i,x=1) = set(arr,i,arr[i]+x);

function profile_lengths(profile) = [
  for (i = [0:len(profile)-1])
    profile_segment_length(profile,i)
];

function overall_length(profile) = sum(profile_lengths(profile));

function sum(arr, i=0, acc=0) =
  len(arr) <= i ?
    acc
  :
    sum(arr, i+1, acc+arr[i]);

function profile_segment_length(profile,i) = norm(profile[(i+1)%len(profile)] - profile[i]);

// Generates an array with n copies of value (default 0)
function dup(value=0,n) = [for (i = [1:n]) value];



/*
// demonstrate distribution of points
// if augment_profile uses insert_extra_vertices_0 or ..._1
// where insert_extra_vertices_1 inserts more uniformly
// whereas insert_extra_vertices_0 depends on chance rounding

// try changing which function augment_profile uses on line 39
// and with insert_extra_vertices_0 try changing 10.1 below

module point(coord) {
  color("red")
  translate(coord)
  cylinder(r=1, h=1.5, $fn=12);
}

use <scad-utils/shapes.scad>
a=circle($fn=20, r=10.1);
b=augment_profile(a,30); // distribute extra points
for(x=b)point(x);
*/
