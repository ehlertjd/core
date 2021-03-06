## Run the tests

### Ubuntu
Run automated tests:
```
# Follow installation instructions in README first
. /runtime/bin/activate # Or wherever your scitran virtualenv is
./test/bin/setup-integration-tests-ubuntu.sh
./test/bin/run-tests-ubuntu.sh
```
All tests are executed by default. Subsets can be run using the filtering options:

* To run linting, use `--lint` (`-l`)
* To run unit tests, use `--unit` (`-u`)
* To run integration tests, use `--integ` (`-i`)
* To run abao tests, use `--abao` (`-a`)
* To pass any arguments to `py.test`, use `-- PYTEST_ARGS`

See [py.test usage](https://docs.pytest.org/en/latest/usage.html) for more.

### Docker
Build scitran-core image and run automated tests in a docker container:
```
./tests/bin/run-tests-docker.sh
```
* To skip building the image, use `--no-build` (`-B`)
* To pass any arguments to `run-tests-ubuntu.sh`, use `-- TEST_ARGS`


#### Example
Without rebuilding the image, run only integration tests matching `foo`, use the highest verbosity level for test output and jump into a python debugger session in case an assertion fails:
```
./tests/bin/run-tests-docker.sh -B -- -i -- -k foo -vvv --pdb
```

**NOTE:** The mongodb version is pinned via the `MONGO_VERSION` variable in `tests/bin/run-tests-docker.sh`.

### Tools
- [abao](https://github.com/cybertk/abao/)

### Testing API against RAML with Abao
Abao is one of the testing tools run during our TravisCI build.  It tests the API implementation against what’s defined in the RAML spec.  Adding a new resource / url to the RAML spec will cause Abao to verify that resource during integration tests.  Sometimes abao cannot properly test a resource (file field uploads) or a test may require chaining variable.  Abao has before and after hooks for tests, written in javascript.  These can be used to skip a test, inject variables into the request, or make extra assertions about the response.  See tests/integration/abao in the repo for the hooks file.  See [abao github readme](https://github.com/cybertk/abao/blob/master/README.md) for more information on how to use hooks.

Abao tests can depend on specific resources (eg. group, project, session, etc.) pre-existing in the DB. That resource loading should be maintained within `tests/integration_tests/abao/load_fixture.py` and is executed automatically via the integration test scripts at `test/bin`.
