/* 
   <meta id="RMSSTAMP">
    Creator RfM 5.5b2 (@1222788 Sep 11 2013)
    For gharker
    CreationDate Wed Sep 25 16:47:53 2013
  </meta>
*/

/*
# ------------------------------------------------------------------------------
#
# Copyright (c) 2011 Pixar Animation Studios. All rights reserved.
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
 *RMSAreaLight.sl  $Revision: #1 $
 */
/*
*/


// RSLINJECT_preamble
#include <stdrsl/ShadingContext.h>
#include <customNodes/_rmsLightUtils.h>


// RSLINJECT_shaderdef
class
RMSGeoAreaLightShape4_rfm
(
    uniform string shape="rect";
    uniform float intensity=20;
    uniform color lightcolor=color(1, 1, 1);
    uniform float temperature=7775.28;
    uniform color specAmount=color(1, 1, 1);
    uniform color diffAmount=color(1, 1, 1);
    uniform color shadowColor=color(0, 0, 0);
    uniform string __group="";
    uniform shader __boundcoshaders[]= {};
    uniform float coneangle=90;
    uniform float penumbraangle=5;
    uniform float penumbraexponent=0;
    uniform string profilemap="";
    uniform string iesprofile="";
    uniform float distributionAngle=90;
    uniform float angularVisibility=1;
    uniform float rmsDisplayBarnDoors=0;
    uniform float rmsBarnT=0;
    uniform float rmsBarnB=0;
    uniform float rmsBarnL=0;
    uniform float rmsBarnR=0;
    uniform string barnDoorMap="default.tex";
    uniform float traceShadows=1;
    uniform float adaptive=1;
    uniform string subset="";
    uniform string excludesubset="";
    uniform string shadowname="";
    uniform float samplebase=0.5;
    uniform float bias=-1;
    uniform float mapbias=1;
    uniform float mapbias2=1;
    uniform float sides=0;
    uniform float areaNormalize=1;
    uniform string photonTarget="";
    uniform string __category="stdrsl_plausible,RMSGeoAreaLightShape4";
)
{
    //Members
    varying color m_lightColor;
    varying normal m_Ns;  
    vector m_direction, m_tangent, m_bitangent;
    uniform float m_angularSpread, m_tan;
    uniform float m_pdf;
    uniform float m_trace = 1;

    // RSLINJECT_members
    #define rman__LightPrimaryVisibility 0
    #define profilerange -1
    public void light(output vector L; output color Cl;)
    {
        // Dummy method signals that this class is intended for use as light
        L = 0;
        Cl = 0;
    }

    public void construct()
    {
        option("user:pass_features_trace",m_trace);
    }

    public void begin()
    {
        // RSLINJECT_begin

        uniform float raydepth;
        uniform float doubleSided;
        rayinfo("depth", raydepth);
        attribute("Sides", doubleSided);

        // We need to agree with surface over the definition of the
        // lighting  hemisphere. This is captured in m_Ns.
        normal nn, nf;
        vector in;
        stdrsl_ShadingUtils sutils;
        sutils->GetShadingVars(raydepth, doubleSided, nn, in, nf, m_Ns);
        m_lightColor = lightcolor * pow(2,intensity);

        if(temperature != -1)
            m_lightColor *= KtoRGB(temperature); 

        uniform float xlen = length(vector "shader" (1,0,0));
        uniform float ylen = length(vector "shader" (0,1,0));

        if(areaNormalize == 1)
        {
            if(shape == "rect")
                m_lightColor /= (xlen * ylen); 
            else
            if(shape == "disk")
            {
                // Need to take into accound squashed proportions
                // XXX
                // Maybe just ignore them
                uniform float r = xlen * .5;
                m_lightColor /= (r * r) * PI ; 
            }
            else
            if(shape == "sphere") 
            {
                // XXX check me
                uniform float r = xlen * .5;
                m_lightColor /= (r * r) * PI * 4 ; 
            }
        }

        if(shape == "distant") 
        {
            //This is really an oriented disk here, but it doesn't
            //really matter since it is distant. 
            m_direction = normalize(vector "shader" (0,0,1));
            m_tangent = normalize(vector "shader" (1,0,0));
            m_bitangent = normalize(vector "shader" (0,1,0));

            uniform float clampedAngVis = radians(max(.1, angularVisibility));
            m_tan = tan(clampedAngVis);
            m_angularSpread = cos(clampedAngVis);
            uniform float solidAngle = M_TWOPI * (1-m_angularSpread); 
            // The lightPdf for the distant light is equal to 1/solid angle
            m_pdf = 1/solidAngle;

            // XXX check this 
            m_lightColor *= m_pdf;
        }
    }

  
    public void prelighting(output color Ci, Oi;)
    {
        // RSLINJECT_light
        string pipelineStage = "";

        // Check to see if the prelighting method is being
        // run to prep the geometric area light. 
        shaderinfo("pipelinestage",pipelineStage);
        if(pipelineStage == "emission") {

            //------------BarnDoors--------------------
            // XXX barnDoorsOffset is only here to facilitate 
            // debugging the use of gobos here. Remove prior to shipping

            string barnMaps[];
            uniform matrix barnMatrix[];
            if(rmsDisplayBarnDoors == 1) 
            {
                // define the barn map
                // XXX for debugging purposes.
                string barnMap = barnDoorMap;
                string barnMap2 = barnDoorMap;
                string barnMap3 = barnDoorMap; 
                string barnMap4 = barnDoorMap; 

                // Left 
                uniform matrix left = matrix "object" 1;
                left = translate(left,vector(0.5, 0, 0));
                left = rotate(left,radians(rmsBarnL),vector(0,1,0));
                left = translate(left,vector(1,0,0));
                push(barnMatrix, left);
                push(barnMaps, barnMap);

                //Right
                uniform matrix right = matrix "object" 1;
                right = rotate(right,radians(180),vector(0,0,1));
                right = translate(right,vector(0.5, 0, 0));//Positional offset
                right = rotate(right,radians(rmsBarnR),vector(0,1,0));
                right = translate(right,vector(1,0,0));
                push(barnMatrix, right);
                push(barnMaps, barnMap2);

                // Top 
                uniform matrix top = matrix "object" 1;
                top = rotate(top,radians(90),vector(0,0,1));
                top = translate(top,vector(0.5, 0, 0));
                top = rotate(top,radians(rmsBarnT),vector(0,1,0));
                top = translate(top,vector(1,0,0));
                push(barnMatrix, top);
                push(barnMaps, barnMap3);

                // Bottom 
                uniform matrix bottom = matrix "object" 1;
                bottom = rotate(bottom,radians(270),vector(0,0,1));
                bottom = translate(bottom,vector(0.5, 0, 0));
                bottom = rotate(bottom,radians(rmsBarnB),vector(0,1,0));
                bottom = translate(bottom,vector(1,0,0));
                push(barnMatrix, bottom);
                push(barnMaps, barnMap4);

            }

            // Get portals, Gobos and blockers
            string goboMaps[];
            string goboCoordSys[];
            string blockerCoordSys[];
            uniform color blockerDiffMultiplier[];
            uniform color blockerSpecMultiplier[];
            uniform vector blockerShape[];
            string portalCoordSys[];

            GetGeoLightModifiers("geoLightModifier",
                                 goboMaps,
                                 goboCoordSys,
                                 blockerCoordSys,
                                 blockerDiffMultiplier,
                                 blockerSpecMultiplier,
                                  blockerShape,
                                 portalCoordSys);

            string shadownames[];
            if(shadowname != "")
                push(shadownames, shadowname);

            uniform float enableTraceShadows = (traceShadows == 1 
                                                && m_trace != 0) ? 1 : 0; 

            color emission = pow(2,intensity) * lightcolor;

            float computedCosinePower = 1;
            if (distributionAngle < 89.99) {
                computedCosinePower = log(0.00000001) /
                                log(cos(radians(distributionAngle)));
                computedCosinePower = clamp(computedCosinePower * 0.5, 0.0, 409600);
            }
            
            if(temperature != -1)
                emission *= KtoRGB(temperature); 

            if (shadowname == "")
            {
                emit(emission,
                    "raytraceshadow", enableTraceShadows,
                    "cosinepower", computedCosinePower,
                    "subset",subset,
                    "adaptiveshadow", adaptive,
                    "excludesubset",excludesubset,
                    "shadowbias", bias,
                    "areanormalized", areaNormalize,
                    "diffusecontribution",diffAmount,
                    "specularcontribution",specAmount,
                    "portals", portalCoordSys, 
                    "gobo", barnMatrix,
                    "gobomap", barnMaps,
                    "gobo", goboCoordSys, 
                    "gobomap", goboMaps,
                    "blockers", blockerCoordSys,
                    "blockerdiffusemultiplier", blockerDiffMultiplier,
                    "blockerspecularmultiplier", blockerSpecMultiplier,
                    "blockershapes", blockerShape,
                    "shadowtint", shadowColor,
                    "profilemap",profilemap,
                    "iesprofile",iesprofile,
                    "profilespace", "object",
                    "coneangle",(shape != "spot") ? -1 : coneangle,
                    "penumbraangle",(shape != "spot") ? -1 :  penumbraangle,
                    "penumbraexponent" , penumbraexponent,
                    "profilerange", profilerange
                    );
            }
            else
            {
                emit(emission,
                    "cosinepower", computedCosinePower,
                    "shadowbias", bias,
                    "shadowmapbias", mapbias,
                    "shadowmapbias2", mapbias2,
                    "shadowmaps", shadownames,
                    "raytraceshadow", enableTraceShadows,
                    "adaptiveshadow", adaptive,
                    "subset", subset,
                    "excludesubset", excludesubset,
                    "areanormalized", areaNormalize,
                    "diffusecontribution",diffAmount,
                    "specularcontribution",specAmount,
                    "portals", portalCoordSys, 
                    "gobo", barnMatrix,
                    "gobomap", barnMaps,
                    "gobo", goboCoordSys, 
                    "gobomap", goboMaps,
                    "blockers", blockerCoordSys,
                    "blockerdiffusemultiplier", blockerDiffMultiplier,
                    "blockerspecularmultiplier", blockerSpecMultiplier,
                    "blockershape", blockerShape,
                    "shadowtint", shadowColor,
                    "profilemap",profilemap,
                    "iesprofile",iesprofile,
                    "profilespace", "object",
                    "coneangle",(shape != "spot") ? -1 : coneangle,
                    "penumbraangle",(shape != "spot") ? -1 :  penumbraangle,
                    "penumbraexponent" , penumbraexponent,
                    "profilerange", profilerange
                    );
            }
        }
    }

    public void surface(output color Ci, Oi)
    {
        Ci = m_lightColor;
        Oi = 1;
    }


}
