/* 
   <meta id="RMSSTAMP">
    Creator RfM 5.5b2 (@1222788 Sep 11 2013)
    For gharker
    CreationDate Wed Sep 25 17:01:38 2013
  </meta>
*/

/*
# ------------------------------------------------------------------------------
#
# Copyright (c) 2012 Pixar Animation Studios. All rights reserved.
#
# The information in this file (the "Software") is provided for the
# exclusive use of the software licensees of Pixar.  Licensees have
# the right to incorporate the Software into other products for use
# by other authorized software licensees of Pixar, without fee.
# Except as expressly permitted herein, the Software may not be
# disclosed to third parties, copied or duplicated in any form, in
# whole or in part, without the prior written permission of
# Pixar Animation Studios.
#
# The copyright notices in the Software and this entire statement,
# including the above license grant, this restriction and the
# following disclaimer, must be included in all copies of the
# Software, in whole or in part, and all permitted derivative works of
# the Software, unless such copies or derivative works are solely
# in the form of machine-executable object code generated by a
# source language processor.
#
# PIXAR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
# ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT
# SHALL PIXAR BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES
# OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
# WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
# ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
# SOFTWARE.
#
# Pixar
# 1200 Park Ave
# Emeryville CA 94608
#
# ------------------------------------------------------------------------------
*/

/*
 * RMSGPSurface.sl  $Revision: #55 $
 *  a GeneralPurpose Surface Shader that supports layered physically plausible
 *  shading and subsurface scattering.
 */

/*
*/

#define DEBUG 0

#define ISBASESHADER() (this == surface)

// RSLINJECT_preamble
#include <customNodes/_rmsGPSurface.h>
#include <customNodes/_rmsDisplacement.h>


