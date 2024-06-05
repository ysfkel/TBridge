
# Define the target
.PHONY: deploy

# Detect the operating system and set the appropriate shell command
ifeq ($(OS), Windows_NT)
    RUN_SCRIPT := cmd /c dev.sh
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S), Linux)
        RUN_SCRIPT := ./deploy/dev.sh
    endif
    ifeq ($(UNAME_S), Darwin)
        RUN_SCRIPT := ./deploy/dev.sh
    endif
endif

# Define the command to run the shell script
deploy:
	$(RUN_SCRIPT)