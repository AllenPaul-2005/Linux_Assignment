#!/bin/bash
pid=$(ps -eo pid,%mem --sort=-%mem | awk 'NR==2 {print $1}')
kill -9 "$pid"
