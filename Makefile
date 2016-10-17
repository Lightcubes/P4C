VPATH=src:

Group0_SRC = \
    p4c.c 

Group0_DEP = $(patsubst %.c, deps.$(CFG)/Group0_%.d, ${Group0_SRC})
Group0_OBJ = $(patsubst %.c, objs.$(CFG)/Group0_%.o, ${Group0_SRC})

TARGET=p4c

CCDEP = gcc 

INCLUDEFLAGS= -I include -I src

ifeq ($(CFG),debug)
CCFLAGS += -pthread -lrt -Wall -D_DEBUG ${INCLUDEFLAGS}
else
CCFLAGS += -pthread -lrt -O2 -Wall ${INCLUDEFLAGS}
endif


all:	inform bin.$(CFG)/${TARGET}

inform:
ifneq ($(CFG),release)
ifneq ($(CFG),debug)
	@echo "Invalid configuration "$(CFG)" specified."
	@echo "You must specify a configuration when running make, e.g."
	@echo  "make CFG=debug"
	@echo  
	@echo  "Possible choices for configuration are 'release' and 'debug'"
	@exit 1
endif
endif
	@echo "Configuration "$(CFG)
	@echo "------------------------"

bin.$(CFG)/${TARGET}: ${Group0_OBJ} | inform
	@mkdir -p $(dir $@)
	$(CC) -g -o $@ $^ ${CCFLAGS}

objs.$(CFG)/Group0_%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -c $(CCFLAGS) -o $@ $<

deps.$(CFG)/Group0_%.d: %.c
	@mkdir -p $(dir $@)
	@echo Generating dependencies for $<
	@set -e ; $(CCDEP) -MM -MP $(INCLUDEFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,objs.$(CFG)\/Group0_\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

clean:
	@rm -rf \
	deps.debug objs.debug bin.debug \
	deps.release objs.release bin.release

ifneq ($(MAKECMDGOALS),clean)
-include ${Group0_DEP}
endif
