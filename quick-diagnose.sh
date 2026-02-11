#!/bin/bash
# Quick diagnostic script with timeouts

echo "=== Quick Deployment Diagnostic ==="
echo ""

# Test health endpoint
echo "1. Testing health endpoint..."
timeout 5 curl -s http://54.174.19.3:3000/api/health || echo "FAILED or TIMEOUT"
echo ""

# Test root endpoint
echo "2. Testing root endpoint..."
timeout 5 curl -s http://54.174.19.3:3000/ | head -5 || echo "FAILED or TIMEOUT"
echo ""

# Check if port 3000 is open
echo "3. Checking if port 3000 is listening..."
timeout 5 nc -zv 54.174.19.3 3000 2>&1 || echo "Port check failed"
echo ""

echo "=== Diagnostic Complete ==="
