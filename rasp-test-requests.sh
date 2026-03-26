#!/bin/bash
# =============================================================================
# RASP Java Agent - API Test Requests
# =============================================================================
# Tests the RASP agent protection on Spring PetClinic REST API.
# Run: bash rasp-test-requests.sh
#
# Prerequisites:
#   - Spring PetClinic running on http://localhost:9966 with RASP agent attached
# =============================================================================

BASE_URL="http://localhost:9966/petclinic/api"

echo "=============================================="
echo " RASP Java Agent - API Test Requests"
echo "=============================================="
echo ""

# -----------------------------------------------------------------------------
# SECTION 1: Normal API Requests (should pass through)
# -----------------------------------------------------------------------------

echo "=============================="
echo " 1. NORMAL API REQUESTS"
echo "=============================="
echo ""

# --- Owners ---
echo ">> GET /owners - List all owners"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners"
echo ""
echo "---"

echo ">> GET /owners?lastName=Davis - Search owner by last name"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=Davis"
echo ""
echo "---"

echo ">> GET /owners/1 - Get owner by ID"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners/1"
echo ""
echo "---"

echo ">> POST /owners - Create a new owner"
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/owners" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "RaspUser",
    "address": "123 Test St",
    "city": "TestCity",
    "telephone": "1234567890"
  }'
echo ""
echo "---"

echo ">> PUT /owners/1 - Update an owner"
curl -s -w "\nHTTP Status: %{http_code}\n" -X PUT "$BASE_URL/owners/1" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "George",
    "lastName": "Franklin",
    "address": "110 W. Liberty St.",
    "city": "Madison",
    "telephone": "6085551023"
  }'
echo ""
echo "---"

# --- Pets ---
echo ">> GET /owners/1/pets - List pets for owner"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners/1/pets"
echo ""
echo "---"

# --- Vets ---
echo ">> GET /vets - List all vets"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/vets"
echo ""
echo "---"

# --- Pet Types ---
echo ">> GET /pettypes - List all pet types"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/pettypes"
echo ""
echo "---"

# --- Specialties ---
echo ">> GET /specialties - List all specialties"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/specialties"
echo ""
echo "---"

# --- Visits ---
echo ">> GET /visits - List all visits"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/visits"
echo ""
echo ""

# -----------------------------------------------------------------------------
# SECTION 2: SQL Injection Attacks (RASP should detect at JDBC sink)
# -----------------------------------------------------------------------------

echo "=============================="
echo " 2. SQL INJECTION ATTACKS"
echo "=============================="
echo ""

echo ">> SQLi via query param - OR 1=1"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=1'%20OR%201%3D1--"
echo ""
echo "---"

echo ">> SQLi via query param - UNION SELECT"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName='%20UNION%20SELECT%20username,password%20FROM%20users--"
echo ""
echo "---"

echo ">> SQLi via query param - DROP TABLE"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=';DROP%20TABLE%20owners;--"
echo ""
echo "---"

echo ">> SQLi via path param"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners/1%20OR%201%3D1"
echo ""
echo "---"

echo ">> SQLi via JSON body - firstName field"
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/owners" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Robert'\''); DROP TABLE owners;--",
    "lastName": "Hacker",
    "address": "123 Evil St",
    "city": "Hackville",
    "telephone": "0000000000"
  }'
echo ""
echo "---"

echo ">> SQLi - Blind boolean-based"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=Davis'%20AND%201%3D1%20AND%20''%3D'"
echo ""
echo "---"

echo ">> SQLi - Time-based blind"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=Davis';WAITFOR%20DELAY%20'0:0:5'--"
echo ""
echo ""

# -----------------------------------------------------------------------------
# SECTION 3: Path Traversal Attacks (RASP should detect at File sink)
# -----------------------------------------------------------------------------

echo "=============================="
echo " 3. PATH TRAVERSAL ATTACKS"
echo "=============================="
echo ""

echo ">> Path traversal - ../../etc/passwd"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners/..%2F..%2F..%2Fetc%2Fpasswd"
echo ""
echo "---"

