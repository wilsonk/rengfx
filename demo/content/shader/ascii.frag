#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// user vars

uniform vec2 c_resolution;

#define zoom 1.

#define P(id,a,b,c,d,e,f,g,h) if(id == int(pos.y)){ int pa = a+2*(b+2*(c+2*(d+2*(e+2*(f+2*(g+2*(h))))))); cha = floor(mod(float(pa)/pow(2.,float(pos.x)-1.),2.)); }

float calc_gray(vec3 col) {
    return col.x*0.299+col.y*0.587+col.z*0.114;
}

vec4 sample(vec2 offset) {
    return texture(texture0, fragTexCoord.xy - offset) * fragColor;
}

void main() {
    vec2 pixCoord = fragTexCoord.xy * c_resolution;
    // sample based on character width and height
    float samp_x = floor((pixCoord.x / 8.) / zoom) * 8. * zoom;
    float samp_y = floor((pixCoord.y / 12.) / zoom) * 12. * zoom;

    vec2 uv = vec2(samp_x, samp_y) / c_resolution;
    ivec2 pos = ivec2(mod(pixCoord.x / zoom, 8.), mod(pixCoord.y / zoom, 12.));
    vec4 tex = texture(texture0, uv);
    float cha = 0.;
    
    float g = calc_gray(tex.xyz);
    if( g < .125 )
    {
        P(11,0,0,0,0,0,0,0,0);
        P(10,0,0,0,0,0,0,0,0);
        P(9,0,0,0,0,0,0,0,0);
        P(8,0,0,0,0,0,0,0,0);
        P(7,0,0,0,0,0,0,0,0);
        P(6,0,0,0,0,0,0,0,0);
        P(5,0,0,0,0,0,0,0,0);
        P(4,0,0,0,0,0,0,0,0);
        P(3,0,0,0,0,0,0,0,0);
        P(2,0,0,0,0,0,0,0,0);
        P(1,0,0,0,0,0,0,0,0);
        P(0,0,0,0,0,0,0,0,0);
    }
    else if( g < .25 ) // .
    {
        P(11,0,0,0,0,0,0,0,0);
        P(10,0,0,0,0,0,0,0,0);
        P(9,0,0,0,0,0,0,0,0);
        P(8,0,0,0,0,0,0,0,0);
        P(7,0,0,0,0,0,0,0,0);
        P(6,0,0,0,0,0,0,0,0);
        P(5,0,0,0,0,0,0,0,0);
        P(4,0,0,0,1,1,0,0,0);
        P(3,0,0,0,1,1,0,0,0);
        P(2,0,0,0,0,0,0,0,0);
        P(1,0,0,0,0,0,0,0,0);
        P(0,0,0,0,0,0,0,0,0);
    }
    else if( g < .375 ) // ,
    {
        P(11,0,0,0,0,0,0,0,0);
        P(10,0,0,0,0,0,0,0,0);
        P(9,0,0,0,0,0,0,0,0);
        P(8,0,0,0,0,0,0,0,0);
        P(7,0,0,0,0,0,0,0,0);
        P(6,0,0,0,0,0,0,0,0);
        P(5,0,0,0,0,0,0,0,0);
        P(4,0,0,0,1,1,0,0,0);
        P(3,0,0,0,1,1,0,0,0);
        P(2,0,0,0,0,1,0,0,0);
        P(1,0,0,0,1,0,0,0,0);
        P(0,0,0,0,0,0,0,0,0);
    }
    else if( g < .5 ) // -
    {
        P(11,0,0,0,0,0,0,0,0);
        P(10,0,0,0,0,0,0,0,0);
        P(9,0,0,0,0,0,0,0,0);
        P(8,0,0,0,0,0,0,0,0);
        P(7,0,0,0,0,0,0,0,0);
        P(6,1,1,1,1,1,1,1,0);
        P(5,0,0,0,0,0,0,0,0);
        P(4,0,0,0,0,0,0,0,0);
        P(3,0,0,0,0,0,0,0,0);
        P(2,0,0,0,0,0,0,0,0);
        P(1,0,0,0,0,0,0,0,0);
        P(0,0,0,0,0,0,0,0,0);
    }
    else if(g < .625 ) // +
    {
        P(11,0,0,0,0,0,0,0,0);
        P(10,0,0,0,0,0,0,0,0);
        P(9,0,0,0,1,0,0,0,0);
        P(8,0,0,0,1,0,0,0,0);
        P(7,0,0,0,1,0,0,0,0);
        P(6,1,1,1,1,1,1,1,0);
        P(5,0,0,0,1,0,0,0,0);
        P(4,0,0,0,1,0,0,0,0);
        P(3,0,0,0,1,0,0,0,0);
        P(2,0,0,0,0,0,0,0,0);
        P(1,0,0,0,0,0,0,0,0);
        P(0,0,0,0,0,0,0,0,0);
    }
    else if(g < .75 ) // *
    {
        P(11,0,0,0,0,0,0,0,0);
        P(10,0,0,0,1,0,0,0,0);
        P(9,1,0,0,1,0,0,1,0);
        P(8,0,1,0,1,0,1,0,0);
        P(7,0,0,1,1,1,0,0,0);
        P(6,0,0,0,1,0,0,0,0);
        P(5,0,0,1,1,1,0,0,0);
        P(4,0,1,0,1,0,1,0,0);
        P(3,1,0,0,1,0,0,1,0);
        P(2,0,0,0,1,0,0,0,0);
        P(1,0,0,0,0,0,0,0,0);
        P(0,0,0,0,0,0,0,0,0);
    }
    else if(g < .875 ) // #
    {
        P(11,0,0,0,0,0,0,0,0);
        P(10,0,0,1,0,0,1,0,0);
        P(9,0,0,1,0,0,1,0,0);
        P(8,1,1,1,1,1,1,1,0);
        P(7,0,0,1,0,0,1,0,0);
        P(6,0,0,1,0,0,1,0,0);
        P(5,0,1,0,0,1,0,0,0);
        P(4,0,1,0,0,1,0,0,0);
        P(3,1,1,1,1,1,1,1,0);
        P(2,0,1,0,0,1,0,0,0);
        P(1,0,1,0,0,1,0,0,0);
        P(0,0,0,0,0,0,0,0,0);
    }
    else // @
    {
        P(11,0,0,0,0,0,0,0,0);
        P(10,0,0,1,1,1,1,0,0);
        P(9,0,1,0,0,0,0,1,0);
        P(8,1,0,0,0,1,1,1,0);
        P(7,1,0,0,1,0,0,1,0);
        P(6,1,0,0,1,0,0,1,0);
        P(5,1,0,0,1,0,0,1,0);
        P(4,1,0,0,1,0,0,1,0);
        P(3,1,0,0,1,1,1,1,0);
        P(2,0,1,0,0,0,0,0,0);
        P(1,0,0,1,1,1,1,1,0);
        P(0,0,0,0,0,0,0,0,0);
    }
    
    vec3 col = tex.xyz / max(tex.x,max(tex.y,tex.z));
    finalColor = vec4(cha*col,1.);

    // finalColor = vec4(g, g, g, 1);
    // finalColor = vec4(tex.xyz, 1.);
}