# Test Markdown Syntax Highlighting

This is a test file to verify that syntax highlighting works in markdown code blocks.

## Python Example

```python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

# Example usage
result = fibonacci(10)
print(f"Result: {result}")

class DataProcessor:
    def __init__(self, config):
        self.config = config
        self.results = []
    
    async def process_items(self, items):
        """Process items asynchronously."""
        for item in items:
            processed = await self.process_single_item(item)
            self.results.append(processed)
        return self.results
```

## JavaScript Example

```javascript
const fetchUserData = async (userId) => {
  try {
    const response = await fetch(`/api/users/${userId}`);
    const userData = await response.json();
    return userData;
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw error;
  }
};

// Usage
fetchUserData(123)
  .then(user => console.log(user))
  .catch(err => console.error(err));
```

## Lua Example

```lua
local function fibonacci(n)
  if n <= 1 then
    return n
  end
  return fibonacci(n - 1) + fibonacci(n - 2)
end

-- Example usage
local result = fibonacci(10)
print("Result: " .. result)

-- Table manipulation
local users = {
  { id = 1, name = "Alice", active = true },
  { id = 2, name = "Bob", active = false }
}

for i, user in ipairs(users) do
  if user.active then
    print(string.format("User %d: %s is active", i, user.name))
  end
end
```

## Bash Example

```bash
#!/bin/bash

# Function to deploy application
deploy_app() {
    local env="$1"
    local app_name="$2"
    
    echo "Deploying $app_name to $env environment..."
    
    if [ ! -f "config/$env.conf" ]; then
        echo "Error: Configuration file not found!"
        return 1
    fi
    
    # Build and deploy
    docker build -t "$app_name:$env" .
    docker-compose -f "docker-compose.$env.yml" up -d
    
    echo "Deployment complete!"
}

# Main execution
deploy_app "${1:-staging}" "${2:-myapp}"
```

## TOML Configuration Example

```toml
[package]
name = "my-rust-app"
version = "0.1.0"
edition = "2021"
authors = ["Your Name <your.email@example.com>"]
description = "A modern Rust application with async support"

[dependencies]
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
clap = { version = "4.0", features = ["derive"] }

[dev-dependencies]
tokio-test = "0.4"

[[bin]]
name = "server"
path = "src/bin/server.rs"

[profile.release]
opt-level = 3
lto = true
```

If you can see syntax highlighting for the code inside the code blocks above, then treesitter injection is working correctly!
