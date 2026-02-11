#!/bin/bash
# Deployment Diagnostic Script for Node.js Applications
# This script helps diagnose common deployment issues

echo "==================================="
echo "Deployment Diagnostic Tool"
echo "==================================="
echo ""

# Check if we're on the server or local
if [ -f "/etc/os-release" ]; then
    echo "✓ Running on server"
    ON_SERVER=true
else
    echo "✓ Running locally"
    ON_SERVER=false
fi

echo ""
echo "1. Checking Node.js Installation"
echo "-----------------------------------"
if command -v node &> /dev/null; then
    echo "✓ Node.js installed: $(node --version)"
else
    echo "✗ Node.js NOT installed"
fi

if command -v npm &> /dev/null; then
    echo "✓ npm installed: $(npm --version)"
else
    echo "✗ npm NOT installed"
fi

echo ""
echo "2. Checking PM2 Installation"
echo "-----------------------------------"
if command -v pm2 &> /dev/null; then
    echo "✓ PM2 installed: $(pm2 --version)"
    echo ""
    echo "PM2 Process List:"
    pm2 list
    echo ""
    echo "PM2 Logs (last 20 lines):"
    pm2 logs --lines 20 --nostream
else
    echo "✗ PM2 NOT installed"
fi

echo ""
echo "3. Checking Application Files"
echo "-----------------------------------"
APP_DIR="/var/www/aifuncheckapp1"
if [ -d "$APP_DIR" ]; then
    echo "✓ Application directory exists: $APP_DIR"
    echo ""
    echo "Directory contents:"
    ls -la "$APP_DIR"
    echo ""
    
    if [ -d "$APP_DIR/dist" ]; then
        echo "✓ dist folder exists"
        echo "dist contents:"
        ls -la "$APP_DIR/dist"
    else
        echo "✗ dist folder NOT found"
    fi
    
    if [ -f "$APP_DIR/package.json" ]; then
        echo "✓ package.json exists"
        echo "Main entry point:"
        grep '"main"' "$APP_DIR/package.json"
        echo "Start script:"
        grep '"start"' "$APP_DIR/package.json"
    else
        echo "✗ package.json NOT found"
    fi
    
    if [ -f "$APP_DIR/ecosystem.config.js" ]; then
        echo "✓ ecosystem.config.js exists"
    else
        echo "✗ ecosystem.config.js NOT found"
    fi
else
    echo "✗ Application directory NOT found: $APP_DIR"
fi

echo ""
echo "4. Checking Port 3000"
echo "-----------------------------------"
if command -v netstat &> /dev/null; then
    echo "Processes listening on port 3000:"
    sudo netstat -tlnp | grep :3000 || echo "No process listening on port 3000"
elif command -v ss &> /dev/null; then
    echo "Processes listening on port 3000:"
    sudo ss -tlnp | grep :3000 || echo "No process listening on port 3000"
else
    echo "✗ netstat/ss not available"
fi

echo ""
echo "5. Testing Health Endpoint"
echo "-----------------------------------"
if command -v curl &> /dev/null; then
    echo "Testing http://localhost:3000/api/health"
    curl -v http://localhost:3000/api/health 2>&1 || echo "Failed to connect"
else
    echo "✗ curl not available"
fi

echo ""
echo "6. Checking System Logs"
echo "-----------------------------------"
if [ -f "/var/log/syslog" ]; then
    echo "Recent syslog entries (last 10):"
    sudo tail -10 /var/log/syslog | grep -i "node\|pm2\|error" || echo "No relevant entries"
fi

echo ""
echo "7. Checking Environment Variables"
echo "-----------------------------------"
if [ -f "$APP_DIR/.env" ]; then
    echo "✓ .env file exists"
    echo "Environment variables (values hidden):"
    grep -v "^#" "$APP_DIR/.env" | grep -v "^$" | cut -d= -f1
else
    echo "✗ .env file NOT found"
fi

echo ""
echo "==================================="
echo "Diagnostic Complete"
echo "==================================="
