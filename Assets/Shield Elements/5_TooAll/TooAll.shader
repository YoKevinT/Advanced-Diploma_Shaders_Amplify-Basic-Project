// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "All_1-5"
{
	Properties
	{
		_Impact("Impact", Color) = (1,0,0,0)
		_FresnelColor("Fresnel Color", Color) = (1,0.733945,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Base("Base", Color) = (0,0,0,0)
		_AnimationScale("Animation Scale", Range( 0 , 1)) = 0
		_HitPosition("HitPosition", Vector) = (0,0,0,0)
		_MovingTexture("Moving Texture", 2D) = "white" {}
		_HitSize("HitSize", Float) = 0.5
		_AnimationSpeed("Animation Speed", Range( 0 , 20)) = 1
		_Noise("Noise", 2D) = "white" {}
		_RimPower("Rim Power", Range( 0 , 10)) = 0.5
		_ShieldPatternScale("ShieldPatternScale", Range( 0 , 5)) = 1
		_DissolveAmount("DissolveAmount", Range( 0 , 1)) = 0
		_TimeScaleX("TimeScaleX", Range( -1 , 1)) = 0
		_TimeScaleY("TimeScaleY", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float _AnimationSpeed;
		uniform float _AnimationScale;
		uniform sampler2D _MovingTexture;
		uniform float _ShieldPatternScale;
		uniform float _TimeScaleX;
		uniform float _TimeScaleY;
		uniform float4 _FresnelColor;
		uniform float3 _HitPosition;
		uniform float _HitSize;
		uniform float4 _Impact;
		uniform float4 _Base;
		uniform float _RimPower;
		uniform float _DissolveAmount;
		uniform sampler2D _Noise;
		uniform float4 _Noise_ST;
		uniform float _Cutoff = 0.5;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float simplePerlin2D43 = snoise( ( ase_vertexNormal + ( _Time.y * _AnimationSpeed ) ).xy );
			simplePerlin2D43 = simplePerlin2D43*0.5 + 0.5;
			float Deform_LocalVertexOffset46 = (( _AnimationScale * 0.0 ) + (simplePerlin2D43 - 0.0) * (_AnimationScale - ( _AnimationScale * 0.0 )) / (1.0 - 0.0));
			float3 temp_cast_1 = (Deform_LocalVertexOffset46).xxx;
			v.vertex.xyz += temp_cast_1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_ShieldPatternScale).xx;
			float mulTime14 = _Time.y * _TimeScaleX;
			float mulTime13 = _Time.y * _TimeScaleY;
			float4 appendResult16 = (float4(mulTime14 , mulTime13 , 0.0 , 0.0));
			float2 uv_TexCoord17 = i.uv_texcoord * temp_cast_0 + appendResult16.xy;
			float4 MovingTexture_Albedo19 = tex2D( _MovingTexture, uv_TexCoord17 );
			float4 Fresnel_Albedo29 = _FresnelColor;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 Impact_Albedo58 = (( distance( ase_vertex3Pos , _HitPosition ) < _HitSize ) ? _Impact :  _Base );
			o.Albedo = ( MovingTexture_Albedo19 + Fresnel_Albedo29 + Impact_Albedo58 ).rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV24 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode24 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV24, (10.0 + (_RimPower - 0.0) * (0.0 - 10.0) / (10.0 - 0.0)) ) );
			float4 Fresnel_Emission30 = ( _FresnelColor * fresnelNode24 );
			o.Emission = Fresnel_Emission30.rgb;
			o.Alpha = 1;
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float4 Dissolve_OpacityMask8 = ( (-0.6 + (( 1.0 - _DissolveAmount ) - 0.0) * (0.6 - -0.6) / (1.0 - 0.0)) + tex2D( _Noise, uv_Noise ) );
			clip( Dissolve_OpacityMask8.r - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
374;73;1227;575;1516.651;416.0189;2.155279;True;False
Node;AmplifyShaderEditor.CommentaryNode;20;-3212.477,521.3287;Inherit;False;1465.138;454.5302;;9;11;12;13;14;15;16;17;18;19;Moving Texture;1,0,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-3160.039,755.8787;Inherit;False;Property;_TimeScaleX;TimeScaleX;14;0;Create;True;0;0;False;0;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-3162.477,859.8589;Inherit;False;Property;_TimeScaleY;TimeScaleY;15;0;Create;True;0;0;False;0;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;47;-3220.991,2071.93;Inherit;False;1563.417;701.5997;;9;37;38;39;40;42;43;44;45;46;Deform;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;32;-3213.928,1153.983;Inherit;False;1589.218;719.8979;;11;22;23;24;25;26;27;28;30;31;29;41;Fresnel;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;10;-3231.021,-282.2833;Inherit;False;1286.326;633.0589;;6;8;5;3;2;1;4;Dissolve;1,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;13;-2884.95,863.7604;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;14;-2882.512,759.7802;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;59;-3209.982,2981.847;Inherit;False;1048.04;908.7612;;8;50;52;56;58;51;53;54;55;Impact;1,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;37;-3115.09,2359.829;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-3170.991,2612.029;Inherit;False;Property;_AnimationSpeed;Animation Speed;9;0;Create;True;0;0;False;0;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;51;-3155.253,3198.387;Inherit;False;Property;_HitPosition;HitPosition;5;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;50;-3159.982,3031.847;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-2733.548,615.0077;Inherit;False;Property;_ShieldPatternScale;ShieldPatternScale;12;0;Create;True;0;0;False;0;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;39;-3031.891,2123.23;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-2845.99,2350.729;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-3131.021,-182.2833;Inherit;False;Property;_DissolveAmount;DissolveAmount;13;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-2599.95,729.6272;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-3163.928,1579.029;Inherit;False;Property;_RimPower;Rim Power;11;0;Create;True;0;0;False;0;0.5;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;54;-3158.914,3494.19;Inherit;False;Property;_Impact;Impact;0;0;Create;True;0;0;False;0;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;2;-2836.492,-174.3878;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;22;-2783.671,1578.246;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;10;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2821.291,2657.529;Inherit;False;Property;_AnimationScale;Animation Scale;4;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;55;-3156.615,3678.609;Inherit;False;Property;_Base;Base;3;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-2387.849,600.3054;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-2722.453,1756.219;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-3155.346,3377.784;Inherit;False;Property;_HitSize;HitSize;7;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;52;-2873.062,3159.848;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;23;-2313.447,1203.983;Inherit;False;Property;_FresnelColor;Fresnel Color;1;0;Create;True;0;0;False;0;1,0.733945,0,0;0.8679245,0.6394767,0.01228193,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-2496.291,2484.628;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;3;-2629.792,-178.2879;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.6;False;4;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;24;-2441.761,1488.418;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;-2067.339,571.3287;Inherit;True;Property;_MovingTexture;Moving Texture;6;0;Create;True;0;0;False;0;-1;3fd73406ebbb1dc489f4f563d47e0bc2;3fd73406ebbb1dc489f4f563d47e0bc2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;43;-2381.891,2121.93;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareLower;56;-2692.615,3361.266;Inherit;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-2790.76,120.7756;Inherit;True;Property;_Noise;Noise;10;0;Create;True;0;0;False;0;-1;e4f18e9f1338cbe4c862d52811feff60;e4f18e9f1338cbe4c862d52811feff60;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-2089.218,1336.264;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-2385.942,3355.779;Inherit;False;Impact_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-1851.512,1225.314;Inherit;False;Fresnel_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-2024.792,844.2554;Inherit;False;MovingTexture_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-2342.592,-28.7879;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;36;-595.0234,-34.23734;Inherit;False;283;367.8321;;3;33;34;35;Fresnel;0.4947529,0,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;45;-2134.89,2457.328;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-1848.71,1351.389;Inherit;False;Fresnel_Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-545.0234,15.76266;Inherit;False;29;Fresnel_Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-1899.573,2451.97;Inherit;False;Deform_LocalVertexOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-559.6258,-156.1931;Inherit;False;19;MovingTexture_Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-2175.035,-23.44755;Inherit;False;Dissolve_OpacityMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-529.6589,504.0481;Inherit;False;58;Impact_Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-540.16,217.5947;Inherit;False;31;Fresnel_Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2454.392,1757.881;Inherit;False;Property;_Intensity;Intensity;8;0;Create;True;0;0;False;0;1.954364;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-573.1841,391.124;Inherit;False;46;Deform_LocalVertexOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-545.0234,117.8946;Inherit;False;30;Fresnel_Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-140.4682,-276.9884;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-558.1423,-273.9647;Inherit;False;8;Dissolve_OpacityMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1852.031,1592.332;Inherit;False;Fresnel_Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-2087.561,1574.931;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;169.9737,-163.9875;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;All_1-5;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;12;0
WireConnection;14;0;11;0
WireConnection;40;0;37;0
WireConnection;40;1;38;0
WireConnection;16;0;14;0
WireConnection;16;1;13;0
WireConnection;2;0;1;0
WireConnection;22;0;28;0
WireConnection;17;0;15;0
WireConnection;17;1;16;0
WireConnection;41;0;39;0
WireConnection;41;1;40;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;44;0;42;0
WireConnection;3;0;2;0
WireConnection;24;3;22;0
WireConnection;18;1;17;0
WireConnection;43;0;41;0
WireConnection;56;0;52;0
WireConnection;56;1;53;0
WireConnection;56;2;54;0
WireConnection;56;3;55;0
WireConnection;27;0;23;0
WireConnection;27;1;24;0
WireConnection;58;0;56;0
WireConnection;29;0;23;0
WireConnection;19;0;18;0
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;45;0;43;0
WireConnection;45;3;44;0
WireConnection;45;4;42;0
WireConnection;30;0;27;0
WireConnection;46;0;45;0
WireConnection;8;0;5;0
WireConnection;61;0;21;0
WireConnection;61;1;33;0
WireConnection;61;2;60;0
WireConnection;31;0;26;0
WireConnection;26;0;24;0
WireConnection;26;1;25;0
WireConnection;0;0;61;0
WireConnection;0;2;34;0
WireConnection;0;10;9;0
WireConnection;0;11;48;0
ASEEND*/
//CHKSM=880283E97975B0DAEB42708906294E3AD1708454