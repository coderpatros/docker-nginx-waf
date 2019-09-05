#!/usr/bin/env bash
total=0
failed=0
passed=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function timestamp {
  date +"%T"
}

function single_test {
    current_timestamp=$(date +%s%N)
    url="http://nginx?t=${current_timestamp}" #DevSkim: ignore DS137138
    content=$(wget $url -q -O -)
    if [[ $content == *"Welcome to nginx!"* ]]; then
        ((passed++))
    else
        ((failed++))
    fi
    ((total++))
}

end=$((SECONDS+60))

while [ $SECONDS -lt $end ]; do
    single_test
done

if [ $failed -eq 0 ]; then
    echo -n -e "$GREEN"
else
    echo -n -e "$RED"
fi
echo -n "PASSED: $passed | FAILED: $failed | TOTAL: $total"
echo -e "$NC"

exit $failed