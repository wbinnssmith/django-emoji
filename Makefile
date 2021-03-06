KARMA=$(CURDIR)/node_modules/karma/bin/karma
BOWER=$(CURDIR)/node_modules/.bin/bower

.PHONY : test clean test-py test-js coverage coverage-py coverage-js coverage-py-html default

default: coverage

test-py:
	tox

test-js: node_modules
	$(KARMA) start test/karma.conf.js --single-run \
		--reporters dots --browsers PhantomJS

test: test-js test-py

node_modules: package.json test/bower.json
	npm install
	cd test && \
		$(BOWER) install --config.interactive=false

coverage: coverage-js coverage-py

coverage-py:
	coverage run test/runtests.py --with-xunit && \
		coverage xml --omit="admin.py,*.virtualenvs/*,./test/*"

coverage-js: node_modules
	$(PHANTOMJS) -R xunit test/tests.html > mochatests.xml

coverage-py-html:
	[ -d htmlcov ] || rm -rf htmlcov
	coverage run test/runtests.py && \
		coverage html --omit="admin.py,*.virtualenvs/*,./test/*"

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info

clean: clean-pyc clean-build

lint-rst:
	pip install restructuredtext_lint
	rst-lint README.rst

upload-package: test lint-rst clean
	pip install twine wheel
	python setup.py sdist
	python setup.py bdist_wheel
	twine upload dist/*
