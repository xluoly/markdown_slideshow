.PHONY: all clean create

MODULES += demo
MODULES += writing_with_markdown
MODULES += svn_introduction
MODULES += git_quick_start
MODULES += git_commands
MODULES += gitlab_workflow
MODULES += makefile_introduction
MODULES += video_broken_issue
MODULES += android_camera_api2

TOP_DIR   = $(PWD)
BUILD_DIR = $(TOP_DIR)/build
DIST_DIR  = $(TOP_DIR)/out
PROJ_DIR  = $(TOP_DIR)/projects

SUB_BUILD = $(addprefix $(BUILD_DIR)/, $(MODULES))
SLIDE_PDF = $(addsuffix /slide.pdf, $(SUB_BUILD))

ifeq ("$(origin M)", "command line")
    MODULES := $(M)
endif

ifeq ("$(origin P)", "command line")
    PROJECT = $(P)
else
    PROJECT = new_project_name
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

create:
	@mkdir -p $(PROJ_DIR)/$(PROJECT)/figures
	@cp template/title.tex $(PROJ_DIR)/$(PROJECT)/title.tex
	@touch $(PROJ_DIR)/$(PROJECT)/content.md
	@echo "project created:\n\t$(PROJ_DIR)/$(PROJECT)"

