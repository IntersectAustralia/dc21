export DC21_HOST=localhost DC21_DB_PWD=dc21_test DC21_AAF_TEST=true DC21_TAG=snap-deploy PASSWORD="FT^yhu8ik" JOAI="Pass123" FIRST_NAME="John" LAST_NAME="Smith" EMAIL="admin@intersect.org.au" USER_PASS="Pass.123" YES_NO="yes"
wget https://raw.github.com/IntersectAustralia/dc21/snap-deploy/vm_setup.sh
/usr/bin/expect -<<EOD
spawn bash vm_setup.sh

expect -exact -re " password for devel:"
send "$PASSWORD\r"

expect -exact "Password: "
send "$PASSWORD\r"

expect -exact "New jOAI password (at least six alphanumeric characters):"
send "$JOAI\r"

expect -exact "Confirm password: "
send "$JOAI\r"

expect -exact "First name:"
send "$FIRST_NAME\r"

expect -exact "Last name:"
send "$LAST_NAME\r"

expect -exact "Email:"
send "$EMAIL\r"

expect -exact "New user password (input will be hidden): "
send "$USER_PASS\r"

expect -exact "Confirm password: "
send "$USER_PASS\r"

expect -exact "Is this okay?"
send "$YES_NO\r"

expect -exact -re " password for devel:"
send "$PASSWORD\r"

expect -exact
interact
EOD