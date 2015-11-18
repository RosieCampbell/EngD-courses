/**
 * Change the color saturation in the beauty pass according to contribution
 * from a light group.  The contribution is read from an AOV.
 *
 * @param group  name of AOV to read to get the light from the light group.
 * @param thresh  luminance in AOV less than this is considered shadowed.
 * @param shift  amount and direction to shift saturation.
 */
class satlight(
    uniform string group = "";
    uniform float thresh = 1.0;
    uniform float shift = 0.0; )
{
    public void imager(
        output varying color Ci;
        output varying color Oi )
    {
        // Read the AOV and determine how much in shadow the pixel is.
        color aov;
        readaov( group, aov );
        float lit = comp( ctransform( "YIQ", aov ), 0 );
        float shad = max( thresh - lit, 0.0 ) / thresh;
        // Luminance of pixel in beauty.
        float Y = comp( ctransform( "YIQ", Ci ), 0 );
        if ( Y > 0.0 )
        {
            // Normalize beauty by luminance.
            Ci /= Y;
            // Adjust the color values multiplicatively.
            float ex = pow( 2.0, shift * shad );
            Ci = color(
                pow( comp( Ci, 0 ), ex ),
                pow( comp( Ci, 1 ), ex ),
                pow( comp( Ci, 2 ), ex ) );
            // Reapply original luminance.
            float newY = comp( ctransform( "YIQ", Ci ), 0 );
            Ci *= Y / newY;
        }
    }
}
