#!/bin/bash
echo "Uploading source ..."
git add --all 1>/dev/null
git commit -m "Update source" 1>/dev/null
git push -f origin source:source 1>/dev/null

echo "DONE."
