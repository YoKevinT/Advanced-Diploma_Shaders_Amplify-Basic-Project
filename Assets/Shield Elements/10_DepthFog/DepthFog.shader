// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DepthFog"
{
	Properties
	{
		_FogIntensity("Fog Intensity", Range( 0 , 1)) = 0.5
		_FogColour("FogColour", Color) = (0,0,0,0)
		_Emission("Emission", Color) = (0,0,0,0)
		_FogTexture("FogTexture", 2D) = "white" {}
		_Fuzziness("Fuzziness", Range( 0 , 1)) = 0.21
		_Range("Range", Range( 0 , 1)) = 0.48
		_FogSpeed("Fog Speed", Vector) = (0,0,0,0)
		_FogSpeed2("Fog Speed 2", Vector) = (0,0,0,0)
		_FogDirection("Fog Direction", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform sampler2D _FogTexture;
		uniform float2 _FogSpeed;
		uniform float _Range;
		uniform float _Fuzziness;
		uniform float2 _FogSpeed2;
		uniform float _FogDirection;
		uniform float4 _FogColour;
		uniform float4 _Emission;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _FogIntensity;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 temp_cast_0 = (1.0).xxx;
			float2 panner29 = ( 1.0 * _Time.y * _FogSpeed + v.texcoord.xy);
			float3 temp_cast_2 = (1.0).xxx;
			float2 uv_TexCoord36 = v.texcoord.xy + float2( 0.5,0.5 );
			float cos50 = cos( 0.01 * _Time.y );
			float sin50 = sin( 0.01 * _Time.y );
			float2 rotator50 = mul( uv_TexCoord36 - float2( 0.5,0.5 ) , float2x2( cos50 , -sin50 , sin50 , cos50 )) + float2( 0.5,0.5 );
			float2 panner37 = ( 1.0 * _Time.y * _FogSpeed2 + rotator50);
			float clampResult47 = clamp( ( saturate( ( 1.0 - ( ( distance( temp_cast_0 , tex2Dlod( _FogTexture, float4( panner29, 0, 0.0) ).rgb ) - _Range ) / max( _Fuzziness , 1E-05 ) ) ) ) + saturate( ( 1.0 - ( ( distance( temp_cast_2 , tex2Dlod( _FogTexture, float4( panner37, 0, 0.0) ).rgb ) - _Range ) / max( _Fuzziness , 1E-05 ) ) ) ) ) , 0.0 , 1.0 );
			float FogStuff80 = clampResult47;
			float4 temp_cast_4 = (FogStuff80).xxxx;
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( temp_cast_4 * _FogDirection * float4( ase_vertexNormal , 0.0 ) ).xyz;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 temp_cast_0 = (1.0).xxx;
			float2 panner29 = ( 1.0 * _Time.y * _FogSpeed + i.uv_texcoord);
			float3 temp_cast_2 = (1.0).xxx;
			float2 uv_TexCoord36 = i.uv_texcoord + float2( 0.5,0.5 );
			float cos50 = cos( 0.01 * _Time.y );
			float sin50 = sin( 0.01 * _Time.y );
			float2 rotator50 = mul( uv_TexCoord36 - float2( 0.5,0.5 ) , float2x2( cos50 , -sin50 , sin50 , cos50 )) + float2( 0.5,0.5 );
			float2 panner37 = ( 1.0 * _Time.y * _FogSpeed2 + rotator50);
			float clampResult47 = clamp( ( saturate( ( 1.0 - ( ( distance( temp_cast_0 , tex2D( _FogTexture, panner29 ).rgb ) - _Range ) / max( _Fuzziness , 1E-05 ) ) ) ) + saturate( ( 1.0 - ( ( distance( temp_cast_2 , tex2D( _FogTexture, panner37 ).rgb ) - _Range ) / max( _Fuzziness , 1E-05 ) ) ) ) ) , 0.0 , 1.0 );
			float FogStuff80 = clampResult47;
			o.Albedo = ( _FogColour * FogStuff80 ).rgb;
			o.Emission = _Emission.rgb;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth3 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float clampResult23 = clamp( abs( ( abs( ( eyeDepth3 - ase_screenPos.w ) ) * (0.01 + (_FogIntensity - 0.0) * (1.0 - 0.01) / (1.0 - 0.0)) ) ) , 0.0 , 1.0 );
			o.Alpha = clampResult23;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
1957;197;1330;714;1304.143;-117.4477;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;82;-2100.618,-876.0106;Inherit;False;1819.939;941.1002;Comment;16;36;28;30;50;35;29;37;38;40;25;41;27;26;33;48;47;Fog Top!;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-2050.618,-264.9101;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0.5,0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;50;-1804.17,-257.8013;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.01;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;30;-1792.618,-701.0103;Inherit;False;Property;_FogSpeed;Fog Speed;6;0;Create;True;0;0;False;0;0,0;0.01,0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;35;-2015.618,-95.91034;Inherit;False;Property;_FogSpeed2;Fog Speed 2;7;0;Create;True;0;0;False;0;0,0;-0.02,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1824.618,-826.0106;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;37;-1591.618,-221.9101;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;29;-1559.817,-726.8103;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;85;-1507.218,85.40019;Inherit;False;1236.498;402.7735;Comment;10;6;10;23;24;5;8;4;3;22;2;Fog Edges;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;38;-1411.617,-219.9101;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;-1;None;e28dc97a9541e3642a48c0e3886688c5;True;0;False;white;Auto;False;Instance;25;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-1369.106,-442.3608;Inherit;False;Property;_Range;Range;5;0;Create;True;0;0;False;0;0.48;0.47;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-1383.817,-729.8103;Inherit;True;Property;_FogTexture;FogTexture;3;0;Create;True;0;0;False;0;-1;None;e28dc97a9541e3642a48c0e3886688c5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;41;-1366.869,-353.2016;Inherit;False;Property;_Fuzziness;Fuzziness;4;0;Create;True;0;0;False;0;0.21;0.55;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1241.817,-532.0101;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;2;-1404.129,137.297;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;26;-1020.524,-602.1257;Inherit;True;Color Mask;-1;;1;eec747d987850564c95bde0e5a6d1867;0;4;1;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.48;False;5;FLOAT;0.21;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;33;-1028.524,-257.145;Inherit;True;Color Mask;-1;;2;eec747d987850564c95bde0e5a6d1867;0;4;1;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.48;False;5;FLOAT;0.21;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;22;-1183.79,225.4983;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;3;-1180.94,135.4002;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-687.7935,-231.5882;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1258.588,397.3124;Inherit;False;Property;_FogIntensity;Fog Intensity;0;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-956.0403,143.1002;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;8;-817.0404,158.1002;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;10;-873.637,251.8866;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.01;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-455.6793,-129.8812;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-683.0403,176.1002;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-180.601,-131.6041;Inherit;False;FogStuff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;84;-817.0994,520.1937;Inherit;False;543.7;240.4066;Comment;3;79;78;81;Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;24;-548.803,173.1472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;-724.0846,570.1937;Inherit;False;80;FogStuff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-767.0994,645.6003;Inherit;False;Property;_FogDirection;Fog Direction;8;0;Create;True;0;0;False;0;0;0.26;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-198.4845,-336.5807;Inherit;False;Property;_FogColour;FogColour;1;0;Create;True;0;0;False;0;0,0,0,0;0.08490568,0.08490568,0.08490568,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;32;48.14747,-33.45306;Inherit;False;Property;_Emission;Emission;2;0;Create;True;0;0;False;0;0,0,0,0;0.09433961,0.09433961,0.09433961,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;23;-426.8033,170.1472;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;144.7505,-151.247;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;78;-482.3994,588.4003;Inherit;False;VertexOffset;-1;;12;58041d64e0e90714ebd2a20290d6b7ec;0;2;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;395,-73;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;DepthFog;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;50;0;36;0
WireConnection;37;0;50;0
WireConnection;37;2;35;0
WireConnection;29;0;28;0
WireConnection;29;2;30;0
WireConnection;38;1;37;0
WireConnection;25;1;29;0
WireConnection;26;1;25;0
WireConnection;26;3;27;0
WireConnection;26;4;40;0
WireConnection;26;5;41;0
WireConnection;33;1;38;0
WireConnection;33;3;27;0
WireConnection;33;4;40;0
WireConnection;33;5;41;0
WireConnection;3;0;2;0
WireConnection;48;0;26;0
WireConnection;48;1;33;0
WireConnection;4;0;3;0
WireConnection;4;1;22;4
WireConnection;8;0;4;0
WireConnection;10;0;6;0
WireConnection;47;0;48;0
WireConnection;5;0;8;0
WireConnection;5;1;10;0
WireConnection;80;0;47;0
WireConnection;24;0;5;0
WireConnection;23;0;24;0
WireConnection;31;0;9;0
WireConnection;31;1;80;0
WireConnection;78;1;81;0
WireConnection;78;2;79;0
WireConnection;0;0;31;0
WireConnection;0;2;32;0
WireConnection;0;9;23;0
WireConnection;0;11;78;0
ASEEND*/
//CHKSM=0304C946937E46AD5FC98A3512C7B2A861BAD820