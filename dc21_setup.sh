export DC21_HOST=localhost DC21_DB_PWD=dc21_test DC21_AAF_TEST=true DC21_TAG=snap-deploy PASSWORD="FT^yhu8ik" JOAI="Pass123" FIRST_NAME="John" LAST_NAME="Smith" EMAIL="admin@intersect.org.au" USER_PASS="Pass.123" YES_NO="yes"
wget https://raw.github.com/IntersectAustralia/dc21/snap-deploy/vm_setup.sh
/usr/bin/expect -<<EOD
spawn bash vm_setup.sh

expect -re -timeout -1 " password for devel:"
send "$PASSWORD\r"

expect -ex -timeout -1 "Password: "
send "$PASSWORD\r"

expect -ex -timeout -1 "New jOAI password (at least six alphanumeric characters):"
send "$JOAI\r"

expect -ex -timeout -1 "Confirm password: "
send "$JOAI\r"

expect -ex -timeout -1 "First name:"
send "$FIRST_NAME\r"

expect -ex -timeout -1 "Last name:"
send "$LAST_NAME\r"

expect -ex -timeout -1 "Email:"
send "$EMAIL\r"

expect -ex -timeout -1 "New user password (input will be hidden): "
send "$USER_PASS\r"

expect -ex -timeout -1 "Confirm password: "
send "$USER_PASS\r"

expect -ex -timeout -1 "Is this okay?"
send "$YES_NO\r"

expect -re -timeout -1 " password for devel:"
send "$PASSWORD\r"

interact
EOD