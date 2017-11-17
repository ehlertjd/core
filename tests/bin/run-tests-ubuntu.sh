#!/usr/bin/env sh

set -eu
unset CDPATH
cd "$( dirname "$0" )/../.."


usage() {
cat >&2 <<EOF
Run scitran-core tests

Usage:
    $0 [OPTION...]

Runs linting and all tests if no options are provided.
Runs subset of tests when using the filtering options.
Displays coverage report if all tests ran and passed.

Options:
    -l, --lint           Run linting
    -u, --unit           Run unit tests
    -i, --integ          Run integration tests
    -a, --abao           Run abao tests
    -h, --help           Print this help and exit
    -- PYTEST_ARGS       Arguments passed to py.test

Envvars:
    SCITRAN_PERSISTENT_DB_PORT    (9001)
    SCITRAN_PERSISTENT_DB_URI     (mongodb://localhost:9001/scitran)
    SCITRAN_PERSISTENT_DB_LOG_URI (mongodb://localhost:9001/logs)

Assumes mongo db instance is accessible at localhost, unless
SCITRAN_PERSISTENT_DB_URI or SCITRAN_PERSISTENT_DB_LOG_URI specify otherwise.

EOF
}


main() {
    export RUN_ALL=true
    local RUN_LINT=false
    local RUN_UNIT=false
    local RUN_INTEG=false
    local RUN_ABAO=false
    local PYTEST_ARGS=

    while [ $# -gt 0 ]; do
        case "$1" in
            -l|--lint)      RUN_ALL=false; RUN_LINT=true      ;;
            -u|--unit)      RUN_ALL=false; RUN_UNIT=true      ;;
            -i|--integ)     RUN_ALL=false; RUN_INTEG=true     ;;
            -a|--abao)      RUN_ALL=false; RUN_ABAO=true      ;;
            -h|--help)      usage;                     exit 0 ;;
            --)             PYTEST_ARGS="${@:2}";      break  ;;
            *) echo "Invalid argument: $1" >&2; usage; exit 1 ;;
        esac
        shift
    done

    if ${RUN_ALL}; then
        # No filtering options used, run everything by default
        RUN_LINT=true
        RUN_UNIT=true
        RUN_INTEG=true
        RUN_ABAO=true
    elif ${RUN_LINT} && ${RUN_UNIT} && ${RUN_INTEG} && ${RUN_ABAO}; then
        # All filtering options were used, the same as none
        RUN_ALL=true
    fi

    # Remove __pycache__ directories for issue with __file__ attribute due to
    # running the tests on the host creating bytecode files hich have a
    # mismatched __file__ attribute when loaded in docker container
    rm -rf tests/unit_tests/python/__pycache__
    rm -rf tests/integration_tests/python/__pycache__

    export PYTHONPATH="$(pwd)"
    export SCITRAN_SITE_API_URL="http://scitran-core-test-service:8081/api"
    export SCITRAN_PERSISTENT_DB_PORT=${SCITRAN_PERSISTENT_DB_PORT:-"9001"}
    export SCITRAN_PERSISTENT_DB_URI=${SCITRAN_PERSISTENT_DB_URI:-"mongodb://localhost:$SCITRAN_PERSISTENT_DB_PORT/scitran"}
    export SCITRAN_PERSISTENT_DB_LOG_URI=${SCITRAN_PERSISTENT_DB_LOG_URI:-"mongodb://localhost:$SCITRAN_PERSISTENT_DB_PORT/logs"}
    export SCITRAN_PERSISTENT_PATH=`mktemp -d`
    export SCITRAN_PERSISTENT_DATA_PATH="$SCITRAN_PERSISTENT_PATH/data"
    export SCITRAN_CORE_DRONE_SECRET=${SCITRAN_CORE_DRONE_SECRET:-T+27oHSKw+WQqT/rre+iaiIY4vNzav/fPStHqW/Eczk=}

    if ${RUN_LINT}; then
        echo "Running pylint ..."
        # TODO Enable Refactor and Convention reports
        # TODO Move --disable into rc
        pylint --reports=no --disable=C,R,W0312,W0141,W0110 api

        # echo "Running pep8 ..."
        # pep8 --max-line-length=150 --ignore=E402 api
    fi

    if ${RUN_UNIT}; then
        echo "Running unit tests ..."
        rm -f .coverage
        py.test --cov=api --cov-report= tests/unit_tests/python $PYTEST_ARGS
    fi

    if ${RUN_INTEG}; then
        echo "Running integration tests ..."
        py.test tests/integration_tests/python $PYTEST_ARGS
    fi

    if ${RUN_ABAO}; then
        echo "Running abao tests ..."
        # Create resources that Abao relies on
        python tests/integration_tests/abao/load_fixture.py

        # If no VIRTUAL_ENV, make sure /usr/local/bin is in the path
        if [[ -z "${VIRTUAL_ENV:-}" ]]; then
            PATH="/usr/local/bin:$PATH"
            npm install tests/integration_tests
        else
            npm install --global tests/integration_tests
        fi

        PATH="$(npm bin):$PATH"

        # Allow us to require modules from package.json,
        # since abao_test_hooks.js is not being called from the package directory
        integration_test_node_modules="$(pwd)/node_modules/scitran-core-integration-tests/node_modules"

        # Have to change into definitions directory to resolve
        # relative $ref's in the jsonschema's
        pushd raml/schemas/definitions
        NODE_PATH="$integration_test_node_modules" abao ../../api.raml "--server=$SCITRAN_SITE_API_URL" "--hookfiles=../../../tests/integration_tests/abao/abao_test_hooks.js"
        popd
    fi

    if ${RUN_ALL}; then
        echo
        echo "UNIT TEST COVERAGE:"
        coverage report --skip-covered
        echo
        echo "OVERALL COVERAGE:"
        coverage combine
        coverage report --show-missing
        coverage html
    fi
}


main "$@"
