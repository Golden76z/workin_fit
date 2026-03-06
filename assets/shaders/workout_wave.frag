// shader adapted from:
// https://www.shadertoy.com/view/wdyczG
// original by https://www.shadertoy.com/user/hahnzhu

#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 iResolution;
uniform float iTime;

uniform vec3 colorPrimary;
uniform vec3 colorSecondary;
uniform vec3 colorAccent1;
uniform vec3 colorAccent2;

out vec4 fragColor;

#define S(a,b,t) smoothstep(a,b,t)

mat2 Rot(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, -s, s, c);
}

vec2 hash(vec2 p) {
  p = vec2(
    dot(p, vec2(2127.1, 81.17)),
    dot(p, vec2(1269.5, 283.37))
  );
  return fract(sin(p) * 43758.5453);
}

float noise(in vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);

  vec2 u = f * f * (3.0 - 2.0 * f);

  float n = mix(
    mix(
      dot(-1.0 + 2.0 * hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
      dot(-1.0 + 2.0 * hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)),
      u.x
    ),
    mix(
      dot(-1.0 + 2.0 * hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
      dot(-1.0 + 2.0 * hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)),
      u.x
    ),
    u.y
  );
  return 0.5 + 0.5 * n;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / iResolution.xy;
  float ratio = iResolution.x / iResolution.y;

  vec2 tuv = uv;
  tuv -= 0.5;

  float degree = noise(vec2(iTime * 0.1, tuv.x * tuv.y));

  tuv.y *= 1.0 / ratio;
  tuv *= Rot(radians((degree - 0.5) * 720.0 + 180.0));
  tuv.y *= ratio;

  float frequency = 5.0;
  float amplitude = 30.0;
  float speed = iTime * 2.0;
  tuv.x += sin(tuv.y * frequency + speed) / amplitude;
  tuv.y += sin(tuv.x * frequency * 1.5 + speed) / (amplitude * 0.5);

  vec3 layer1 = mix(
    colorPrimary,
    colorSecondary,
    S(-0.3, 0.2, (tuv * Rot(radians(-5.0))).x)
  );
  vec3 layer2 = mix(
    colorAccent1,
    colorAccent2,
    S(-0.3, 0.2, (tuv * Rot(radians(-5.0))).x)
  );

  vec3 finalComp = mix(layer1, layer2, S(0.5, -0.3, tuv.y));
  fragColor = vec4(finalComp, 1.0);
}
