KAJAR := ~/Programs/KickAssembler/KickAss.jar
KICKASS := java -jar $(KAJAR)

.PHONY: clean

supermon64.prg: relocate.prg supermon64-8000.prg supermon64-C000.prg
	./build.py $^ $@

supermon64-8000.prg: supermon64.asm
	$(KICKASS) -o $@ -define LOWORG $<

supermon64-C000.prg: supermon64.asm
	$(KICKASS) -o $@ $<

relocate.prg: relocate.asm
	$(KICKASS) -o $@ $<

clean:
	rm -f *.prg
