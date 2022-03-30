VERSION=$(cat package.json | json version )
IFS='.' 
read -a TOKENS <<< "$VERSION"
v="$VERSION"
UPDATE=$(expr ${TOKENS[3]} + 1) 
IFS=''
NEW_VERSION="${TOKENS[0]}.${TOKENS[1]}.${TOKENS[2]}.$UPDATE"
json -I -f package.json -e "this.version=\"$NEW_VERSION\""