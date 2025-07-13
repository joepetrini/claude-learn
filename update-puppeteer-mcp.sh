#!/bin/bash

# Script to replace Puppeteer MCP with BrowserMCP

echo "Replacing Puppeteer MCP with BrowserMCP..."

# Remove existing puppeteer server
echo "Removing existing Puppeteer server..."
claude mcp remove puppeteer -s user

# Add browsermcp server
echo "Adding BrowserMCP server..."
claude mcp add browsermcp -s user -- npx @browsermcp/mcp@latest

echo "Done! Replaced Puppeteer MCP with BrowserMCP."
echo ""
echo "Important notes:"
echo "1. Restart Claude Code for changes to take effect"
echo "2. BrowserMCP provides browser automation capabilities"
echo ""
echo "To verify the configuration, run: claude mcp get browsermcp"