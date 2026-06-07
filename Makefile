SRC_DIR := ./src
BUILD_DIR := ./build
#These are all the functions your main program wants to call. Right now it is set to every function defined by CobDOMinate.
COBOL_CALLED = 
COBOL_CALLED_COBC = $(foreach n,$(COBOL_CALLED),-K $(n))
#These are all the functions your main program wants to expose.
COBOL_EXPORTS = MAIN 
COBOL_EXPORTS_COBC = $(foreach n,$(COBOL_EXPORTS),-K $(n))
#Your COBOL entrypoint is added here
COBOL_EXPORTS_EMCC = $(shell printf "_%s\n" $(COBOL_EXPORTS) | paste -sd, -)

all: $(BUILD_DIR)/web/main.js $(BUILD_DIR)/web

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/web: $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/web

$(BUILD_DIR)/main.c: $(BUILD_DIR)
	cobc -F -C -o $@ $(SRC_DIR)/main.cob $(COBOL_CALLED_COBC) $(COBOL_EXPORTS_COBC)

$(BUILD_DIR)/web/main.js: $(BUILD_DIR)/main.c $(BUILD_DIR)/web
	emcc -o $@ $< -lgmp -lcob -lcobdom -s EXPORTED_FUNCTIONS=_malloc,_free,_cob_init,$(COBOL_EXPORTS_EMCC) -s EXPORTED_RUNTIME_METHODS=ccall,cwrap,HEAP8 -Wno-deprecated-non-prototype

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
