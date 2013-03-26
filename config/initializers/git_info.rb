GIT_BRANCH = `git status | sed -n 1p`.split(" ").last
GIT_COMMIT = `git log | sed -n 1p`.split(" ").last
GIT_LATEST_TAG = `git tag | xargs -I@ git log --format=format:"%ci %h @%n" -1 @ | sort | sed -n '$p'`.split(" ").last