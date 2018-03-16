//=====================================
// This is public Domain Code
// Contributed by: William A Adams
// 11 May 2011
// 2017-03-12: Gael Lafond
//   Original from: http://www.thingiverse.com/thing:8483
//=====================================

// Usage:
//   bezier_polygon(array of points and handles);
// Example:
//   bezier_polygon([
//     [[  0,   0],[  0, -30],[-50, -30],[-50,   0]],
//     [[-50,   0],[-50,  30],[  0,  35],[  0,  60]]
//   ]);


//=======================================
// Functions
// These are the 4 blending functions for a cubic bezier curve
//=======================================

/*
	Bernstein Basis Functions

	For Bezier curves, these functions give the weights per control point.
*/
function BEZ03(u) = pow((1-u), 3);
function BEZ13(u) = 3*u*(pow((1-u),2));
function BEZ23(u) = 3*(pow(u,2))*(1-u);
function BEZ33(u) = pow(u,3);

// Calculate a singe point along a cubic bezier curve
// Given a set of 4 control points, and a parameter 0 <= 'u' <= 1
// These functions will return the exact point on the curve
function bezier_2D_point(p0, p1, p2, p3, u) = [
	BEZ03(u)*p0[0]+BEZ13(u)*p1[0]+BEZ23(u)*p2[0]+BEZ33(u)*p3[0],
	BEZ03(u)*p0[1]+BEZ13(u)*p1[1]+BEZ23(u)*p2[1]+BEZ33(u)*p3[1]
];

function bezier_3D_point(p0, p1, p2, p3, u) = [
	BEZ03(u)*p0[0]+BEZ13(u)*p1[0]+BEZ23(u)*p2[0]+BEZ33(u)*p3[0],
	BEZ03(u)*p0[1]+BEZ13(u)*p1[1]+BEZ23(u)*p2[1]+BEZ33(u)*p3[1],
	BEZ03(u)*p0[2]+BEZ13(u)*p1[2]+BEZ23(u)*p2[2]+BEZ33(u)*p3[2]
];

/**
 * Returns an array of points representing the polygon.
 * IMPORTANT: Construction an array in a for loop is a feature that has been added around 2014.
 *   Unfortunately, it doesn't seems to be any workaround.
 *   You will need a recent version of OpenSCAD to use this function.
 * Points: [
 *   [point1, bezier1-2, bezier2-1, point2],
 *   [point2, bezier2-3, bezier3-2, point3],
 *   [point3, bezier3-4, bezier4-3, point4],
 *   ...,
 *   [pointN, bezierN-1, bezier1-N, point1]
 * ]
 */
function bezier_coordinates(points, steps) = [
	for (c = points)
		for (step = [0:steps])
			bezier_2D_point(c[0], c[1], c[2],c[3], step/steps)
];

module _bezier_draw_handle(point, handle, handleOpacity) {
	lineWidth = 0.5;
	circleRadius = 1;

	if (point[0] != handle[0] || point[1] != handle[1]) {
		deltaX = point[0] - handle[0];
		deltaY = point[1] - handle[1];
		distance = sqrt(deltaX*deltaX + deltaY*deltaY);
		angle = atan2(deltaY, deltaX) + 90;

		color([0, 0, 0, handleOpacity]) {
			// Line
			translate([point[0], point[1], 0]) {
				rotate([0, 0, angle]) {
					translate([-lineWidth/2, 0, 0]) {
						square([lineWidth, distance - circleRadius]);
					}
				}
			}

			// Handle
			translate([handle[0], handle[1], 0]) {
				difference() {
					circle(r = circleRadius);
					circle(r = circleRadius * 0.75);
				}
			}
		}
	}
	color([0, 0, 0, handleOpacity]) {
		// Points
		translate([point[0], point[1], 0])
			circle(r = circleRadius);
	}
}

module bezier_polygon(points, handleOpacity=0) {
	steps = $fn <= 0 ? 30 : $fn;
	polygon(bezier_coordinates(points, steps));

	if (handleOpacity > 0) {
		for (c = points) {
			_bezier_draw_handle(c[0], c[1], handleOpacity);
			_bezier_draw_handle(c[3], c[2], handleOpacity);
		}
	}
}
