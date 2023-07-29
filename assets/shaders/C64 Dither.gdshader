shader_type canvas_item;

// chppse if dither is on
#define Dither

// PaletteSize
#define PaletteSize 16
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform int dither :hint_range(0, 1, 1)=1;
uniform float distanceParam:hint_range(0.01, 1.0, 0.01)= 0.4; // [0-1]

// 0= C64 palette, 1= black and white, 2=Custom
uniform int palette_choice:hint_range(0, 2, 1)=0;

uniform float DownScale:hint_range(0.01, 1.0, 0.01)= 1.0; // [0-1]


// custom palette
uniform vec3 palette_vector1:source_color= vec3(  0,0,0);
uniform vec3 palette_vector2:source_color= vec3(  1,  1,  1);
uniform vec3 palette_vector3:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector4:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector5:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector6:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector7:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector8:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector9:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector10:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector11:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector12:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector13:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector14:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector15:source_color= vec3(  0,  0,  0);
uniform vec3 palette_vector16:source_color= vec3(  0,  0,  0);

vec3[PaletteSize] palette_chooser(int pal){
vec3[PaletteSize] pale=
// C64 like palette
    {
		vec3(  0,  0,  0)/255.0,
        vec3(255,255,255)/255.0,
        vec3(152, 75, 67)/255.0,
        vec3(121,193,200)/255.0,	
        vec3(155, 81,165)/255.0,
        vec3(104,174, 92)/255.0,
        vec3( 62, 49,162)/255.0,
        vec3(201,214,132)/255.0,	
        vec3(155,103, 57)/255.0,
        vec3(106, 84,  0)/255.0,
        vec3(195,123,117)/255.0,
        vec3( 85, 85, 85)/255.0,	
        vec3(138,138,138)/255.0,
        vec3(163,229,153)/255.0,
        vec3(138,123,206)/255.0,
        vec3(173,173,173)/255.0
	};


vec3[PaletteSize] pale1=
// monochrome palette
    {
		vec3(  0,  0,  0)/255.0,
        vec3(255,255,255)/255.0,
        vec3(0,  0,  0)/255.0,
        vec3(0,  0,  0)/255.0,	
        vec3(0,  0,  0)/255.0,
        vec3(0,  0,  0)/255.0,
        vec3( 0,  0,  0)/255.0,
        vec3(0,  0,  0)/255.0,	
        vec3(0,  0,  0)/255.0,
        vec3(0,  0,  0)/255.0,
        vec3(0,  0,  0)/255.0,
        vec3(0,  0,  0)/255.0,	
        vec3(0,  0,  0)/255.0,
        vec3(0,  0,  0)/255.0,
        vec3(0,  0,  0)/255.0,
        vec3(0,  0,  0)/255.0
	};
	
vec3[PaletteSize] pale2=
// custom palette
    {
		palette_vector1/255.0,
        palette_vector2/255.0,
        palette_vector3/255.0,
       	palette_vector4/255.0,	
        palette_vector5/255.0,
        palette_vector6/255.0,
        palette_vector7/255.0,
        palette_vector8/255.0,	
        palette_vector9/255.0,
        palette_vector10/255.0,
        palette_vector11/255.0,
        palette_vector12/255.0,	
        palette_vector13/255.0,
       	palette_vector14/255.0,
        palette_vector15/255.0,
        palette_vector16/255.0
	};
	
	
switch (pal){
	case 0:
		return pale;
	case 1:
		return pale1;
	case 2:
		return pale2;
}
}
	
float colorDistance(vec3 color, vec3 c1, vec3 c2, float frac)
{
    return mix(distance(color, mix(c1, c2, frac)), distance(color, c1) + distance(color, c2), 0.5*distanceParam*distanceParam);
}

// choose palette
vec3 getPalettifiedColor(vec3 color, vec2 coord, vec2 texture_size, vec3[16] palette)
{
    color *= color;

    vec3 c1 = vec3(0);
    vec3 c2 = vec3(0);
    
    float frac = 0.0;

    for (int i = 0; i < (PaletteSize - 1); ++i)
    {
        for (int j = i + 1; j < PaletteSize; ++j)
        {
            vec3 p1 = palette[i];
            vec3 p2 = palette[j];            
            
            p1 *= p1;
            p2 *= p2;
           
            vec3 num = p1*p1 - p1*color - p1*p2 + p2*color;
            vec3 den = p1*p1 - 2.0*p1*p2 + p2*p2;
            
            float a = (num.r + num.g + num.b)/(den.r + den.g + den.b);
            
            if (colorDistance(color, p1, p2, a) < colorDistance(color, c1, c2, frac))
            {
                c1 = p1;
                c2 = p2;
                frac = a;
            }
        }
    }
if (dither==1){
	vec2 iChannelResolution= 1.0/ texture_size;
    return sqrt(mix(c1, c2, float(frac > texture(screen_texture, coord/iChannelResolution.xy).r)));
	}
else{
    return sqrt(mix(c1, c2, frac));
	}
}


	
void fragment() {
	
	vec3[16] palette = palette_chooser(palette_choice);
	vec4 fragCoord = floor(FRAGCOORD/DownScale)*DownScale;
    
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
  
    vec3 outColor = texture(screen_texture, fragCoord.xy/iResolution.xy).rgb;
    
    outColor = getPalettifiedColor(outColor, fragCoord.xy/DownScale, TEXTURE_PIXEL_SIZE, palette);


    COLOR = vec4(outColor, 1.0);
}