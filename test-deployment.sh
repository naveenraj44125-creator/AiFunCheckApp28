#!/bin/bash
# Comprehensive deployment test script

BASE_URL="http://54.174.19.3:3000"
TIMESTAMP=$(date +%s)
EMAIL="testuser${TIMESTAMP}@example.com"
USERNAME="testuser${TIMESTAMP}"
PASSWORD="testpass123"

echo "=== AI Stories Sharing - Deployment Test ==="
echo "Base URL: $BASE_URL"
echo ""

# Test 1: Health Check
echo "1. Testing Health Endpoint..."
HEALTH=$(curl -s "${BASE_URL}/api/health")
echo "Response: $HEALTH"
if echo "$HEALTH" | grep -q "ok"; then
    echo "✅ Health check passed"
else
    echo "❌ Health check failed"
    exit 1
fi
echo ""

# Test 2: Register User
echo "2. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\",\"username\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}")
echo "Response: $REGISTER_RESPONSE"
if echo "$REGISTER_RESPONSE" | grep -q "id"; then
    echo "✅ Registration successful"
    USER_ID=$(echo "$REGISTER_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    echo "User ID: $USER_ID"
else
    echo "❌ Registration failed"
    exit 1
fi
echo ""

# Test 3: Login
echo "3. Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\"}")
echo "Response: $LOGIN_RESPONSE"
if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo "✅ Login successful"
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    echo "Token: ${TOKEN:0:20}..."
else
    echo "❌ Login failed"
    exit 1
fi
echo ""

# Test 4: Create Post
echo "4. Testing Post Creation..."
POST_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{"content":{"type":"text","text":"My first AI story! ChatGPT tried to convince me it was sentient."},"visibility":"public"}')
echo "Response: $POST_RESPONSE"
if echo "$POST_RESPONSE" | grep -q "id"; then
    echo "✅ Post creation successful"
    POST_ID=$(echo "$POST_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    echo "Post ID: $POST_ID"
else
    echo "❌ Post creation failed"
    exit 1
fi
echo ""

# Test 5: Get Feed
echo "5. Testing Feed Retrieval..."
FEED_RESPONSE=$(curl -s "${BASE_URL}/api/feed")
echo "Response: $FEED_RESPONSE"
if echo "$FEED_RESPONSE" | grep -q "posts"; then
    echo "✅ Feed retrieval successful"
    POST_COUNT=$(echo "$FEED_RESPONSE" | grep -o '"total":[0-9]*' | cut -d':' -f2)
    echo "Total posts in feed: $POST_COUNT"
else
    echo "❌ Feed retrieval failed"
    exit 1
fi
echo ""

# Test 6: Get Specific Post
echo "6. Testing Get Post by ID..."
GET_POST_RESPONSE=$(curl -s "${BASE_URL}/api/posts/${POST_ID}")
echo "Response: $GET_POST_RESPONSE"
if echo "$GET_POST_RESPONSE" | grep -q "ChatGPT"; then
    echo "✅ Get post successful"
else
    echo "❌ Get post failed"
    exit 1
fi
echo ""

# Test 7: Logout
echo "7. Testing Logout..."
LOGOUT_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/auth/logout" \
  -H "Authorization: Bearer ${TOKEN}")
echo "Response: $LOGOUT_RESPONSE"
if echo "$LOGOUT_RESPONSE" | grep -q "Logged out"; then
    echo "✅ Logout successful"
else
    echo "❌ Logout failed"
    exit 1
fi
echo ""

echo "==================================="
echo "✅ ALL TESTS PASSED!"
echo "==================================="
echo ""
echo "Application is fully functional at:"
echo "  ${BASE_URL}"
echo ""
echo "Available endpoints:"
echo "  - GET  /api/health"
echo "  - POST /api/auth/register"
echo "  - POST /api/auth/login"
echo "  - POST /api/auth/logout"
echo "  - GET  /api/feed"
echo "  - POST /api/posts"
echo "  - GET  /api/posts/:id"
echo "  - PUT  /api/posts/:id"
echo "  - DELETE /api/posts/:id"
echo "  - POST /api/friends/request"
echo "  - POST /api/friends/accept/:requestId"
echo "  - POST /api/friends/decline/:requestId"
echo "  - DELETE /api/friends/:friendId"
echo "  - GET  /api/friends"
