wget https://raw.github.com/IntersectAustralia/dc21/snap-deploy/vm_setup.sh
/usr/bin/expect -<<EOD
set timeout -1
spawn bash vm_setup.sh

expect -re " password for devel:"
send "$PASSWORD\r"

expect -ex "Password: "
send "$PASSWORD\r"

expect -ex "New jOAI password (at least six alphanumeric characters):"
send "$JOAI\r"

expect -ex "Confirm password: "
send "$JOAI\r"

expect -ex "First name:"
send "$FIRST_NAME\r"

expect -ex "Last name:"
send "$LAST_NAME\r"

expect -ex "Email:"
send "$EMAIL\r"

expect -ex "New user password (input will be hidden): "
send "$USER_PASS\r"

expect -ex "Confirm password: "
send "$USER_PASS\r"

expect -ex "Is this okay?"
send "$YES_NO\r"

expect -re " password for devel:"
send "$PASSWORD\r"

expect

EOD