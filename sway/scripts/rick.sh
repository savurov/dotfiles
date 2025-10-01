#!/usr/bin/env bash
# Wait for Sway to fully initialize

# Open Chrome directly to the video
google-chrome --hide-crash-restore-bubble --new-window "https://www.youtube.com/watch?v=dQw4w9WgXcQ&autoplay=1"

# Optional: force fullscreen on YouTube (needs swaymsg and jq)
# swaymsg '[app_id="google-chrome-canary"] fullscreen enable'

