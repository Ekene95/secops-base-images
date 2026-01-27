#!/bin/bash
IMAGE="mpnt-wolfi-java:24.0.1-amd64"

echo "🧪 Starting Smoke Test for $IMAGE..."
echo "----------------------------------------"

# 1. Security Check: Non-Root Enforcement
echo -n "[1/4] Checking non-root enforcement... "
ROOT_CHECK=$(docker run --rm $IMAGE touch /etc/test_file 2>&1)
if [[ $ROOT_CHECK == *"Permission denied"* ]]; then
    echo "✅ PASS (Root access blocked)"
else
    echo "❌ FAIL (Container allowed root-level write!)"
fi

# 2. Functional Check: Java Path and Version
echo -n "[2/4] Verifying Java path and version... "
JAVA_CHECK=$(docker run --rm $IMAGE java -version 2>&1)
if [[ $JAVA_CHECK == *"openjdk version"* ]]; then
    echo "✅ PASS (Java is in PATH and executable)"
else
    echo "❌ FAIL (Java not found or execution error)"
fi

# 3. Environment Check: JAVA_HOME
echo -n "[3/4] Validating JAVA_HOME... "
JH_CHECK=$(docker run --rm $IMAGE sh -c 'echo $JAVA_HOME')
if [[ $JH_CHECK == "/usr/lib/jvm/java-24-openjdk" ]]; then
    echo "✅ PASS (JAVA_HOME is correct)"
else
    echo "❌ FAIL (JAVA_HOME is $JH_CHECK)"
fi

# 4. Footprint Check: Idle Memory
echo -n "[4/4] Measuring idle memory usage... "
CONTAINER_ID=$(docker run -d $IMAGE sleep 5)
MEM_USAGE=$(docker stats --no-stream --format "{{.MemUsage}}" $CONTAINER_ID)
docker rm -f $CONTAINER_ID > /dev/null
echo "📊 $MEM_USAGE (Benchmark complete)"

echo "----------------------------------------"
echo "🚀 Smoke Test Finished."
