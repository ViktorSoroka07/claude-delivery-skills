#!/bin/sh
# The later-round case's history, under a prompt that asks for the review "again".
here=$(cd "$(dirname "$0")" && pwd)
exec sh "$here/../review-pr-reviews-only-what-changed/fixture.sh"
