// Copyright (c) 2015 Sergio Gonzalez. All rights reserved.
// License: https://github.com/serge-rgb/milton#license

in vec2 v_sizes;

uniform int u_radius;
uniform bool u_fill;
uniform vec4 u_color;


void
main()
{
    float r = length(v_sizes);

    // Make preview ring high-contrast and thicker so it remains visible
    // against both light and dark backgrounds.
    float girth = u_fill ? 3.0 : 2.0;
    const float ring_alpha = 0.9;

    if ( r <= u_radius
         && r > u_radius - girth ) {
        out_color = vec4(0,0,0,ring_alpha);
    }
    else if ( r < u_radius + girth && r >= u_radius ) {
        out_color = vec4(1,1,1,ring_alpha);
    }
    else if ( u_fill && r < u_radius ) {
        out_color = u_color;
    }
    else {
        discard;
    }
}

