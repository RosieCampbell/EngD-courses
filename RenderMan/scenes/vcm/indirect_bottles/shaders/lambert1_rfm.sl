/* 
   <meta id="RMSSTAMP">
    Creator RfM 5.5b2 (@1222788 Sep 11 2013)
    For gharker
    CreationDate Wed Sep 25 16:41:10 2013
  </meta>
*/

plugin "RfMShadeops";
#include "mayaNodes/_rfmShadingState.h"
#include "mayaNodes/geomNormal.h"
#include "mayaNodes/_rfmShadingUtils.h"

/* begin generate ---- */
surface
lambert1_rfm
(
    uniform color lambert1_c=color(0.5, 0.5, 0.5);
    uniform float lambert1_dc=0.8;
    uniform string lambert1_SSPassid="";
    uniform string lambert1_SSConversionClass="";
    uniform string lambert1_rman__SSOutputFile="";
    uniform string lambert1_rman__SSMap="";
    varying color _spectralImportance=color(1, 1, 1);
    varying float _volumetricExtinction=0;
    varying float _mediumIOR=1;
    uniform float __computesOpacity=0;
    uniform string rfmSurface__bakeMap="";
    output varying color Ambient;
    output varying color DiffuseColor;
    output varying color DiffuseDirect;
    output varying color DiffuseDirectShadow;
    output varying color DiffuseIndirect;
    output varying color DiffuseEnvironment;
    output varying color SpecularColor;
    output varying color SpecularDirect;
    output varying color SpecularDirectShadow;
    output varying color SpecularIndirect;
    output varying color SpecularEnvironment;
    output varying color Backscattering;
    output varying color Incandescence;
    output varying color Refraction;
    output varying color Rim;
    output varying color Translucence;
    output varying color Subsurface;
    output varying color OcclusionDirect;
    output varying color OcclusionIndirect;
    output varying color GlowColor;
)
{

RFM_SURFACE_SETUP();
// no extra source for geomNormal

#include "mayaNodes/lambert.h" // need access to globals
            

#include "mayaNodes/rfmSurface.h" // we need to access globals
            

RFM_SURFACE_BEGIN();
    varying normal tmp_0;
    rfm_geomNormal
    (
        tmp_0 // out_N
    );
    rfmShadingState tmp_1;
    varying color tmp_2;
    varying color tmp_3;
    varying color tmp_4;
    rfm_lambert
    (
        lambert1_c, // c
        lambert1_dc, // dc
        color(0, 0, 0), // transparency
        color(0, 0, 0), // ambientColor
        color(0, 0, 0), // incandescence
        0, // translucence
        0.5, // translucenceFocus
        0.5, // translucenceDepth
        0, // glowIntensity
        0, // hideSource
        0, // surfaceThickness
        0.5, // shadowAttenuation
        0, // lightAbsorbance
        0, // chromaticAberration
        tmp_0, // normalCamera
        2, // matteOpacityMode
        1, // matteOpacity
        0, // refractions
        6, // refractionLimit
        1, // refractiveIndex
        1, // rman__TraceRefractionSamples
        "refraction", // rman__TraceRefractionSubset
        1e+10, // rman__TraceRefractionMaxDist
        0, // rman__TraceRefractionBlur
        lambert1_SSPassid, // SSPassid
        lambert1_SSConversionClass, // SSConversionClass
        lambert1_rman__SSOutputFile, // rman__SSOutputFile
        lambert1_rman__SSMap, // rman__SSMap
        1, // rman__SSMult
        color(1, 1, 1), // rman__SSEnterTint
        color(1, 1, 1), // rman__SSExitTint
        color(0.5, 0.5, 0.5), // rman__SSAlbedo
        0.5, // rman__SSDiffuseMeanFreePathlen
        color(1, 1, 1), // rman__SSDMFPTint
        1, // rman__SSFilterScale
        "world", // rman__SSCoordSystem
        1, // rman__IndirectColorMult
        1, // rman__RadiosityMult
        1, // rman__IndirectEnvMult
        1, // rman__SpecularEnvMult
        _spectralImportance,
        _volumetricExtinction,
        _mediumIOR,
        tmp_1, // outputShadingState
        tmp_2, // outColor
        tmp_3, // outGlowColor
        tmp_4 // outTransparency
    );
    rfm_rfmSurface
    (
        __computesOpacity,
        tmp_2, // surfColor
        tmp_3, // surfGlowColor
        tmp_4, // surfTransparency
        tmp_1, // inputShadingState
        rfmSurface__bakeMap, // _bakeMap
        Ambient,
        DiffuseColor,
        DiffuseDirect,
        DiffuseDirectShadow,
        DiffuseIndirect,
        DiffuseEnvironment,
        SpecularColor,
        SpecularDirect,
        SpecularDirectShadow,
        SpecularIndirect,
        SpecularEnvironment,
        Backscattering,
        Incandescence,
        Refraction,
        Rim,
        Translucence,
        Subsurface,
        OcclusionDirect,
        OcclusionIndirect,
        GlowColor
    );

RFM_SURFACE_END();
}

