// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FullShield"
{
	Properties
	{
		_AnimationSpeed("Animation Speed", Range( -10 , 10)) = 0
		_RimPower("Rim Power", Range( 0 , 10)) = 7
		_ShieldPatterColor("Shield Patter Color", Color) = (0.7735849,0.7577737,0,0)
		_ShieldPatternPower("Shield Pattern Power", Range( 0 , 100)) = 5
		_ShieldPatternSize("Shield Pattern Size", Range( 0 , 20)) = 5
		_ShieldPatternWaves("Shield Pattern Waves", 2D) = "white" {}
		_ShieldDistorion("Shield Distorion", Range( 0 , 0.05)) = 0.01
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_ShieldPattern("Shield Pattern", 2D) = "white" {}
		_ShieldColor("Shield Color", Color) = (0.7075472,0,0.67447,0)
		_InstersectColor("Instersect Color", Color) = (0.9528302,0.4814794,0,0)
		_HitSize("Hit Size", Float) = 0.02
		_HitColor("Hit Color", Color) = (0,0,0,0)
		_HitPosition("Hit Position", Vector) = (0,0,0,0)
		_HitTime("Hit Time", Float) = 0
		_IntersectIntensity("Intersect Intensity", Range( 0 , 0.2)) = 0.2
		_Opacity("Opacity", Range( 0 , 1)) = 0.5
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
		};

		uniform float _AnimationSpeed;
		uniform float _ShieldDistorion;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float4 _ShieldColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _InstersectColor;
		uniform float _RimPower;
		uniform float _ShieldPatternPower;
		uniform sampler2D _ShieldPatternWaves;
		uniform float3 _HitPosition;
		uniform float _HitSize;
		uniform float4 _ShieldPatterColor;
		uniform float4 _HitColor;
		uniform float _HitTime;
		uniform sampler2D _ShieldPattern;
		uniform float _ShieldPatternSize;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _IntersectIntensity;
		uniform float _Opacity;
		uniform float _EdgeLength;


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


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_vertexNormal = v.normal.xyz;
			float ShieldSpeed26 = ( _Time.y * _AnimationSpeed );
			float simplePerlin2D44 = snoise( ( ase_vertexNormal + ( ShieldSpeed26 / 5.0 ) ).xy );
			simplePerlin2D44 = simplePerlin2D44*0.5 + 0.5;
			float VertexOffset49 = (( _ShieldDistorion * 0.0 ) + (simplePerlin2D44 - 0.0) * (_ShieldDistorion - ( _ShieldDistorion * 0.0 )) / (1.0 - 0.0));
			float3 temp_cast_1 = (VertexOffset49).xxx;
			v.vertex.xyz += temp_cast_1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 Normal14 = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			o.Normal = Normal14;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo16 = ( _ShieldColor * tex2D( _Albedo, uv_Albedo ) );
			o.Albedo = Albedo16.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV20 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode20 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV20, (0.0 + (_RimPower - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ) );
			float ShieldRim5 = fresnelNode20;
			float ShieldPatternPower55 = _ShieldPatternPower;
			float ShieldSpeed26 = ( _Time.y * _AnimationSpeed );
			float4 appendResult7 = (float4(1 , ( 1.0 - ( ShieldSpeed26 / 5.0 ) ) , 0.0 , 0.0));
			float2 uv_TexCoord19 = i.uv_texcoord * float2( 1,1 ) + appendResult7.xy;
			float4 Waves15 = tex2D( _ShieldPatternWaves, uv_TexCoord19 );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float HitDistance78 = distance( ase_vertex3Pos , _HitPosition );
			float HitSize71 = _HitSize;
			float4 ShieldPatternColor53 = _ShieldPatterColor;
			float4 HitColor74 = _HitColor;
			float4 lerpResult85 = lerp( ShieldPatternColor53 , ( HitColor74 * ( HitSize71 / HitDistance78 ) ) , (0.0 + (_HitTime - 0.0) * (1.0 - 0.0) / (100.0 - 0.0)));
			float4 Hit94 = (( HitDistance78 > 0.0 ) ? (( HitSize71 < HitDistance78 ) ? lerpResult85 :  ShieldPatternColor53 ) :  ShieldPatternColor53 );
			float2 appendResult59 = (float2(_ShieldPatternSize , _ShieldPatternSize));
			float2 appendResult60 = (float2(1 , ShieldSpeed26));
			float2 uv_TexCoord61 = i.uv_texcoord * appendResult59 + appendResult60;
			float4 ShieldPattern63 = tex2D( _ShieldPattern, uv_TexCoord61 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth109 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth109 = abs( ( screenDepth109 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _IntersectIntensity ) );
			float clampResult110 = clamp( distanceDepth109 , 0.0 , 1.0 );
			float4 lerpResult107 = lerp( _InstersectColor , ( ( ( ShieldRim5 + ShieldPatternPower55 ) * Waves15 ) * ( Hit94 * ShieldPattern63 ) ) , clampResult110);
			float4 Emission113 = ( lerpResult107 * ShieldPatternColor53 );
			o.Emission = Emission113.rgb;
			o.Alpha = _Opacity;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
374;73;1227;575;-3.957214;828.5281;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;95;-2142.128,2706.246;Inherit;False;2263.668;958.1829;;23;73;75;77;76;78;74;80;81;82;83;85;79;87;88;89;90;86;91;92;93;94;70;71;Impact Effect;0.03529412,0.5843138,0.4941176,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;4;-2113.344,-1406.497;Inherit;False;627;286;Controlls Speed of ShieldSpeed;4;27;26;25;24;Animation Speed;0.03529412,0.5843138,0.4941176,1;0;0
Node;AmplifyShaderEditor.Vector3Node;76;-2058.507,3476.429;Inherit;False;Property;_HitPosition;Hit Position;14;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;75;-2081.896,3289.312;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;27;-2078.344,-1343.497;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2095.345,-1216.497;Inherit;False;Property;_AnimationSpeed;Animation Speed;0;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;77;-1814.378,3384.332;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2069.095,2827.846;Inherit;False;Property;_HitSize;Hit Size;12;0;Create;True;0;0;False;0;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1839.344,-1343.497;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-1684.344,-1349.497;Inherit;False;ShieldSpeed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;-1600.948,3378.485;Inherit;False;HitDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;73;-2080.428,3056.878;Inherit;False;Property;_HitColor;Hit Color;13;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;1;-2121.938,406.235;Inherit;False;1775.052;545.3714;Waves on our Shield;10;19;18;15;12;11;10;9;8;7;6;Shield Waves Effect;0.03529412,0.5843138,0.4941176,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;64;-2120.214,1865.884;Inherit;False;1469.988;674.4272;;12;58;59;60;61;62;63;57;56;53;52;54;55;Shield Main Pattern;0.03529412,0.5843138,0.4941176,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-1845.998,2917.395;Inherit;False;HitSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;52;-2015.38,1915.884;Inherit;False;Property;_ShieldPatterColor;Shield Patter Color;2;0;Create;True;0;0;False;0;0.7735849,0.7577737,0,0;0.7735849,0.7577737,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;10;-2071.939,683.235;Inherit;False;26;ShieldSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-1521.922,3085.596;Inherit;False;71;HitSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-1834.843,3059.802;Inherit;False;HitColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2055.474,835.606;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-1523.684,3203.64;Inherit;False;78;HitDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;81;-1285.835,3149.022;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-1312.261,3015.122;Inherit;False;74;HitColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-1335.167,3332.255;Float;False;Property;_HitTime;Hit Time;15;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-1728.932,1956.944;Inherit;False;ShieldPatternColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-1800.916,712.9719;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;3;-2109.694,-981.8721;Inherit;False;886.3451;383.902;Fresnel Flow on Rim;5;23;22;21;20;5;Shield Rim;0.03586687,0.5849056,0.4955272,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2070.214,2156.314;Inherit;False;Property;_ShieldPatternSize;Shield Pattern Size;4;0;Create;True;0;0;False;0;5;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-1095.555,3134.927;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;8;-1650.939,594.235;Inherit;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;False;0;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;22;-2059.694,-931.8721;Inherit;False;Property;_RimPower;Rim Power;1;0;Create;True;0;0;False;0;7;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-1090.273,2924.992;Inherit;False;53;ShieldPatternColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;88;-1115.952,3351.432;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;100;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2037.712,2422.82;Inherit;False;26;ShieldSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;57;-2021.965,2263.808;Inherit;False;Constant;_UV;UV;11;0;Create;True;0;0;False;0;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;9;-1635.939,757.235;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;85;-830.1899,3184.189;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;6;-1389.939,456.235;Inherit;False;Constant;_Vector1;Vector 1;5;0;Create;True;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TFHCRemapNode;21;-2039.349,-804.97;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;60;-1681.226,2402.311;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-811.0551,2758.646;Inherit;False;71;HitSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-1383.939,655.235;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-804.686,2962.617;Inherit;False;78;HitDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-1680.512,2248.52;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-1157.939,521.235;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;93;-573.0603,2757.546;Inherit;False;78;HitDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-1511.226,2309.311;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;20;-1761.348,-806.97;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareLower;89;-569.003,3013.704;Inherit;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1420.811,1972.069;Inherit;False;Property;_ShieldPatternPower;Shield Pattern Power;3;0;Create;True;0;0;False;0;5;5;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-1447.349,-812.97;Inherit;False;ShieldRim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareGreater;90;-338.8178,2852.931;Inherit;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;62;-1237.226,2310.311;Inherit;True;Property;_ShieldPattern;Shield Pattern;9;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;114;-2118.991,3831.719;Inherit;False;1845.826;879.9644;;17;97;98;96;101;102;100;104;106;107;108;109;110;111;103;99;112;113;Emission;0.03529412,0.5843138,0.4941176,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-1082.811,1973.069;Inherit;False;ShieldPatternPower;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;-917.8881,477.3729;Inherit;True;Property;_ShieldPatternWaves;Shield Pattern Waves;5;0;Create;True;0;0;False;0;-1;fc6723d1b4e1a2546877f9b7685469c6;fc6723d1b4e1a2546877f9b7685469c6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-84.52028,2848.51;Inherit;False;Hit;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;50;-2114.495,1120.125;Inherit;False;1710.689;553.608;;10;39;40;41;43;42;44;46;45;48;49;Shield Distoriton;0.03529412,0.5843138,0.4941176,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-2041.689,3881.719;Inherit;False;5;ShieldRim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-874.2263,2311.311;Inherit;False;ShieldPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-2068.991,4004.577;Inherit;False;55;ShieldPatternPower;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-570.8878,521.3729;Inherit;False;Waves;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1880.461,4595.683;Inherit;False;Property;_IntersectIntensity;Intersect Intensity;16;0;Create;True;0;0;False;0;0.2;0;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-1882.855,4441.949;Inherit;False;63;ShieldPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-1724.986,3944.513;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-1870.794,4309.165;Inherit;False;94;Hit;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-2064.495,1523.342;Inherit;False;Constant;_Float1;Float 1;16;0;Create;True;0;0;False;0;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-2028.593,1388.284;Inherit;False;26;ShieldSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-1883.338,4173.849;Inherit;False;15;Waves;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1496.113,4372.905;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;39;-1882.632,1170.125;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;42;-1802.927,1507.956;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;109;-1528.461,4551.683;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1507.113,4028.906;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;2;-2117.134,-436.5586;Inherit;False;785.3441;688;Albedo and Normal;6;29;28;17;16;14;13;Shield Texture;0.03529412,0.5843138,0.4941176,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;110;-1261.461,4467.683;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;106;-1264.019,3918.378;Inherit;False;Property;_InstersectColor;Instersect Color;11;0;Create;True;0;0;False;0;0.9528302,0.4814794,0,0;0.9528302,0.4814794,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-1602.904,1336.996;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1573.902,1557.733;Inherit;False;Property;_ShieldDistorion;Shield Distorion;6;0;Create;True;0;0;False;0;0.01;0;0;0.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1277.113,4173.905;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;44;-1403.874,1172.851;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-985.1972,4219.183;Inherit;False;53;ShieldPatternColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;17;-2067.134,-188.5585;Inherit;True;Property;_Albedo;Albedo;7;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;28;-2038.134,-386.5585;Inherit;False;Property;_ShieldColor;Shield Color;10;0;Create;True;0;0;False;0;0.7075472,0,0.67447,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;107;-968.3685,3998.633;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1293.231,1425.399;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;48;-989.3533,1299.022;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-2060.734,21.44152;Inherit;True;Property;_Normal;Normal;8;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-754.5012,3996.054;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1735.19,-256.9965;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-633.3553,1295.316;Inherit;False;VertexOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-500.2293,3992.107;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1555.79,-260.8965;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-1557.39,21.20355;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;454.5819,-397.2171;Inherit;False;49;VertexOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;455.8328,-819.0473;Inherit;False;16;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;463.2043,-716.6282;Inherit;False;14;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;119;408.5129,-508.8848;Inherit;False;Property;_Opacity;Opacity;17;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;461.3413,-610.9283;Inherit;False;113;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1723.348,-930.9701;Inherit;False;ShieldRimPower;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;760.7761,-730.1408;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;FullShield;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;23;-1;-1;18;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;77;0;75;0
WireConnection;77;1;76;0
WireConnection;24;0;27;0
WireConnection;24;1;25;0
WireConnection;26;0;24;0
WireConnection;78;0;77;0
WireConnection;71;0;70;0
WireConnection;74;0;73;0
WireConnection;81;0;79;0
WireConnection;81;1;80;0
WireConnection;53;0;52;0
WireConnection;11;0;10;0
WireConnection;11;1;12;0
WireConnection;82;0;83;0
WireConnection;82;1;81;0
WireConnection;88;0;87;0
WireConnection;9;0;11;0
WireConnection;85;0;86;0
WireConnection;85;1;82;0
WireConnection;85;2;88;0
WireConnection;21;0;22;0
WireConnection;60;0;57;1
WireConnection;60;1;58;0
WireConnection;7;0;8;1
WireConnection;7;1;9;0
WireConnection;59;0;56;0
WireConnection;59;1;56;0
WireConnection;19;0;6;0
WireConnection;19;1;7;0
WireConnection;61;0;59;0
WireConnection;61;1;60;0
WireConnection;20;3;21;0
WireConnection;89;0;92;0
WireConnection;89;1;91;0
WireConnection;89;2;85;0
WireConnection;89;3;86;0
WireConnection;5;0;20;0
WireConnection;90;0;93;0
WireConnection;90;2;89;0
WireConnection;90;3;86;0
WireConnection;62;1;61;0
WireConnection;55;0;54;0
WireConnection;18;1;19;0
WireConnection;94;0;90;0
WireConnection;63;0;62;0
WireConnection;15;0;18;0
WireConnection;101;0;96;0
WireConnection;101;1;97;0
WireConnection;103;0;99;0
WireConnection;103;1;100;0
WireConnection;42;0;40;0
WireConnection;42;1;41;0
WireConnection;109;0;108;0
WireConnection;102;0;101;0
WireConnection;102;1;98;0
WireConnection;110;0;109;0
WireConnection;43;0;39;0
WireConnection;43;1;42;0
WireConnection;104;0;102;0
WireConnection;104;1;103;0
WireConnection;44;0;43;0
WireConnection;107;0;106;0
WireConnection;107;1;104;0
WireConnection;107;2;110;0
WireConnection;46;0;45;0
WireConnection;48;0;44;0
WireConnection;48;3;46;0
WireConnection;48;4;45;0
WireConnection;111;0;107;0
WireConnection;111;1;112;0
WireConnection;29;0;28;0
WireConnection;29;1;17;0
WireConnection;49;0;48;0
WireConnection;113;0;111;0
WireConnection;16;0;29;0
WireConnection;14;0;13;0
WireConnection;23;0;22;0
WireConnection;0;0;116;0
WireConnection;0;1;117;0
WireConnection;0;2;118;0
WireConnection;0;9;119;0
WireConnection;0;11;120;0
ASEEND*/
//CHKSM=812F72DA16A73C2AB473AC8C4CF824262F92528A