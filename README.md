# AI Code Review Agent

## Overview
Bito’s **[AI Code Review Agent](https://bito.ai/ai-code-review-agent/)** is the first agent built with **Bito’s AI Agent framework and engine**. It is an automated AI assistant (powered by OpenAI’s GPT-4 and Anthropic’s Claude 2.1) that will review your team’s code; it spots bugs, issues, code smells, and security vulnerabilities in Pull/Merge Requests (PR/MR) and provides high-quality suggestions to fix them.

It seamlessly **integrates with Git providers such as GitHub, GitLab, and Bitbucket (coming soon)**, automatically posting recommendations directly as comments within the corresponding Pull Request. It includes real-time recommendations from static analysis and OSS vulnerability tools such as fbinfer, Dependency-Check, etc., and can include high severity suggestions from other 3rd party tools you use such as Snyk or Sonar.

The upcoming Bito's **Native Code RAG** feature will enable the AI Code Review Agent to understand your entire codebase, offering better context-aware analysis and suggestions for a more personalized and contextually relevant code review experience.

AI Code Review Agent ensures a secure and confidential experience without compromising on reliability. Bito neither reads nor stores your code, and none of your code is used for AI model training. Learn more about our **[Privacy & Security practices](https://docs.bito.ai/privacy-and-security)**.

**[View Documentation](https://docs.bito.ai/bito-dev-agents/ai-code-review-agent)**

## Watch Video on YouTube
Right-click the image below and select "Open link in new tab" to view the **[YouTube video](https://youtu.be/QzMFfl2KRJI)** on a new page.

[![Bito's AI Code Review Agent](https://img.youtube.com/vi/QzMFfl2KRJI/0.jpg)](https://www.youtube.com/watch?v=QzMFfl2KRJI)

## Getting Started
There are two ways to use the AI Code Review Agent.

**1- Bito Cloud:** Offers a hassle-free experience with no installation required on your machine.
[Follow this guide](https://docs.bito.ai/bito-dev-agents/ai-code-review-agent/getting-started/install-run-using-bito-cloud)

**2- Self-hosted service via CLI, webhooks, or GitHub Actions:** Ideal for deployments within your own infrastructure.
[Follow this guide](https://docs.bito.ai/bito-dev-agents/ai-code-review-agent/getting-started/install-run-as-a-self-hosted-service)

## Why Use AI for Code Review?
- **Time Saving**: Can reduce code review time by up to 50%.
- **Quality Improvement**: Enhances code review quality.
- **Support Role**: Assists senior software engineers, focusing on mundane review tasks.

## Key Features
- **Pull Request (PR) Summary**: Quick overview of PRs.
- **Estimated Effort to Review**: Evaluates complexity for better planning.
- **Code Improvement**: Analyzes security, performance, scalability, optimization, potential breakages, code structure, and coding standards.
- **Tailored Code Suggestions**: Provides specific line-by-line code improvement advice.
- **Static Code Analysis**: Uses tools like fbinfer, supports integration with tools like Sonar.
- **Open Source Security Vulnerabilities**: Checks for high-severity vulnerabilities using tools like OWASP Dependency-Check.
- **Feedback in PRs/MRs**: Posts review comments directly in PRs or MRs.
- **Real-Time Feedback**: Upcoming feature for instant IDE feedback.

## Screenshots
### Screenshot # 1
> *Code review automatically added as comment when a pull request is created.*

![AI Code Review Agent's output screenshot](https://github.com/gitbito/codereviewagent/assets/22556762/c465ceab-9164-4eb3-b899-3c824773b194)

---

### Screenshot # 2
> *Code review manually triggered using **/review** command.*

![AI Code Review Agent's output screenshot](https://github.com/gitbito/codereviewagent/assets/22556762/dc84121a-e79d-4893-bb4a-c95a5ca434b3)

---

### Screenshot # 3
> *Line-by-line code suggestions to quickly fix issues.*

![AI Code Review Agent's output screenshot](https://github.com/gitbito/codereviewagent/assets/22556762/df8f422e-5ba3-4e24-ae1e-32d3cfd4ad40)

---

### Screenshot # 4
> *Using tools like Facebook’s open source fbinfer (available out of the box), it analyzes your code, specific to the language, thoroughly and suggests fixes. Tools you use such as Sonar can also be configured.*

![AI Code Review Agent's output screenshot](https://github.com/gitbito/codereviewagent/assets/22556762/1afa9f7e-7f1a-4644-b2fc-36de23aa54ea)

---

### Screenshot # 5
> *The Agent checks real-time for the latest high severity security vulnerabilities in your code, using OWASP Dependency-Check (available out of the box). Additional tools such as Snyk, or GitHub Dependabot can also be configured.*

![AI Code Review Agent's output screenshot](https://github.com/gitbito/codereviewagent/assets/22556762/fca4a038-2281-41bf-b0eb-3c43136a68a5)

---

## Need Support? We're Ready to Assist!
For comprehensive information and guidance on the AI Code Review Agent, including installation and configuration instructions, please refer to our detailed **[documentation available here](https://docs.bito.ai/bito-dev-agents/ai-code-review-agent)**. Should you require further assistance or have any inquiries, our support team is readily available to assist you.

Feel free to reach out to us via email at: **[support@bito.ai](mailto:support@bito.ai)**


Testing fork branch
