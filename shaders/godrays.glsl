#version 300 es
precision highp float;
uniform vec2 resolution;
uniform vec2 touch;
uniform float time;
float Bayer2(vec2 a) {
    a = floor(a);
    return fract(a.x / 2. + a.y * a.y * .75);
}
float rand(vec2 n) {
    return
        fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}
// https://www.shadertoy.com/view/7sfXDn
#define Bayer4(a)   (Bayer2 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer8(a)   (Bayer4 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer16(a)  (Bayer8 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer32(a)  (Bayer16(.5 *(a)) * .25 + Bayer2(a))
#define Bayer64(a)  (Bayer32(.5 *(a)) * .25 + Bayer2(a))
vec3 sunPosition() {
     float rot = 15.0;
    float sunAngle = rot;
     float sunX = 0.0;
    float sunY = sin(radians(sunAngle));
    float sunZ = cos(radians(sunAngle));
    return vec3(sunX, sunY, sunZ);
}
float hg(float low,const float v){
    float lv=v*v;
    return 0.25*(1.0 / 3.14159265)*
     (1.0-lv)*
     pow(1.0+lv-2.0*v*low,-1.5);
}
float calcu(vec3 a){
    vec3 b = a;
    if(a.y > 0.07)
        return rand(floor(4.0 * (b.xz / b.y) + time * 0.51));
}
vec3 beamcast(vec3 dir){
    vec3 q = dir;

    vec3 sp = sunPosition();
    vec3 diff = (q - (sp));
    float ld = dot(sp, dir);
    float alpha = hg(ld, 0.85);

    vec3 occlusion = vec3(0.0);

    float ditherFactor = Bayer64(gl_FragCoord.xy);
    float decay = 1.0;
    float sc = calcu((q-diff) + (diff * ditherFactor));
    occlusion += sc;
    vec3 lRay = 1.0 - exp(-(occlusion * alpha));
    return lRay;
}

out vec4 fc;
void main(void) {
 vec2 uv = gl_FragCoord.xy / resolution.xy;
 uv -= 0.5;
 uv.x *= resolution.x/resolution.y;
vec3 p = vec3(uv, 1);
p = normalize(p);
 fc.rgb = beamcast(p);
 fc.a = 1.0;
}
