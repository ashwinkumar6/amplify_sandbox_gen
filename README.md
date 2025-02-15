# Sandbox Management Script

This script automates the creation and deletion of [Amplify gen2 sandboxes](https://docs.amplify.aws/react/how-amplify-works/concepts/) for development and testing purposes. It ensures each sandbox is set up correctly with its required resources and supports running multiple iterations in parallel.

## Features
- **Sandbox Creation**:
  - Automatically sets up directories and copies templates for sandbox creation.
  - Runs sandbox creation commands (`npx ampx sandbox`) in the background to allow parallel execution.
- **Sandbox Deletion**:
  - Removes all sandboxes and associated resources using the `npx ampx sandbox delete` command.
- **Configurable Iterations**:
  - Specify the number of sandboxes to create using a command-line argument.
  
## Prerequisites
0. **Credentials**: Make sure you have required creds or permission configured to access your AWS account.
1. **Node.js**: Ensure `Node.js` and `npx` are installed and available in your environment.
2. **ampx CLI**: The `ampx` CLI tool must be installed globally or accessible via `npx`.
3. **Template Directory**: The `template` directory must exist in the same location as the script, containing the resources required for each sandbox.

## Usage

### Commands

The script supports two commands: `create` and `deleteAll`.

1. **Create Sandboxes**:
    ```bash
    ./sandboxes/sandbox-generator.sh create <number_of_iterations>
    ```
  - Example: Create 3 sandboxes:
        ```bash
        ./sandboxes/sandbox-generator.sh create 3
        ```

2. **Delete All Sandboxes**:
    ```bash
    ./sandboxes/sandbox-generator.sh deleteAll
    ```

## File Structure
```
sandboxes
├── generated
│   ├── backend-1
│   │   ├── amplify
│   │   │   ├── auth
│   │   │   │   └── resource.ts
│   │   │   ├── backend.ts
│   │   │   ├── package.json
│   │   │   └── tsconfig.json
│   │   ├── amplify_outputs.json
│   │   ├── logs
│   │   └── package.json
│   └── backend-2
│       ├── amplify
│       │   ├── auth
│       │   │   └── resource.ts
│       │   ├── backend.ts
│       │   ├── package.json
│       │   └── tsconfig.json
│       ├── amplify_outputs.json
│       ├── logs
│       └── package.json
├── sandbox-generator.sh
└── template
    ├── amplify
    │   ├── auth
    │   │   └── resource.ts
    │   ├── backend.ts
    │   ├── package.json
    │   └── tsconfig.json
    └── package.json

11 directories, 20 files
```

- `template/`: Contains the base files and directories to copy into each sandbox.
- `generated/`: Created dynamically to store the sandboxes.

## Output
Logs for each sandbox are saved in a file named logs inside each sandbox directory (generated/backend-*).

### Example Output
Check AWS CloudFormation console to verify stack creation/deletion 
- **Creating Sandboxes**
    ```
    Setting up directory: ./generated/backend-1
    Copying template to ./generated/backend-1
    Current directory: /path/to/sandboxes
    Running: npx ampx sandbox --identifier backend-1 in ./generated/backend-1
    Sandbox with identifier backend-1 has been created or attempted.

    Setting up directory: ./generated/backend-2
    Copying template to ./generated/backend-2
    Current directory: /path/to/sandboxes
    Running: npx ampx sandbox --identifier backend-2 in ./generated/backend-2
    Sandbox with identifier backend-2 has been created or attempted.
    Completed creating sandboxes.
    ```
- **Deleting Sandboxes**
```
Deleting sandbox: backend-1
Sandbox backend-1 has been deleted or attempted.
Deleting sandbox: backend-2
Sandbox backend-2 has been deleted or attempted.
```


## Notes
1. Error Handling: If any command fails, logs can be inspected for troubleshooting.
2. Parallel Execution: Sandbox commands run in the background, allowing for efficient resource setup.
3. Customization: Update the base_dir variable in the script to point to your preferred working directory.

## Error handling
1. Spawning a large number of sandboxes might result in a large number of background processes which would result in high memory usage.
