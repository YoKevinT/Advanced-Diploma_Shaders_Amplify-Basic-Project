// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CameraExample"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_PixelY("Pixel Y", Range( 0 , 5000)) = 200
		_PixelX("Pixel X", Range( 0 , 5000)) = 200
		_Color0("Color 0", Color) = (0,0,0,0)

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _PixelX;
			uniform float _PixelY;
			uniform float4 _Color0;


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv05 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float pixelWidth4 =  1.0f / _PixelX;
				float pixelHeight4 = 1.0f / _PixelY;
				half2 pixelateduv4 = half2((int)(uv05.x / pixelWidth4) * pixelWidth4, (int)(uv05.y / pixelHeight4) * pixelHeight4);
				

				finalColor = ( tex2D( _MainTex, pixelateduv4 ) + _Color0 );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17800
402;73;964;575;1592.282;352.2328;1.68169;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1147.69,-113.1521;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;-1171.612,37.43521;Inherit;False;Property;_PixelX;Pixel X;1;0;Create;True;0;0;False;0;200;200;0;5000;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1166.095,141.173;Inherit;False;Property;_PixelY;Pixel Y;0;0;Create;True;0;0;False;0;200;200;0;5000;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCPixelate;4;-738.8361,-1.107723;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;14;-695.0915,-170.6509;Inherit;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-447.2757,-54.53943;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;15;-426.7947,201.0026;Inherit;False;Property;_Color0;Color 0;2;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-45.95952,111.8731;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;191.7127,184.9859;Float;False;True;-1;2;ASEMaterialInspector;0;2;CameraExample;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;4;0;5;0
WireConnection;4;1;2;0
WireConnection;4;2;3;0
WireConnection;1;0;14;0
WireConnection;1;1;4;0
WireConnection;16;0;1;0
WireConnection;16;1;15;0
WireConnection;0;0;16;0
ASEEND*/
//CHKSM=D1CBCADDB9768FA5DAE4929987830F2B0F9BAA07