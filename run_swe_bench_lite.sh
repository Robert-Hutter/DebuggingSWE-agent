#!/bin/bash

# Colors for CLI formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print formatted messages
print_msg() {
    local color=$1
    local msg=$2
    echo -e "${color}${msg}${NC}"
}

# 3. Check for sweagent/debugger folder and contents
while true; do
    print_msg "${YELLOW}" "Please copy the SOLA Agent Debugger Client API sources into the sweagent/debugger folder."
    print_msg "${YELLOW}" "Press any key to continue..."
    read -n 1 -s
    echo

    if [ -d "sweagent/debugger" ] && [ "$(ls -A sweagent/debugger)" ]; then
        print_msg "${GREEN}" "Debugger sources found in sweagent/debugger."
        break
    else
        print_msg "${RED}" "Error: sweagent/debugger folder is missing or empty."
    fi
done

# 4. Check for existing OpenAI API key or prompt for a new one
if [ -n "$OPENAI_API_KEY" ]; then
    print_msg "${GREEN}" "OpenAI API key already set in environment."
else
    while true; do
        print_msg "${YELLOW}" "Enter your OpenAI API key:"
        read -r api_key
        # Validation: checks if key starts with sk- and is at least 20 chars, allowing dashes
        if [[ $api_key =~ ^sk-[a-zA-Z0-9\-]{20,} ]]; then
            print_msg "${GREEN}" "Valid OpenAI API key format."
            export OPENAI_API_KEY="$api_key"
            print_msg "${GREEN}" "OpenAI API key exported successfully."
            break
        else
            print_msg "${RED}" "Error: Invalid OpenAI API key format. It should start with 'sk-' and be at least 20 characters."
        fi
    done
fi
echo

# 5. Prompt to start SOLA Agent Debugger Server
print_msg "${YELLOW}" "Please start the SOLA Agent Debugger Server with client port 8765."
print_msg "${YELLOW}" "Press any key to continue..."
read -n 1 -s
echo

# 6. Prompt for LLM model selection
print_msg "${BLUE}" "Select an LLM model:"
PS3="Enter the number (1-4): "
options=("gpt-4o-mini" "gpt-4.1" "gpt-4o" "gpt-5")
select model in "${options[@]}"; do
    if [[ " ${options[*]} " =~ " ${model} " ]]; then
        print_msg "${GREEN}" "Selected model: $model"
        break
    else
        print_msg "${RED}" "Invalid selection. Please choose 1, 2, 3, or 4."
    fi
done
echo

# 7. Start SWE Agent with the selected model
print_msg "${BLUE}" "Starting SWE-Agent..."
sweagent run-batch \
    --config config/default.yaml \
    --agent.model.name "$model" \
    --agent.model.per_instance_cost_limit 2.00 \
    --instances.type swe_bench \
    --instances.subset lite \
    --instances.split dev  \
    --instances.slice :3 \
    --instances.shuffle=True