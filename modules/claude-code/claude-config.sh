#!/bin/bash
# Show current Claude Code configuration

echo "Claude Code Configuration"
echo "========================="
echo ""
echo "User settings: ~/.claude/settings.json"
echo ""
if [ -f ~/.claude/settings.json ]; then
  jq '.' ~/.claude/settings.json
else
  echo "(No settings file found)"
fi

echo ""
echo "Project settings: .claude/settings.json"
echo ""
if [ -f .claude/settings.json ]; then
  jq '.' .claude/settings.json
else
  echo "(No project settings)"
fi
