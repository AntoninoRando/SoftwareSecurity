#!/bin/bash
NC='\033[0m' # No Color
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'

echo -e "\n${RED}Results of flawfinder on the original version of the code:\n${NC}"
uv run flawfinder Project1_SSA24.c

echo -e "\n${GREEN}Results of flawfinder on the corrected version of the code:\n\n${NC}"
uv run flawfinder Project1_SSA24_correct.c