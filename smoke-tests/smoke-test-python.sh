#!/bin/bash
# Usage: ./smoke-test-python.sh <image-name>
# Example: ./smoke-test-python.sh kenzman/ns-wolfi-python:latest

if [ -z "$1" ]; then
    echo "Usage: $0 <image-name>"
    echo "Example: $0 kenzman/ns-wolfi-python:latest"
    exit 1
fi

IMAGE="$1"

echo "🐍 Starting Python Smoke Test for $IMAGE..."
echo "----------------------------------------"

# 1. Security Check: Non-Root Enforcement
echo -n "[1/4] Checking non-root enforcement... "
ROOT_CHECK=$(docker run --rm $IMAGE touch /etc/test_file 2>&1)
if [[ $ROOT_CHECK == *"Permission denied"* ]]; then
    echo "✅ PASS (Root access blocked)"
else
    echo "❌ FAIL (Container allowed root-level write!)"
fi

# 2. Functional Check: Python Path and Version
echo -n "[2/4] Verifying Python path and version... "
PY_CHECK=$(docker run --rm $IMAGE python --version 2>&1)
if [[ $PY_CHECK == *"Python"* ]]; then
    echo "✅ PASS ($PY_CHECK)"
else
    echo "❌ FAIL (Python not found or execution error)"
fi

# 3. Functional Check: pip
echo -n "[3/4] Verifying pip is available... "
PIP_CHECK=$(docker run --rm $IMAGE pip --version 2>&1)
if [[ $PIP_CHECK == *"pip"* ]]; then
    echo "✅ PASS (pip is available)"
else
    echo "❌ FAIL (pip not found)"
fi

# 4. Footprint Check: Idle Memory
echo -n "[4/4] Measuring idle memory usage... "
CONTAINER_ID=$(docker run -d $IMAGE sleep 5)
MEM_USAGE=$(docker stats --no-stream --format "{{.MemUsage}}" $CONTAINER_ID)
docker rm -f $CONTAINER_ID > /dev/null
echo "📊 $MEM_USAGE (Benchmark complete)"

echo "----------------------------------------"
echo "🚀 Python Smoke Test Finished."
