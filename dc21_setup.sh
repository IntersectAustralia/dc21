export DC21_HOST=localhost DC21_DB_PWD=dc21_test DC21_AAF_TEST=true DC21_TAG=snap-deploy PASSWORD="FT^yhu8ik" JOAI="Pass123" FIRST_NAME="John" LAST_NAME="Smith" EMAIL="admin@intersect.org.au" USER_PASS="Pass.123" YES_NO="yes"
/usr/bin/expect -<<EOD
spawn bash <(curl -s https://raw.github.com/IntersectAustralia/dc21/snap-deploy/vm_setup.sh)

expect -re " password for devel:"
send "$password\r"

expect "Password: "
send "$password\r"

expect "New jOAI password (at least six alphanumeric characters):"
send "$JOAI\r"

expect "Confirm password: "
send "$JOAI\r"

expect "First name:"
send "$first_name\r"

expect "Last name:"
send "$last_name\r"

expect "Email:"
send "$email\r"

expect "New user password (input will be hidden): "
send "$user_pass\r"

expect "Confirm password: "
send "$user_pass\r"

expect "Is this okay?"
send "$yes_no\r"

expect -re " password for devel:"
send "$password\r"
interact
EOD