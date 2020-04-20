#!/bin/bash

docker run -p 1313:1313 -v $(pwd):/source -w /source monachus/hugo hugo server --bind=0.0.0.0 --theme contrast-hugo --renderToDisk
