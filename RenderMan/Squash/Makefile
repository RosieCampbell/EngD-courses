RENDER=render
SLCOMPILER=oslc
VIEWER=sho
SLEXT=oso

SHADERNAME=pumpkinSurface

all: ${SHADERNAME}.${SLEXT} pumpkin.rib
	cat pumpkin.rib | sed s/XXXX/${SHADERNAME}/g | ${RENDER}

${SHADERNAME}.${SLEXT} : ${SHADERNAME}.osl
	${SLCOMPILER} ${SHADERNAME}.osl

clean :
	rm -f *.tiff *.oso
