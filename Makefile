.PHONY: all clean newproj

MODULES += demo

TOP_DIR   = $(PWD)
BUILD_DIR = $(TOP_DIR)/build
DIST_DIR  = $(TOP_DIR)/out
PROJ_DIR  = $(TOP_DIR)/projects

SUB_BUILD = $(addprefix $(BUILD_DIR)/, $(MODULES))
SLIDE_PDF = $(addsuffix /slide.pdf, $(SUB_BUILD))

ifndef M
	M = newproj
endif

all: $(SUB_BUILD) $(SLIDE_PDF)

$(SUB_BUILD):
	mkdir -p $@
	ln -s $(PROJ_DIR)/$(notdir $@)/figures $@/figures

$(DIST_DIR):
	mkdir -p $@

#.SECONDEXPANSION:
$(BUILD_DIR)/%.tex: $(PROJ_DIR)/%.md
	pandoc -t beamer --slide-level 2 $< -o $@

$(BUILD_DIR)/%/title.tex: $(PROJ_DIR)/%/title.tex
	cp $< $@

$(BUILD_DIR)/%/slide.tex: template/slide.tex
	cp $< $@

%/slide.pdf: $(DIST_DIR) %/slide.tex %/title.tex %/content.tex
	cd $(dir $@) && \
		xelatex slide.tex && \
		xelatex slide.tex && \
		sed -n -e '/\\title{.\+}/p' title.tex | \
	   	sed -e 's,\\title{,"$(DIST_DIR)/,g' -e 's/}/.pdf"/g' | \
		xargs cp -v slide.pdf

clean:
	@echo "remove $(BUILD_DIR)"
	@rm -rf $(BUILD_DIR)

newproj:
	@mkdir -p $(PROJ_DIR)/$(M)/figures
	@cp template/title.tex $(PROJ_DIR)/$(M)/title.tex
	@touch $(PROJ_DIR)/$(M)/content.md
	@echo "Create new project: $(PROJ_DIR)/$(M)"

