# Bito Action

This document provides a step-by-step guide for setting up and running the Bito Action Script. The Bito Action Script allows you to configure and run automated code reviews using the Bito Code Review Agent (CRA). It enables you to seamlessly integrate the CRA into your Continuous Integration/Continuous Deployment (CI/CD) pipeline. Follow the instructions below to configure and execute the script successfully.

## Steps for Setup

### 1. Login to Bito

- Navigate to the Bito platform: [Bito Login](https://alpha.bito.ai/auth/login).
- Use your credentials to log in to your account.

### 2. Create a New Agent Configuration Instance

- After logging in, go to **Configured Agents**.
- Select **Code Review Agent (CRA)**.
- Click on **Create New Instance**.

### 3. Configure the CRA Agent

- During the setup process, you'll need to provide a Git access token to allow the CRA to access your repositories. Please refer to [Bito Documentation](https://docs.bito.ai/) to create a Git access token.
- After a successful configuration, you'll receive a unique **Agent Instance URL** and **Agent Instance Secret**. These credentials are essential for configuring the Bito Action Script.

### 4. Download Bito Action Script

- Download the Bito Action Script and a sample configuration file from the following repository: [Bito Action Script on GitHub](https://github.com/gitbito/CodeReviewAgent/tree/main/bito-action-script).

### 5. Update the Property File

- Open the `bito_action.properties` file located in the downloaded script folder.
- Update the following properties with the information provided during the CRA configuration:

  - agent_instance_url=<your_agent_instance_url>
  - agent_instance_secret=<your_agent_instance_secret>
  - pr_url=<your_git_repository_url> (Optional if using the runtime URL method)
  

### 6. Run the Bito Action Script

You can run the Bito Action Script in two different ways, depending on your preference:

#### Option 1: Using the Property File and Runtime Git URL

- Ensure the `bito_action.properties` file is updated with the correct values.
- Run the following command:

  ```bash
  bash ./bito_actions.sh bito_action.properties pr_url=<pr_url>
  ```
  - Replace <pr_url> with the pull request URL you want to review.
  

#### Option 2: Using Runtime Values

- Provide all necessary values directly in the command line:

  ```bash
  bash ./bito_actions.sh agent_instance_url=<agent_instance_url> agent_instance_secret=<secret> pr_url=<pr_url>
  ```
  - Replace <agent_instance_url>, <secret>, and <pr_url> with your specific values.

### 7. Integrate Bito Action Script into CI/CD Pipeline

- Incorporate the Bito Action Script into your CI/CD pipeline by including the appropriate commands in your build or deployment scripts.
  
- This integration ensures that code reviews are automatically triggered as part of the pipeline, enhancing your development workflow by enforcing code quality checks on every code change.

## Script Responses

During execution, the script will return various responses based on the success or failure of the process. Below are the possible responses: 

### 1. Success
**Response:**
```plaintext
Success:- Job Started with Id : ce82fae8-05da-4389-bddc-86ed583ab053

```

### 2. Invalid Secret
**Response:**
```plaintext
{"status":1,"response":"Secret is not valid","created":"2024-08-09T12:32:23.060340616Z"}

```

### 3. Invalid Instance URL
**Response:**
```plaintext
{"status":1,"response":"webhook is invalid: Please create a new instance","created":"2024-08-09T12:33:07.050869506Z"}

```

### 4. Missing Input Data for Script
**Response:**
```plaintext
Error: pr_url is empty

```

## Example Property File

Below is a sample `bito_action.properties` file:
```plaintext
agent_instance_url=your_agent_instance_url
agent_instance_secret=your_agent_secret
pr_url=

```

## Conclusion

You are now ready to use the Bito Action Script for automated code reviews through CI/CD Pipelines. Ensure all configurations are correct before running the script. If you encounter any issues, consult the [Bito Documentation](https://docs.bito.ai/) or reach out to Bito support for assistance.



