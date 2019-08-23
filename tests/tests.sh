#!/usr/bin/env bash
total=0
failed=0
passed=0

echo -n "Sending a normal request should succeed... "
content=$(wget http://nginx-waf-defaults -q -O -)
if [[ $content == *"Welcome to nginx!"* ]]; then
    echo "PASSED"
    ((passed++))
else
    echo "FAILED"
    ((failed++))
fi
((total++))

echo -n "Sending a dodgy request should be forbidden... "
# using integer overflow attack
response=$(curl --write-out %{http_code} --silent --output /dev/null http://nginx-waf-defaults?arg=2147483648)
if [ "403" = "$response" ]; then
    echo "PASSED"
    ((passed++))
else
    echo "FAILED"
    ((failed++))
fi
((total++))



echo -n "Sending a normal request should succeed when in DetectionOnly mode... "
content=$(wget http://nginx-waf-detectiononly -q -O -)
if [[ $content == *"Welcome to nginx!"* ]]; then
    echo "PASSED"
    ((passed++))
else
    echo "FAILED"
    ((failed++))
fi
((total++))

echo -n "Sending a dodgy request should be succeed when in DetectionOnly mode... "
# using integer overflow attack
content=$(wget http://nginx-waf-detectiononly?arg=2147483648 -q -O -)
if [[ $content == *"Welcome to nginx!"* ]]; then
    echo "PASSED"
    ((passed++))
else
    echo "FAILED"
    ((failed++))
fi
((total++))

echo
echo "PASSED: $passed | FAILED: $failed | TOTAL: $total"
exit $failed