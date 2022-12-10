clean:
	rm -rf dist
	rm -rf dist_package
	rm -rf build
	rm -f cumulus-message-adapter.zip

dist:
	mkdir -p dist/cma_bin

requirements: dist requirements.txt
	pip install -r requirements.txt --target ./dist/
	find ./dist -type d -name '__pycache__' | xargs rm -rf
	find ./dist/botocore/data -mindepth 1 -maxdepth 1 -type d |\
		egrep -v '(stepfunctions|s3)' |\
		xargs rm -rf
	rm -rf dist/docutils

packaged_runtime: requirements
	pip install -r requirements-dev.txt
	cp __main__.py ./dist/
	pyinstaller --distpath dist_package --clean -n cma ./dist/__main__.py

cumulus-message-adapter.zip: requirements packaged_runtime
	cp __main__.py ./dist/
	cp -R message_adapter ./dist/
	cp -R ./dist_package/cma/* ./dist/cma_bin
	(cd dist && zip -r -9 ../cumulus-message-adapter.zip .)
