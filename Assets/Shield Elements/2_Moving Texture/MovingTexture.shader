// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MovingTexture"
{
	Properties
	{
		_MovingTexture("Moving Texture", 2D) = "white" {}
		_ShieldPatternScale("ShieldPatternScale", Range( 0 , 5)) = 1
		_TimeScaleX("TimeScaleX", Range( -1 , 1)) = 0
		_TimeScaleY("TimeScaleY", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MovingTexture;
		uniform float _ShieldPatternScale;
		uniform float _TimeScaleX;
		uniform float _TimeScaleY;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_ShieldPatternScale).xx;
			float mulTime4 = _Time.y * _TimeScaleX;
			float mulTime8 = _Time.y * _TimeScaleY;
			float4 appendResult6 = (float4(mulTime4 , mulTime8 , 0.0 , 0.0));
			float2 uv_TexCoord2 = i.uv_texcoord * temp_cast_0 + appendResult6.xy;
			o.Albedo = tex2D( _MovingTexture, uv_TexCoord2 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
323;73;1278;575;2401.881;297.0115;2.152253;True;False
Node;AmplifyShaderEditor.RangedFloatNode;5;-1649.355,181.632;Inherit;False;Property;_TimeScaleX;TimeScaleX;2;0;Create;True;0;0;False;0;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1651.793,285.6122;Inherit;False;Property;_TimeScaleY;TimeScaleY;3;0;Create;True;0;0;False;0;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;8;-1374.266,289.5137;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;4;-1371.828,185.5335;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1222.864,40.76116;Inherit;False;Property;_ShieldPatternScale;ShieldPatternScale;1;0;Create;True;0;0;False;0;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;-1089.266,155.3805;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-877.1643,26.05877;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-556.6547,-2.917976;Inherit;True;Property;_MovingTexture;Moving Texture;0;0;Create;True;0;0;False;0;-1;3fd73406ebbb1dc489f4f563d47e0bc2;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MovingTexture;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;7;0
WireConnection;4;0;5;0
WireConnection;6;0;4;0
WireConnection;6;1;8;0
WireConnection;2;0;3;0
WireConnection;2;1;6;0
WireConnection;1;1;2;0
WireConnection;0;0;1;0
ASEEND*/
//CHKSM=EF1DD526FBDBC11D64484D7837C6FABA1044C491