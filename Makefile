all: src/fseventsp.cr src/fse2tsv.cr
	mkdir -p ./bin
	crystal build --release -o bin/fseventsp src/fseventsp.cr
	crystal build -o bin/fse2tsv src/fse2tsv.cr

clean:
	rm -rf ./bin
