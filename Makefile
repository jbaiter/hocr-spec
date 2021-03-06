VERSION := 1.2

SPEC_BIBLIO = biblio.json
SPEC_BEFORE = $(VERSION)/spec.before.html
SPEC_AFTER = $(VERSION)/spec.after.html
SPEC_MD = $(VERSION)/spec.md
SPEC_BS = $(VERSION)/index.bs
SPEC_HTML = $(VERSION)/index.html

BIKESHED = $(shell for cmd in bikeshed docker;do type >/dev/null 2>&1 $$cmd && echo $$cmd && break;done)
BIKESHED_ARGS = -f
BIKESHED_SPEC_ARGS =

SPEC_DEFS = $(VERSION)/include/defs/bbox
SPEC_DEFS_YML = $(VERSION)/defs.yml
SPEC_DEFS_TEMPLATES = $(shell find $(VERSION)/templates/ -type f)
GEN_DEFS = python3 gen-defs.py

$(SPEC_HTML): $(SPEC_BS)
	@case "$(BIKESHED)" in \
		bikeshed) bikeshed $(BIKESHED_ARGS) spec $(BIKESHED_SPEC_ARGS) $(SPEC_BS) ;; \
		docker)   docker run --rm -it -v $(PWD):/data kbai/bikeshed $(BIKESHED_ARGS) spec $(BIKESHED_SPEC_ARGS) $(SPEC_BS) ;; \
		*)        echo 'Unsupported bikeshed backend "$(BIKESHED)"'; exit 1 ;; esac
	@rm -f $(SPEC_BS)

$(SPEC_BS): $(SPEC_BEFORE) $(SPEC_MD) $(SPEC_BIBLIO) $(SPEC_AFTER) $(SPEC_DEFS)
	@echo 'Rebuilding spec...'
	@cat  $(SPEC_BEFORE)           > $(SPEC_BS)
	@echo '<pre class="biblio">'   >> $(SPEC_BS)
	@cat  $(SPEC_BIBLIO)           >> $(SPEC_BS)
	@echo '</pre>'                 >> $(SPEC_BS)
	@cat  $(SPEC_MD) $(SPEC_AFTER) >> $(SPEC_BS)

$(SPEC_DEFS): $(SPEC_DEFS_YML) $(SPEC_DEFS_TEMPLATES)
	@$(GEN_DEFS) --basepath $(VERSION)

clean:
	$(RM) $(SPEC_HTML) $(SPEC_BS)
