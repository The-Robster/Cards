//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time_milli;
uniform bool u_mix_with_sprite;
uniform float u_alpha_mix;

float periodMilliseconds = 6000.0;

uniform float u_featherProportion;

uniform bool u_ignoreGray;

float grayCutoff = .1;

float rand(vec2 n)
{
	return fract( sin( dot( n, vec2(12.9898, 4.1414) ) ) * 43758.5453 );
}


float noise(vec2 n)
{
	const vec2 d = vec2( 0.0, 1.0 );
	vec2 b = floor( n ), f = smoothstep( vec2(0.0), vec2(1.0), fract(n) );
	return mix( mix( rand(b), rand(b + d.yx), f.x ), mix( rand(b + d.xy), rand(b + d.yy), f.x ), f.y );
}

const mat2 rot = mat2( 0.8, -0.6, 0.6, 0.8 );

float fbm( vec2 p )
{
    float f = 0.0;
    f += 0.5000 * noise( p ); p = rot * p * 2.02;
    f += 0.2500 * noise( p ); p = rot * p * 2.03;
    f += 0.1250 * noise( p ); p = rot * p * 2.01;
    f += 0.0625 * noise( p );

    return f / 0.9375;
}

float marble(vec2 coord) {
	vec2 q = vec2 ( fbm(coord + vec2(0.0, 0.0)), fbm(coord + vec2(5.2,1.3)));
	return fbm (coord + 4.0*q);
}

float marbleTwice(vec2 coord) {
	vec2 q = vec2 ( fbm(coord + vec2(0.0, 0.0)),
					fbm(coord + vec2(5.2,1.3)));
	
	vec2 r = vec2 ( fbm(coord + 4.0 * q + vec2(1.7, 9.2)), 
					fbm(coord + 4.0 * q + vec2(8.3, 2.8)));
	
	
	return fbm (coord + 4.0*r);
}

float marbleTwiceTimeAdjusted(vec2 coord) {
	float wider = marbleTwice(coord * .01);
	float narrower = marbleTwice(coord * .02);
	
	float mix_amount = .2 + .6*sin(u_time_milli / (periodMilliseconds / (2.0*3.14)));
	
	float mixed = (wider * mix_amount) + (narrower * (1.0-mix_amount));
	
	return mixed;
	
}

float adjustColor(float color) {
	return ((color * 0.7) - .2);
}

vec4 voidColorAtCoord(vec2 coord) {
	float result = marbleTwiceTimeAdjusted(coord);
	
	float alpha = 1.0;
	//if(u_do_alpha_blending) {
	//	alpha = .2 + (1.0 - result);
	//}
	
	alpha = result + u_alpha_mix;//* result + u_alpha_mix;
	
	return vec4(adjustColor(result), 0.0, adjustColor(result), alpha);
}

vec4 featherEdges(vec4 inColor) {
	//sprite has own texture sheet so  no need for uvs
	float distFromEdgeX = min(v_vTexcoord.x, abs(1.0 - v_vTexcoord.x));
	float distFromEdgeY = min(v_vTexcoord.y, abs(1.0 - v_vTexcoord.y));
	float distFromEdge = min(distFromEdgeX, distFromEdgeY);
	
	//TODO: probs more efficient way to do this?
	if(distFromEdge > u_featherProportion) {
		return inColor;
	}
	
	float normalizedAlpha = distFromEdge / u_featherProportion;
	
	//normalizedAlpha = normalizedAlpha *  inColor.x;
	
	return vec4 (inColor.xyz, min(inColor.a, 1.0) * normalizedAlpha);
}

bool checkIsGray(vec4 inColor) {
	bool greenRedDiff = abs(inColor.r - inColor.g) > grayCutoff;
	bool greenBlueDiff = abs(inColor.b - inColor.g) > grayCutoff;
	bool blueRedDiff = abs(inColor.r - inColor.b) > grayCutoff;
	
	return !(greenRedDiff || greenBlueDiff || blueRedDiff);
}

void main()
{
	vec4 originalColor =  texture2D( gm_BaseTexture, v_vTexcoord);
	/*if(u_for_piece) {
		originalColor = removeAllRed( originalColor );
	}*/
	if(u_ignoreGray && checkIsGray(originalColor)) {
		gl_FragColor = v_vColour * originalColor;
		return;
	}
	
	//This is the sauce. gl_FragCoord gives us coordinates relative to the window
	vec4 voidColor = voidColorAtCoord(gl_FragCoord.xy);
	
	voidColor = featherEdges(voidColor);
	
	if(u_mix_with_sprite) {
		voidColor = mix(originalColor, voidColor, min(1.0,max(0.0,voidColor.a)));
		voidColor = vec4(voidColor.x, voidColor.y, voidColor.z, originalColor.a);
	}
	
	gl_FragColor = v_vColour * vec4(voidColor.x, voidColor.y, voidColor.z, min(voidColor.a, originalColor.a));
}
