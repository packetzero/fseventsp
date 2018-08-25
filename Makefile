all: src/fseventsp.cr
	mkdir -p ./bin
	crystal build --release -o bin/fseventsp src/fseventsp.cr
	#crystal build -o bin/fseventsp_debug src/fseventsp.cr

clean:
	rm -rf ./bin
