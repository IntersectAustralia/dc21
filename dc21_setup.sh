export DC21_HOST=localhost DC21_DB_PWD=dc21_test DC21_AAF_TEST=true DC21_TAG=snap-deploy PASSWORD="FT^yhu8ik" JOAI="Pass123" FIRST_NAME="John" LAST_NAME="Smith" EMAIL="admin@intersect.org.au" USER_PASS="Pass.123" YES_NO="yes"
wget https://raw.github.com/IntersectAustralia/dc21/snap-deploy/vm_setup.sh
/usr/bin/expect -<<EOD
spawn bash vm_setup.sh

expect -re " password for devel:"
send "$PASSWORD\r"

expect "Password: "
send "$PASSWORD\r"

expect "New jOAI password (at least six alphanumeric characters):"
send "$JOAI\r"

expect "Confirm password: "
send "$JOAI\r"

expect "First name:"
send "$FIRST_NAME\r"

expect "Last name:"
send "$LAST_NAME\r"

expect "Email:"
send "$EMAIL\r"

expect "New user password (input will be hidden): "
send "$USER_PASS\r"

expect "Confirm password: "
send "$USER_PASS\r"

expect "Is this okay?"
send "$YES_NO\r"

expect -re " password for devel:"
send "$PASSWORD\r"

expect
interact
EOD