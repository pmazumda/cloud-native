Installation


To install Node.js and Yarn, follow these steps:

### 1. Install Node.js

- Visit the [Node.js official website](https://nodejs.org/).
- Download the LTS (Long Term Support) version for your operating system.
- Run the installer and follow the prompts to complete the installation.
- To verify the installation, open your terminal and run:
  ```
  node -v
  npm -v
  ```

### 2. Install Yarn

- Open your terminal.
- Run the following command to install Yarn globally using npm:
  ```
  npm install --global yarn
  ```
- To verify Yarn is installed, run:
  ```
  yarn --version
  ```

For more details, refer to the [Yarn official documentation](https://yarnpkg.com/getting-started/install).

### 3. Install Devbox

- Visit the [Devbox official website](https://www.jetpack.io/devbox/docs/install/) for the latest installation instructions.
- For Windows, you can use the following command in PowerShell (requires [Scoop](https://scoop.sh/) to be installed):
  ```
  scoop install devbox
  ```
- Alternatively, download the installer from the [Devbox releases page](https://github.com/jetpack-io/devbox/releases) and follow the instructions for your OS.
- To verify the installation, run:
  ```
  devbox --version
  ```

### 4. Initialize a Devbox Project

- In your project directory, run:
  ```
  devbox init
  ```
- This will create a `devbox.json` file in your project folder.
- You can now add packages to your Devbox environment:
  ```
  devbox add <package-name>
  ```
- To start a shell with your Devbox environment, run:
  ```
  devbox shell
  ```

For more details, refer to the [Devbox documentation](https://www.jetpack.io/devbox/docs/).
