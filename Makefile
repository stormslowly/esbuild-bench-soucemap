# Rome benchmark (measures TypeScript performance)

ROME_TSCONFIG += {
ROME_TSCONFIG +=   \"compilerOptions\": {
ROME_TSCONFIG +=     \"sourceMap\": true,
ROME_TSCONFIG +=     \"esModuleInterop\": true,
ROME_TSCONFIG +=     \"resolveJsonModule\": true,
ROME_TSCONFIG +=     \"moduleResolution\": \"node\",
ROME_TSCONFIG +=     \"target\": \"es2019\",
ROME_TSCONFIG +=     \"module\": \"commonjs\",
ROME_TSCONFIG +=     \"baseUrl\": \".\"
ROME_TSCONFIG +=   }
ROME_TSCONFIG += }

github/rome:
	mkdir -p github/rome
	cd github/rome && git init && git remote add origin https://github.com/romejs/rome.git
	cd github/rome && git fetch --depth 1 origin d95a3a7aab90773c9b36d9c82a08c8c4c6b68aa5 && git checkout FETCH_HEAD

bench/rome-verify: github/rome
	mkdir -p bench/rome-verify
	cp -r github/rome/packages bench/rome-verify/packages
	cp github/rome/package.json bench/rome-verify/package.json


.PHONY:bench-sourcemap
bench-sourcemap: bench/rome bench/rome-verify
	rm -fr bench/rome/esbuild
	echo Done with bench-sourcemap\n
	time -p ./node_modules/.bin/esbuild --bundle --sourcemap --minify bench/rome/src/entry.ts --outfile=bench/rome/esbuild/rome.esbuild.js --platform=node --timing
	time -p ./node_modules/.bin/esbuild --bundle --sourcemap --minify bench/rome/src/entry.ts --outfile=bench/rome/esbuild/rome.esbuild.js --platform=node --timing
	time -p ./node_modules/.bin/esbuild --bundle --sourcemap --minify bench/rome/src/entry.ts --outfile=bench/rome/esbuild/rome.esbuild.js --platform=node --timing
	du -h bench/rome/esbuild/rome.esbuild.js*
	shasum bench/rome/esbuild/rome.esbuild.js*
	cd bench/rome-verify && rm -fr esbuild

.PHONY: bench-no-sourcemap
bench-no-sourcemap: bench/rome bench/rome-verify
	rm -fr bench/rome/esbuild
	echo Done bench-no-sourcemap\n
	time -p ./node_modules/.bin/esbuild --bundle --sources-content=false --minify bench/rome/src/entry.ts --outfile=bench/rome/esbuild/rome.esbuild.js --platform=node --timing
	time -p ./node_modules/.bin/esbuild --bundle --sources-content=false --minify bench/rome/src/entry.ts --outfile=bench/rome/esbuild/rome.esbuild.js --platform=node --timing
	time -p ./node_modules/.bin/esbuild --bundle --sources-content=false --minify bench/rome/src/entry.ts --outfile=bench/rome/esbuild/rome.esbuild.js --platform=node --timing
	du -h bench/rome/esbuild/rome.esbuild.js*
	shasum bench/rome/esbuild/rome.esbuild.js*
	cd bench/rome-verify && rm -fr esbuild

.PHONY: all
all: bench-no-sourcemap bench-sourcemap

.PHONY: clean
clean:
	rm -rf bench github

bench/rome: github/rome
	mkdir -p bench/rome
	cp -r github/rome/packages bench/rome/src
	echo "$(ROME_TSCONFIG)" > bench/rome/src/tsconfig.json
	echo 'import "rome/bin/rome"' > bench/rome/src/entry.ts

	# Patch a cyclic import ordering issue that affects commonjs-style bundlers (webpack and parcel)
	echo "export { default as createHook } from './api/createHook';" > .temp
	sed "/createHook/d" bench/rome/src/@romejs/js-compiler/index.ts >> .temp
	mv .temp bench/rome/src/@romejs/js-compiler/index.ts

	# Replace "import fs = require('fs')" with "const fs = require('fs')" because
	# the TypeScript compiler strips these statements when targeting "esnext",
	# which breaks Parcel 2 when scope hoisting is enabled.
	find bench/rome/src -name '*.ts' -type f -print0 | xargs -L1 -0 sed -i '' 's/import \([A-Za-z0-9_]*\) =/const \1 =/g'
	find bench/rome/src -name '*.tsx' -type f -print0 | xargs -L1 -0 sed -i '' 's/import \([A-Za-z0-9_]*\) =/const \1 =/g'

	# Get an approximate line count
	rm -r bench/rome/src/@romejs/js-parser/test-fixtures
	echo 'Line count:' && (find bench/rome/src -name '*.ts' && find bench/rome/src -name '*.js') | xargs wc -l | tail -n 1

