#!/bin/sh

echo "Generating site content...."
hugo 

echo "Uploading new site..."
cd public 
git add --all 1>/dev/null
git commit -m "Update site"  1>/dev/null
git push origin -f master 1>/dev/null


echo "DONE."
