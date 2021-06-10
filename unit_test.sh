
# Deploy ephemeral db
source $CICD_ROOT/deploy_ephemeral_db.sh

# Map env vars set by `deploy_ephemeral_db.sh` if vars the app uses are different
export PGPASSWORD=$DATABASE_ADMIN_PASSWORD

# check if NAMESPACE is set
[ -z "$NAMESPACE" ] && exit 1
oc get secret rbac -o json -n $NAMESPACE


python3 -m venv app-venv
. app-venv/bin/activate
pip install --upgrade pip setuptools wheel pipenv tox psycopg2-binary
pip install crc-bonfire==v1.4.0b0
tox -r
result=$?
source .bonfire_venv/bin/activate

# TODO: add unittest-xml-reporting to rbac so that junit results can be parsed by jenkins
mkdir -p $WORKSPACE/artifacts
cat << EOF > $WORKSPACE/artifacts/junit-dummy.xml
<testsuite tests="1">
    <testcase classname="dummy" name="dummytest"/>
</testsuite>
EOF
