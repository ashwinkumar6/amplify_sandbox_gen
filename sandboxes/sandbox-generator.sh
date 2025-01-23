#!/bin/bash

# Check if at least one argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <create|deleteAll> [number_of_iterations]"
  exit 1
fi

# Get the command and optional number of iterations
command=$1
num_iterations=$2

# Base directories
sandbox_dir="$(cd "$(dirname "$0")" && pwd)"
generated_dir="$sandbox_dir/generated"
template_dir="$sandbox_dir/template"
base_dir="$sandbox_dir"


# Check if the template directory exists
if [ ! -d "$template_dir" ]; then
  echo "Error: Template directory does not exist at $template_dir"
  exit 1
fi

# Create sandboxes
create_sandboxes() {
  if [ -z "$num_iterations" ]; then
    echo "Usage: $0 create <number_of_iterations>"
    exit 1
  fi

  # Create the 'generated' directory if it doesn't already exist
  if [ ! -d "$generated_dir" ]; then
    echo "Creating directory: $generated_dir"
    mkdir -p "$generated_dir"
  fi

  # Loop through the specified number of times
  for ((count=1; count<=num_iterations; count++)); do
    # Change to the base directory at the start of each iteration
    cd "$base_dir" || { echo "Failed to change directory to $base_dir"; exit 1; }

    # Define the identifier and target folder
    identifier="backend-$count"
    target_dir="$generated_dir/$identifier"
    log_file="logs"  # Only "logs" since we're inside the target directory

    # Create the target directory structure
    echo "Setting up directory: $target_dir"
    mkdir -p "$target_dir"

    # Create an empty logs file
    touch "$target_dir/$log_file"

    # Print working directory to debug
    echo "Current directory: $(pwd)"

    # Copy the entire template directory into the target directory using absolute path
    echo "Copying template to $target_dir"
    cp -r "$template_dir/." "$target_dir"

    # Navigate to the target directory and run the sandbox command
    echo "Running: npx ampx sandbox --identifier $identifier in $target_dir"
    pushd "$target_dir" > /dev/null
    npx ampx sandbox --identifier "$identifier" > "$log_file" 2>&1 &

    # Ensure we are not using 'popd' prematurely; we will let the background process finish in the next loop.
    # This allows the next iteration to start immediately.

    echo "Sandbox with identifier $identifier has been created or attempted."
  done

  echo "Completed creating sandboxes."
}

# Delete all sandboxes
delete_all_sandboxes() {
  if [ ! -d "$generated_dir" ]; then
    echo "No generated sandboxes to delete."
    exit 0
  fi

  # Loop through all generated directories
  for sandbox_dir in "$generated_dir"/backend-*; do
    if [ -d "$sandbox_dir" ]; then
      identifier=$(basename "$sandbox_dir")
      log_file="logs"  # Log file inside the target directory

      # Ensure logs file exists
      touch "$sandbox_dir/$log_file"

      echo "Deleting sandbox: $identifier"
      pushd "$sandbox_dir" > /dev/null
      npx ampx sandbox delete --identifier "$identifier" -y > "$log_file" 2>&1 &
      popd > /dev/null

      echo "Sandbox $identifier has been deleted or attempted."
    fi
  done

  # TODO: Clean up the generated directory
  # TODO: delete dir once stack is successfully destroyed
  # echo "Removing all generated directories."
  # rm -rf "$generated_dir"
  # echo "All sandboxes deleted."
}

# Execute the specified command
case $command in
  create)
    create_sandboxes
    ;;
  deleteAll)
    delete_all_sandboxes
    ;;
  *)
    echo "Unknown command: $command"
    echo "Usage: $0 <create|deleteAll> [number_of_iterations]"
    exit 1
    ;;
esac