echo ">> Path traversal - backslash variant"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners/..%5C..%5C..%5Cwindows%5Csystem32%5Cdrivers%5Cetc%5Chosts"
echo ""
echo "---"

echo ">> Path traversal - double encoding"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners/..%252F..%252F..%252Fetc%252Fpasswd"
echo ""
echo ""

# -----------------------------------------------------------------------------
# SECTION 4: Command Injection Attacks (RASP should detect at Process sink)
# -----------------------------------------------------------------------------

echo "=============================="
echo " 4. COMMAND INJECTION ATTACKS"
echo "=============================="
echo ""

echo ">> Command injection via query param"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=;cat%20/etc/passwd"
echo ""
echo "---"

echo ">> Command injection via header"
curl -s -w "\nHTTP Status: %{http_code}\n" \
  -H "X-Custom-Header: \$(whoami)" \
  "$BASE_URL/owners"
echo ""
echo "---"

echo ">> Command injection - pipe variant"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=|ls%20-la"
echo ""
echo "---"

echo ">> Command injection - backtick variant"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=\`id\`"
echo ""
echo ""

# -----------------------------------------------------------------------------
# SECTION 5: XSS Attacks (RASP should detect reflected payloads)
# -----------------------------------------------------------------------------

echo "=============================="
echo " 5. XSS ATTACKS"
echo "=============================="
echo ""

echo ">> Reflected XSS via query param"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=<script>alert('xss')</script>"
echo ""
echo "---"

echo ">> XSS via JSON body"
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/owners" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "<img src=x onerror=alert(1)>",
    "lastName": "XSSTest",
    "address": "123 Test St",
    "city": "TestCity",
    "telephone": "1234567890"
  }'
echo ""
echo "---"

echo ">> XSS - SVG onload"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners?lastName=<svg/onload=alert('xss')>"
echo ""
echo ""

# -----------------------------------------------------------------------------
# SECTION 6: IDOR Attacks (accessing other users' resources)
# -----------------------------------------------------------------------------

echo "=============================="
echo " 6. IDOR ATTACKS"
echo "=============================="
echo ""

echo ">> Access owner ID 1"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners/1"
echo ""
echo "---"

echo ">> Access owner ID 999 (non-existent)"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/owners/999"
echo ""
echo "---"

echo ">> Delete owner (unauthorized)"
curl -s -w "\nHTTP Status: %{http_code}\n" -X DELETE "$BASE_URL/owners/1"
echo ""
echo ""

# -----------------------------------------------------------------------------
# SECTION 7: Header Injection / HTTP Smuggling
# -----------------------------------------------------------------------------

echo "=============================="
echo " 7. HEADER INJECTION"
echo "=============================="
echo ""

echo ">> Host header injection"
curl -s -w "\nHTTP Status: %{http_code}\n" \
  -H "Host: evil.com" \
  "$BASE_URL/owners"
echo ""
echo "---"

echo ">> CRLF injection via header"
curl -s -w "\nHTTP Status: %{http_code}\n" \
  -H "X-Injected: value%0d%0aInjected-Header: evil" \
  "$BASE_URL/owners"
echo ""
echo ""

# -----------------------------------------------------------------------------
# SECTION 8: Mass Assignment / Unexpected Fields
# -----------------------------------------------------------------------------

echo "=============================="
echo " 8. MASS ASSIGNMENT"
echo "=============================="
echo ""

echo ">> POST with extra fields (id, role)"
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/owners" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 999,
    "firstName": "Admin",
    "lastName": "Hacker",
    "address": "123 Hack St",
    "city": "Hackville",
    "telephone": "0000000000",
    "role": "ADMIN",
    "isAdmin": true
  }'
echo ""
echo ""

echo "=============================================="
echo " TEST COMPLETE"
echo "=============================================="
echo ""
echo "Check your RASP fleet dashboard at:"
echo "  https://core.htsone.ai"
echo ""
echo "Look for security events reported by agent:"
echo "  App: spring-petclinic-rest"
echo "=============================================="
