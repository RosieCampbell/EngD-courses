RENDER=render
SLCOMPILER=oslc
VIEWER=sho
SLEXT=oso

SHADERNAME=urchinPattern

all: ${SHADERNAME}.${SLEXT} urchin.rib
	cat urchin.rib | sed s/XXXX/${SHADERNAME}/g | ${RENDER}

${SHADERNAME}.${SLEXT} : ${SHADERNAME}.osl
	${SLCOMPILER} ${SHADERNAME}.osl

clean :
	rm -f *.tiff *.oso