// RSLINJECT_shaderdef
class
siggraph_glassBottlesOnCakeStand_v03_RMSGPSurface4_rfm
(
    uniform color surfaceColor=color(1, 1, 1);
    uniform float diffuseGain=0.5;
    uniform color translucentColor=color(0, 0, 0);
    uniform color emission=color(0, 0, 0);
    uniform float __computesOpacity=0;
    uniform float diffuseRoughness=0.1;
    uniform float purity=0.002;
    uniform float distributionAngle=0;
    uniform float emissionExposure=0;
    uniform shader boundLayers[]= {};
    uniform float refractionAmount=0;
    uniform shader glass= null;
    uniform float roughness=0.008;
    uniform float specularGain=1;
    uniform color specularColor=color(1, 1, 1);
    uniform float anisotropy=0;
    uniform float indirectSpecularScale=1;
    uniform float metallic=0;
    uniform float flakeAmount=0;
    uniform float flakeScale=10;
    uniform float ior=1.5;
    uniform float specularBlend=0;
    uniform float roughnessB=0.008;
    uniform float specularGainB=1;
    uniform float anisotropyB=0;
    uniform color specColorB=color(1, 1, 1);
    uniform float indirectSpecularScaleB=1;
    uniform float specularConeAngleSamples=1;
    uniform float maxSpecularSamples=16;
    uniform float lightConeAngleSamples=4;
    uniform float maxLightSamples=16;
    varying float _roughness=-1;
    varying float traceIor=-1;
    uniform float dispMode=1;
    uniform float compositionRule=1;
    uniform color sssTint=color(1, 1, 1);
    uniform color sssMix=color(0, 0, 0);
    uniform float sssDmfpScale=1;
    uniform color sssDmfp=color(1, 1, 1);
    uniform float sssSamples=16;
    uniform string sssPassID="RenderCam_SSRender";
    uniform string sssConversionClass="SSDiffuse";
    uniform string sssOutputFile="";
    uniform string sssMap="";
    uniform string sssMapConnection="";
    uniform string sssSpace="world";
    uniform string __group="";
    uniform string lightGroups[]={};
    uniform string __category="RMSGPLayer,stdrsl_plausible";
    uniform string SurfaceMap="";
    uniform string SpecularMap="";
    uniform string SpecularMapB="";
    uniform string RoughnessMap="";
    uniform string DisplacementMap="";
    uniform string MaskMap="";
    uniform string shadowname="";
    uniform float traceShadows=1;
    uniform float adaptive=1;
    uniform string subset="";
    uniform string excludesubset="";
    uniform float bias=-1;
    uniform float mapbias=1;
    uniform float mapbias2=1;
)
{
    // All member variables are deemed private
    rms_GPSurface m_gpsurf;

    // RSLINJECT_members
    #define specularFeatures 1
    #define enableOldRoughnessMapping 0
    #define tangentSource -1
    #define bumpEncoding 1
    #define sssSmooth 0
    #define giSamplesOverride -1
    #define linearizeTint 0
    #define mask 1
    #define transparency color(0, 0, 0)
    #define maskReflections 0
    #define specularClamp 100
    #define tangentInput -1
    #define indirectIrradiance 0
    #define enableDisplacement -1
    #define vectorEncoding 1
    #define displacementScalar 0
    #define displacementVector vector(0, 0, 0)
    #define displacementAmount 0
    #define normalEncoding 0
    #define normalMode -1
    #define inputNormal normal(0, 0, 0)
    #define displacementCenter 0.5
    #define bumpScalar 0
    #define bumpAmount 0
    #define lightCategory ""
    #define sssAlbedo color(1, 1, 1)
    #define useCs 1
    #define applySRGB 1
    #define sssUnitlen 0.1
    #define sssMaxDepth 2
    #define sssTraceSet ""
    #define sssMaxDist 10
    #define mediaIor 1
    #define inputNormalA normal(0, 0, 0)
    #define specularBFeatures 1
    #define inputNormalB normal(0, 0, 0)
    #define indirectSpecularSubset ""
    #define specularMaxDistance 100000
    #define backSideReflections 0
    #define importanceThreshold 1e-05
    #define specularBroadening 1

    public void construct()  
        // no parameter dependencies, so no INJECT
    {
        m_gpsurf->Construct(); 
    }

    public void begin() 
        // depends on mask settings, boundLayers
        // guaranteed to run in coshaders prior to any method invocations
    {
        // RSLINJECT_begin
        if(ISBASESHADER()) 
        {
            color Opacity = mask * (color(1) - 
                    clamp(transparency,color(0),color(1)));
            m_gpsurf->Begin(boundLayers, Opacity,
                            MaskMap, maskReflections, specularClamp, 
                            tangentSource, tangentInput, indirectIrradiance,
                            refractionAmount, glass);
        }
    }
 
    public void opacity(output color Oi)
    {
        m_gpsurf->DelegateOpacity(__computesOpacity, Oi);
    }

    // displacement:
    //  the displacement method is only called on the BASESHADER
    //  we delegate to coshaders variant method ComputeLayerDisplacement
    //
    public void displacement(output point P; output normal N) 
    {
        m_gpsurf->DelegateDisplacement(enableDisplacement, dispMode, P, N);
    }

    public void prelighting(output color Ci, Oi) 
    {
        // RSLINJECT_prelighting
        if(this == surface)
            m_gpsurf->DelegatePrelighting(emission, distributionAngle, 
                                          emissionExposure, traceShadows,
                                          adaptive, bias, mapbias, mapbias2,
                                          shadowname, subset, excludesubset);
    }

    // initDiffuse: shared initialization function for diffuse.
    //
    private color initDiffuse() 
    {
        // RSLINJECT_initDiffuse

        if(ISBASESHADER() && useCs == 1)
        {
            m_gpsurf->InitDiffuse(surfaceColor*Cs, SurfaceMap, translucentColor, 
                                  applySRGB, purity, diffuseRoughness, 
                                  diffuseGain, metallic);
        }
        else
        {
            m_gpsurf->InitDiffuse(surfaceColor, SurfaceMap, translucentColor,
                                  applySRGB, purity, diffuseRoughness, 
                                  diffuseGain, metallic);
        }
        return m_gpsurf->m_diffuse->m_diffColor;
    }

    // initSpecular: shared initialization function for specular.
    //
    private void initSpecular(color specContribution;) 
    {
        // RSLINJECT_initSpecular

        m_gpsurf->InitSpecular(specularBlend, mediaIor, ior,
                            specContribution,
                            specularGain, specularGainB,
                            specularColor, specColorB,
                            SpecularMap, SpecularMapB,
                            roughness, roughnessB, RoughnessMap,
                            anisotropy, anisotropyB,
                            metallic, flakeAmount, flakeScale, 
                            specularFeatures, specularBFeatures,
                            applySRGB, specularConeAngleSamples, 
                            maxSpecularSamples, lightConeAngleSamples,
                            maxLightSamples, backSideReflections, 
                            indirectSpecularScale,
                            indirectSpecularScaleB,
                            specularBroadening, _roughness,
                            inputNormalA, inputNormalB, traceIor,
                            enableOldRoughnessMapping);
    }

    // The base shader lighting methods -----------------------------------
    // lighting:
    //   automatically called on base shader on primary reyes grids
    //   we delegate to coshader lightingCS method
    //
    public void lighting(output color Ci, Oi) 
    {
        // Handle case where shader has difference opacity
        // for transmission rays vs shading opacity

        if(glass != null)
            Oi = m_gpsurf->m_shadingOi;

        // RSLINJECT_lighting

        color specContribution;
        if(m_gpsurf->BaseIsVisible(specContribution) == 1)
        {
            initDiffuse();
            initSpecular(specContribution);
        }
        Ci = m_gpsurf->DelegateLighting(lightCategory, lightGroups,
                           ior, metallic, sssAlbedo, sssTint, 
                           sssDmfp * sssDmfpScale, sssUnitlen, 
                           sssSamples, sssMix, sssTraceSet,
                           sssMaxDist, sssMaxDepth, sssPassID, 
                           sssConversionClass, sssOutputFile, sssMap, sssSpace,
                           indirectSpecularSubset, 
                           specularMaxDistance, importanceThreshold, 
                           giSamplesOverride);
    }

    // diffuselighting:
    //   automatically called on base shader on ray-shaded points
    //   we delegate to coshader DiffuselightingCS method
    //
    public void diffuselighting(output color Ci, Oi, Ii) 
    {
        // RSLINJECT_diffuselighting

        // Handle case where shader has difference opacity
        // for transmission rays vs shading opacity

        if(glass != null)
            Oi = m_gpsurf->m_shadingOi;

        color specContribution;
        if(m_gpsurf->BaseIsVisible(specContribution) == 1)
        {
            initDiffuse();
        }
        Ci = m_gpsurf->DelegateDiffuseLighting(lightCategory, lightGroups, ior, 
                           metallic, sssAlbedo, sssTint, sssDmfp * sssDmfpScale,
                           sssUnitlen, sssSamples, sssMix, sssTraceSet, 
                           sssMaxDist, sssMaxDepth, sssPassID,
                           sssConversionClass, sssOutputFile, sssMap, 
                           sssSpace, giSamplesOverride, Ii);
    }

    // specularlighting:
    //   automatically called on base shader on ray-shaded points
    //   we delegate to coshader SpecularlightingCS method
    //
    public void specularlighting(output color Ci, Oi) 
    {
        if(m_gpsurf->m_disableViewDependence == 1) 
            return;

        // Handle case where shader has difference opacity
        // for transmission rays vs shading opacity

        if(glass != null)
            Oi = m_gpsurf->m_shadingOi;

        // RSLINJECT_specularlighting

        color specContribution;
        if(m_gpsurf->BaseIsVisible(specContribution) == 1)
        {
            initSpecular(specContribution);
        }
        Ci = m_gpsurf->DelegateSpecularLighting(lightCategory, lightGroups, Ci,
                                specularBroadening, indirectSpecularSubset, 
                                 specularMaxDistance, importanceThreshold);
    }

    public void postlighting(output varying color Ci, Oi)
    {
        m_gpsurf->DelegatePostLighting(Ci,Oi);
    }

    /*---------------------------------------------------------------*/
    // evaluateSamples:
    //  called by directlighting and/or indirectspecular
    //  base shader delegates to EvaluateLayerSamples method on coshaders
    //
    public void evaluateSamples(string distribution;
                                output __radiancesample samples[])
    {
        m_gpsurf->DelegateEvaluateSamples(distribution, samples);
    }

    // generateSamples:
    //   called from directlighting integrator, thus only in base shader
    //   we delegate to GenerateSamplesCS
    //
    public void generateSamplesWithRoughness(string type; output __radiancesample samples[];
                                output float roughnessVals[])
    {
        m_gpsurf->DelegateGenerateSamples(type, samples, roughnessVals);
    }
    public void generateSamples(string type; output __radiancesample samples[];)
    {
        float roughnessVals[];
        m_gpsurf->DelegateGenerateSamples(type, samples, roughnessVals);
    }
    /*---------------------------------------------------------------*/
    // InitCoshader:
    //  a special coshader interface method to ensure synchronization
    //  of shading context and layering with base shader.
    //  May be called twice when displacements are in play.
    public void InitCoshader(stdrsl_ShadingContext ctx; 
                             output color omask;
                             output uniform float omaskReflections;)
        // depends on mask parameters
    {
        m_gpsurf->m_shadingCtx = ctx; // precedes RSLINJECT

        // RSLINJECT_InitCoshader

        color Opacity = mask * (color(1) - clamp(transparency,color(0),color(1)));
        m_gpsurf->InitMask(Opacity, MaskMap);

        omask = m_gpsurf->m_mask;
        omaskReflections = maskReflections;

    }

    // ComputeLayerDisplacement:
    //  a special coshader interface for displacement composition
    //  called via baseshader->displacement->ComputeDisplacement
    public void ComputeLayerDisplacement(point origP; 
                                         normal origN; 
                                         output point accumP; 
                                         output normal accumN)
        // depends on: 
        //      dispMode, compositionRule, displacementVector, 
        //      DisplacementMap, displacementAmount, displacementCenter
        //      overrideNormal, inputNormal 
    {
        // RSLINJECT_displacement
        rms_Displacement disp;

        // Masking the displacement from the base layer isn't desirable
        varying float localMask = (this == surface) ? 1 : mask;

        disp->ComputeLayerDisplacement(origP, origN, accumP, accumN,
                                          localMask,
                                          dispMode, vectorEncoding, 
                                          normalEncoding,
                                          displacementScalar, 
                                          displacementVector, 
                                          DisplacementMap, 
                                          displacementAmount, 
                                          displacementCenter,
                                          normalMode, inputNormal,
                                          compositionRule,
                                          bumpScalar,
                                          bumpAmount,
                                          bumpEncoding
                                          );

    }

    // The coshader lighting methods -----------------------------------
    // Simplified methods that need only return data to the base shader 
    // for evaluation. Only called via delegation from base shader.
    public void InitLayerDiffuse(output color diffuseColor;
                                 output color SssAlbedo, SssTint, SssDmfp, SssMix;
                                 output float SssUnitlen,SssSamples;)
    {
        SssTint = sssTint;
        SssAlbedo = sssAlbedo;
        SssDmfp = sssDmfp * sssDmfpScale;
        SssMix = sssMix;
        SssUnitlen = sssUnitlen;
        SssSamples = sssSamples;

        diffuseColor = initDiffuse();
    }

    public void InitLayerSpecular(color specContribution; output float Kt)
    {
        uniform float ifEverSpec = 0;
        if(specContribution !=color(0))
            ifEverSpec = 1;

        if(ifEverSpec == 1) {
            initSpecular(specContribution);
            Kt = m_gpsurf->m_fresnel->m_Kt;
        } else {
            Kt = 1;
        }
    } 

    public void InitLayerSpecAndDiffuse(color specContribution;
                                        output color diffuseColor;
                                        output float Kt;
                                        output color SssAlbedo, SssTint, SssDmfp, SssMix;
                                        output float SssUnitlen,SssSamples;
                                        )
    {
        InitLayerSpecular(specContribution, Kt);
        InitLayerDiffuse(diffuseColor, SssTint, SssAlbedo, SssDmfp,
                         SssMix, SssUnitlen, SssSamples);
    }

    public void EvaluateLayerSamples(string distribution;
                                color layerContrib;
                                output __radiancesample samples[])
    {
        m_gpsurf->EvaluateLayerSamples(distribution, layerContrib, samples);
    }

    public void GenerateLayerSamples(string type; 
                                output __radiancesample samples[];
                                output float roughnessVals[];
                                output uniform float counts[])
    {
        m_gpsurf->GenerateLayerSamples(type,samples,roughnessVals, counts);
    }

    public void UpdateLayerManifold(point PP; normal NN)
    {
        m_gpsurf->m_shadingCtx->m_Ps = PP;
        m_gpsurf->m_shadingCtx->m_Nn = NN;
        m_gpsurf->m_shadingCtx->reinit();
    }
    
    //Method for evaluating the prelighting method on the coshader and 
    //returning incandescence behavior
    public void GetEmission(output color retIncand; output varying float retExposure)
    {
        //run the prelighting setup here just to return emission to 
        //the parent coshader
        // RSLINJECT_prelighting
        retIncand = emission;
        retExposure = emissionExposure;
    }
}
