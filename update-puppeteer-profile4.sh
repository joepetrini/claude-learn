#!/bin/bash

# Script to update Puppeteer MCP with Chrome Profile 4

echo "Updating Puppeteer MCP server to use Chrome Profile 4 (Joe)..."

# Remove existing puppeteer server
echo "Removing existing Puppeteer server..."
claude mcp remove puppeteer -s user

# Add puppeteer with Profile 4
echo "Adding Puppeteer with Chrome Profile 4..."
claude mcp add puppeteer -s user \
  -e 'PUPPETEER_LAUNCH_OPTIONS={"headless": false, "executablePath": "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "userDataDir": "/Users/joepetrini/Library/Application Support/Google/Chrome/Profile 4"}' \
  -- npx -y @modelcontextprotocol/server-puppeteer

echo "Done! Puppeteer MCP has been updated to use Chrome Profile 4 (Joe - joepetrini@gmail.com)."
echo ""
echo "Important notes:"
echo "1. Make sure Chrome is closed before using Puppeteer"
echo "2. Restart Claude Code for changes to take effect"
echo ""
echo "To verify the configuration, run: claude mcp get puppeteer"