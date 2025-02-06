#!/bin/bash

# Function to make API calls
test_calculator() {
    local num1=$1
    local num2=$2
    local operation=$3
    local expected=$4
    
    echo "Testing $operation: $num1 $operation $num2 = $expected"
    
    RESULT=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"num1\": $num1, \"num2\": $num2, \"operation\": \"$operation\"}" \
        http://localhost:5050/calculate | jq -r .result)
    
    if [ "$RESULT" = "$expected" ]; then
        echo "✓ Test passed"
        return 0
    else
        echo "✗ Test failed: Expected $expected, got $RESULT"
        return 1
    fi
}

# Wait for application to be ready
echo "Waiting for application to start..."
sleep 5

# Run test cases
echo "Running calculator tests..."

# Test addition
test_calculator 10 5 "add" "15.0" || exit 1

# Test subtraction
test_calculator 10 5 "subtract" "5.0" || exit 1

# Test multiplication
test_calculator 10 5 "multiply" "50.0" || exit 1

# Test division
test_calculator 10 5 "divide" "2.0" || exit 1

# Test power
test_calculator 2 3 "power" "8.0" || exit 1

# Test error cases
echo "Testing error cases..."

# Test division by zero
RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"num1": 10, "num2": 0, "operation": "divide"}' \
    http://localhost:5050/calculate)

if echo "$RESPONSE" | grep -q "Division by zero is not allowed"; then
    echo "✓ Division by zero test passed"
else
    echo "✗ Division by zero test failed"
    exit 1
fi

echo "All tests completed successfully!" 