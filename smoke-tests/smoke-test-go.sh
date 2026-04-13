#!/bin/bash
# Usage: ./smoke-test-go.sh <image-name>
# Example: ./smoke-test-go.sh kenzman/ns-wolfi-go:latest

if [ -z "$1" ]; then
    echo "Usage: $0 <image-name>"
    echo "Example: $0 kenzman/ns-wolfi-go:latest"
    exit 1
fi

IMAGE="$1"

echo "🔵 Starting Go Smoke Test for $IMAGE..."
echo "----------------------------------------"

# 1. Security Check: Non-Root Enforcement
echo -n "[1/4] Checking non-root enforcement... "
ROOT_CHECK=$(docker run --rm $IMAGE touch /etc/test_file 2>&1)
if [[ $ROOT_CHECK == *"Permission denied"* ]]; then
    echo "✅ PASS (Root access blocked)"
else
    echo "❌ FAIL (Container allowed root-level write!)"
fi

# 2. Functional Check: Go Path and Version
echo -n "[2/4] Verifying Go path and version... "
GO_CHECK=$(docker run --rm $IMAGE go version 2>&1)
if [[ $GO_CHECK == *"go version"* ]]; then
    echo "✅ PASS ($GO_CHECK)"
else
    echo "❌ FAIL (Go not found or execution error)"
fi

# 3. Environment Check: GOPATH
echo -n "[3/4] Validating GOPATH... "
GP_CHECK=$(docker run --rm $IMAGE sh -c 'echo $GOPATH')
if [[ $GP_CHECK == "/home/appuser/go" ]]; then
    echo "✅ PASS (GOPATH is correct)"
else
    echo "❌ FAIL (GOPATH is $GP_CHECK)"
fi

# 4. Footprint Check: Idle Memory
echo -n "[4/4] Measuring idle memory usage... "
CONTAINER_ID=$(docker run -d $IMAGE sleep 5)
MEM_USAGE=$(docker stats --no-stream --format "{{.MemUsage}}" $CONTAINER_ID)
docker rm -f $CONTAINER_ID > /dev/null
echo "📊 $MEM_USAGE (Benchmark complete)"

echo "----------------------------------------"
echo "🚀 Go Smoke Test Finished."
