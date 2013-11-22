export DC21_HOST=localhost DC21_DB_PWD=dc21_test DC21_AAF_TEST=true DC21_TAG=snap-deploy PASSWORD="FT^yhu8ik" JOAI="Pass123" FIRST_NAME="John" LAST_NAME="Smith" EMAIL="admin@intersect.org.au" USER_PASS="Pass.123" YES_NO="yes"
wget https://raw.github.com/IntersectAustralia/dc21/snap-deploy/vm_setup.sh
/usr/bin/expect -<<EOD
spawn bash vm_setup.sh

expect {
    -re " password for devel:" {
        send "$PASSWORD\r"
        exp_continue
    }
    "Password: " {
        send "$PASSWORD\r"
        exp_continue
    }
    "New jOAI password (at least six alphanumeric characters):" {
         send "$JOAI\r"
         exp_continue
    }
    "Confirm password: " {
         send "$JOAI\r"
         exp_continue
    }
    "First name:" {
         send "$FIRST_NAME\r"
         exp_continue
    }
    "Last name:" {
         send "$LAST_NAME\r"
         exp_continue
    }
    "Email:" {
         send "$EMAIL\r"
         exp_continue
    }
    "New user password (input will be hidden): " {
         send "$USER_PASS\r"
         exp_continue
    }
    "Is this okay?" {
         send "YES_NO\r"
         exp_continue
    }
}
EOD