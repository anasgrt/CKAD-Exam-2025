#!/bin/bash
#===============================================================================
# CKAD 2025 Practice Lab Runner
# Source: Verified 2025 CKAD Candidate Reports
# Usage: ./scripts/run-question.sh <Question-Folder>
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Functions
print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║           CKAD 2025 Practice Lab - Exam Simulator                ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_help() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./scripts/run-question.sh <Question-Folder> [command]"
    echo ""
    echo -e "${YELLOW}Commands:${NC}"
    echo "  setup     - Set up the lab environment (default)"
    echo "  verify    - Check if your answer is correct"
    echo "  solution  - Show the solution"
    echo "  reset     - Reset/cleanup the environment"
    echo "  list      - List all available questions"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./scripts/run-question.sh Question-01-Ingress-Creation"
    echo "  ./scripts/run-question.sh Question-02-Fix-Broken-Ingress verify"
    echo "  ./scripts/run-question.sh list"
    echo ""
}

list_questions() {
    echo -e "${CYAN}Available Questions:${NC}"
    echo ""
    for dir in "$BASE_DIR"/Question-*/; do
        if [ -d "$dir" ]; then
            q_name=$(basename "$dir")
            echo -e "  ${GREEN}•${NC} $q_name"
        fi
    done
    echo ""
}

run_setup() {
    local question_dir="$1"

    if [ ! -f "$question_dir/setup.sh" ]; then
        echo -e "${RED}Error: setup.sh not found in $question_dir${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Setting up lab environment...${NC}"
    echo ""
    bash "$question_dir/setup.sh"

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}QUESTION:${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    cat "$question_dir/question.txt"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Tip:${NC} When ready, run: ${CYAN}./scripts/run-question.sh $(basename $question_dir) verify${NC}"
    echo ""
}

run_verify() {
    local question_dir="$1"

    if [ ! -f "$question_dir/verify.sh" ]; then
        echo -e "${RED}Error: verify.sh not found in $question_dir${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Verifying your answer...${NC}"
    echo ""

    if bash "$question_dir/verify.sh"; then
        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                    ✅ CORRECT! Well done!                         ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
    else
        echo ""
        echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║              ❌ NOT CORRECT - Keep trying!                        ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Tip:${NC} Review the question and try again."
        echo -e "     Or run: ${CYAN}./scripts/run-question.sh $(basename $question_dir) solution${NC}"
        echo ""
    fi
}

run_solution() {
    local question_dir="$1"

    if [ ! -f "$question_dir/solution.sh" ]; then
        echo -e "${RED}Error: solution.sh not found in $question_dir${NC}"
        exit 1
    fi

    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}SOLUTION:${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    cat "$question_dir/solution.sh"
    echo ""
}

run_reset() {
    local question_dir="$1"

    if [ -f "$question_dir/reset.sh" ]; then
        echo -e "${YELLOW}Resetting environment...${NC}"
        bash "$question_dir/reset.sh"
        echo -e "${GREEN}Environment reset complete.${NC}"
    else
        echo -e "${YELLOW}No reset script found. Manual cleanup may be required.${NC}"
    fi
}

# Main
print_banner

if [ $# -eq 0 ]; then
    print_help
    exit 0
fi

COMMAND="${1:-}"

# Handle list command
if [ "$COMMAND" = "list" ]; then
    list_questions
    exit 0
fi

# Handle help
if [ "$COMMAND" = "help" ] || [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ]; then
    print_help
    exit 0
fi

# Find question directory
QUESTION_DIR=""
for dir in "$BASE_DIR"/Question-*/; do
    if [ -d "$dir" ]; then
        dir_name=$(basename "$dir")
        if [[ "$dir_name" == *"$COMMAND"* ]] || [ "$dir_name" = "$COMMAND" ]; then
            QUESTION_DIR="$dir"
            break
        fi
    fi
done

if [ -z "$QUESTION_DIR" ] || [ ! -d "$QUESTION_DIR" ]; then
    echo -e "${RED}Error: Question directory '$COMMAND' not found${NC}"
    echo ""
    list_questions
    exit 1
fi

ACTION="${2:-setup}"

case "$ACTION" in
    setup)
        run_setup "$QUESTION_DIR"
        ;;
    verify)
        run_verify "$QUESTION_DIR"
        ;;
    solution)
        run_solution "$QUESTION_DIR"
        ;;
    reset)
        run_reset "$QUESTION_DIR"
        ;;
    *)
        echo -e "${RED}Unknown action: $ACTION${NC}"
        print_help
        exit 1
        ;;
esac
