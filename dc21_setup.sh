wget https://raw.github.com/IntersectAustralia/dc21/snap-deploy/vm_setup.sh
/usr/bin/expect -<<EOD
set timeout -1
spawn bash vm_setup.sh

expect -re " password for devel:"
send "$PASSWORD\r"

expect -re " password for devel:"
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

expect -ex "Country Name (2 letter code) \[XX\]:"
send "$SSL_COUNTRY_CODE\r"

expect -ex "State or Province Name (full name) \[\]:"
send "$SSL_STATE_CODE\r"

expect -ex "Locality Name (eg, city) \[Default City\]:"
send "$SSL_CITY\r"

expect -ex "Organization Name (eg, company) \[Default Company Ltd\]:"
send "$SSL_ORGANIZATION_NAME\r"

expect -ex "Organizational Unit Name (eg, section) \[\]:"
send "$SSL_ORGANIZATION_UNIT_NAME\r"

expect -ex "Common Name (eg, your name or your server's hostname) \[\]:"
send "$DC21_HOST\r"

expect -ex "Email Address \[\]:"
send "$SSL_EMAIL\r"

expect

EOD