//
/**
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#include "Metal Shaders/Common.h"
#include <metal_stdlib>

using namespace metal;

struct VertexIn {
  packed_float3 position;
  packed_float3 normal;
  float2 uv;
};

struct VertexOut {
  float4 position [[position]];
  half3 worldPosition;
  half3 worldNormal;
  float2 uv;
  uint textureID [[flat]];
};

vertex VertexOut vertex_nature(constant VertexIn *in [[buffer(0)]],
                               uint vertexID [[vertex_id]],
                               constant int &vertexCount [[buffer(1)]],
                               constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                               constant NatureInstance *instances [[buffer(BufferIndexInstances)]],
                               uint instanceID [[instance_id]]  ) {
  NatureInstance instance = instances[instanceID];
  uint offset = instance.morphTargetID * vertexCount;
  VertexIn vertexIn = in[vertexID + offset];
  VertexOut out;
  float4 position = float4(vertexIn.position, 1);
  float3 normal = vertexIn.normal;
  out.position = uniforms.projectionMatrix * uniforms.viewMatrix
  * uniforms.modelMatrix * instance.modelMatrix * position;
  out.worldPosition = half3((uniforms.modelMatrix * position
                       * instance.modelMatrix).xyz);
  out.worldNormal = half3(uniforms.normalMatrix * instance.normalMatrix * normal);
  out.textureID = instance.textureID;
  out.uv = vertexIn.uv;
  return out;
}

constant half3 sunlight = half3(2, 4, -4);

fragment half4 fragment_nature(VertexOut in [[stage_in]],
                                texture2d_array<half> baseColorTexture [[texture(0)]],
                                constant FragmentUniforms &fragmentUniforms [[buffer(BufferIndexFragmentUniforms)]]
                                ){
  constexpr sampler s(filter::linear);
  half4 baseColor = baseColorTexture.sample(s, in.uv, in.textureID);
  half3 normal = normalize(in.worldNormal);
  half3 lightDirection = normalize(sunlight);
  half diffuseIntensity = saturate(dot(lightDirection, normal));
  half4 color = mix(baseColor * 0.5, baseColor * 1.5, diffuseIntensity);
  return color;
}

kernel void compute(uint pid [[ thread_position_in_grid ]])
{
  uint id = pid + 1;
  id *= 2;
}
