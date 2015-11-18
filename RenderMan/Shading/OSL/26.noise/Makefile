
RENDER=render
SLCOMPILER=oslc
VIEWER=sho
SLEXT=oso

SHADERNAME=wood

all: ${SHADERNAME}.${SLEXT} test.rib
	cat test.rib | sed s/XXXX/${SHADERNAME}/g | ${RENDER}

${SHADERNAME}.${SLEXT} : ${SHADERNAME}.osl
	${SLCOMPILER} ${SHADERNAME}.osl

clean :
	rm -f *.tiff *.oso
