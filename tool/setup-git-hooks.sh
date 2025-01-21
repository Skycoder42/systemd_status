#!/bin/bash
set -eo pipefail

mkdir -p .git/hooks

cat << EOF > .git/hooks/pre-commit
#!/bin/bash
set -eo pipefail

echo '=== Checking server ==='
pushd server > /dev/null
dart run dart_pre_commit
popd > /dev/null

echo '=== Checking client ==='
pushd client > /dev/null
dart run dart_pre_commit
popd > /dev/null
EOF
chmod a+x .git/hooks/pre-commit
