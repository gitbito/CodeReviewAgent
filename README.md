<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

[![Visit bito.ai][bito-shield]][bito-url]
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://bito.ai/product/ai-code-review-agent/">
    <img src="https://github.com/user-attachments/assets/d06b4dcf-9234-4d9a-be65-1e6f1ecfe5fa" alt="Logo" width="150">
  </a>

  <h3 align="center">AI Code Review Agent</h3>

  <p align="center">
    On-demand, context-aware code reviews in your Git workflow or IDE as you code.
    <br />
    <a href="https://docs.bito.ai/bito-dev-agents/ai-code-review-agent"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://www.youtube.com/watch?v=ZrfSDANgboU">View a demo</a>
    ·
    <a href="https://alpha.bito.ai/home/welcome">Signup for free</a>
    ·
    <a href="https://bit.ly/BitoSlack">Join the community in Slack</a>
  </p>
</div>

<br />

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About the project</a>
    </li>
    <li>
      <a href="#getting-started">Getting started</a>
    </li>
    <li>
      <a href="#why-use-ai-for-code-review">Why use AI for code review?</a>
    </li>
    <li>
      <a href="#key-features">Key features</a>
    </li>
    <li>
      <a href="#screenshots">Screenshots</a>
    </li>
    <li>
      <a href="#need-support-were-ready-to-assist">Need support? We're ready to assist!</a>
    </li>

  </ol>
</details>

<br />

<!-- ABOUT THE PROJECT -->

## About the project

> _Click the image below to watch the demo video on YouTube._

[![See Bito's AI Code Review work](https://i.imgur.com/iUFnfuK.png)](https://youtu.be/WukH9rA_5go "See Bito's AI Code Review work")

Bito’s **[AI Code Review Agent](https://bito.ai/ai-code-review-agent/)** is the first agent built with **Bito’s AI Agent framework and engine**. It is an automated AI assistant (powered by Anthropic’s Claude Sonnet 3.5) that will review your team’s code; it spots bugs, issues, code smells, and security vulnerabilities in Pull/Merge Requests (PR/MR) and provides high-quality suggestions to fix them.

It seamlessly **integrates with Git providers such as GitHub, GitLab, and Bitbucket**, automatically posting recommendations directly as comments within the corresponding Pull Request. It includes real-time recommendations from static analysis and OSS vulnerability tools such as fbinfer, Dependency-Check, etc., and can include high severity suggestions from other 3rd party tools you use such as Snyk or Sonar.

The AI Code Review Agent is equipped with advanced code understanding capabilities, allowing it to analyze your entire codebase in depth. This results in more context-aware insights and suggestions, providing a tailored and highly relevant code review experience that aligns with the specific needs of your project.

The AI Code Review Agent ensures a secure and confidential experience without compromising on reliability. Bito neither reads nor stores your code, and none of your code is used for AI model training. Learn more about our **[Privacy & Security practices](https://docs.bito.ai/privacy-and-security)**.

<br />

<!-- GETTING STARTED -->

## Getting started

There are three ways to use the AI Code Review Agent.

**1- Bito Cloud:** Offers a hassle-free experience with no installation required on your machine.
[Follow this guide](https://docs.bito.ai/bito-dev-agents/ai-code-review-agent/getting-started/install-run-using-bito-cloud)

**2- Self-hosted service via CLI, webhooks, or GitHub Actions:** Ideal for deployments within your own infrastructure.
[Follow this guide](https://docs.bito.ai/bito-dev-agents/ai-code-review-agent/getting-started/install-run-as-a-self-hosted-service)

**3- AI code reviews in IDE:** Get instant feedback on your code changes directly within VS Code or JetBrains IDEs.
[Follow this guide](https://docs.bito.ai/bito-dev-agents/ai-code-review-agent/getting-started/ai-code-reviews-in-ide)

<br />

## Why use AI for code review?

- **Time saving:** Can reduce code review time by up to 50%.
- **Quality improvement:** Enhances code review quality.
- **Support role:** Assists senior software engineers, focusing on mundane review tasks.

<br />

## Key features

- **AI code review:** AI analyzes your code changes to identify issues related to security, performance, scalability, optimization, impact on existing features, code structure, and coding standards.
- **Deep code understanding:** Deep understanding of your code including libraries, frameworks, functionality to improve code review.
- **Real-time feedback:** Get instant code review feedback in VS Code and all JetBrains IDEs.
- **Pull request (PR) summary:** Quick overview of pull request.
- **Feedback in pull requests**: Posts review comments directly in pull requests.
- **Estimated effort to review:** Evaluates complexity for better planning.
- **Tailored code suggestions:** Provides specific line-by-line code improvement suggestions.
- **Static code analysis:** Uses tools like fbinfer, supports integration with tools like Sonar and more.
- **Security vulnerability check:** Uses tools like OWASP Dependency-Check for detecting high-severity vulnerabilities in the open source projects you use.

<br />

## Screenshots


### Screenshot # 1

> _AI-generated pull request (PR) summary_
<br />

<kbd>
  <img src="https://github.com/user-attachments/assets/9ef02020-4382-4b4a-8c08-9d647b5da78f" alt="AI-generated pull request (PR) summary" />
</kbd>

<br />

---

<br />

### Screenshot # 2

> _Code review manually triggered using **/review** command._
<br />

<kbd>
  <img src="https://github.com/user-attachments/assets/4c53b4eb-474e-40aa-b9fd-f10d3ecb022a" alt="Use the /review command to manually trigger a code review." />
</kbd>

<br />

---

<br />

### Screenshot # 3

> _Using tools like Facebook’s open source fbinfer (available out of the box), the Agent thoroughly analyzes your language-specific code and suggests fixes. Tools you use such as Sonar can also be configured._
<br />

<kbd>
  <img src="https://github.com/gitbito/codereviewagent/assets/22556762/1afa9f7e-7f1a-4644-b2fc-36de23aa54ea" alt="Static Code Analysis reports inside AI code review" />
</kbd>

<br />

---

<br />

### Screenshot # 4

> _The Agent checks your code in real-time for high-severity security vulnerabilities using OWASP Dependency-Check (available out of the box). Additional tools like Snyk or GitHub Dependabot can also be configured._
<br />

<kbd>
  <img src="https://github.com/user-attachments/assets/09cee3f1-8b86-4a2d-b509-a0fbab361ce7" alt="AI Code Review Agent checks your code in real-time for high-severity security vulnerabilities using OWASP Dependency-Check" />
</kbd>

<br />

---

<br />

### Screenshot # 5

> _Get instant feedback on your code changes directly within VS Code or JetBrains IDEs._
<br />

<kbd>
  <img src="https://github.com/user-attachments/assets/c6c44cf0-c6e0-4f58-8ab0-de7dc29abb99" alt="Get instant feedback on your code changes directly within VS Code or JetBrains IDEs." />
</kbd>

<br />

---

<br />

## Need support? We're ready to assist!

For comprehensive information and guidance on the AI Code Review Agent, including installation and configuration instructions, please refer to our detailed **[documentation available here](https://docs.bito.ai/bito-dev-agents/ai-code-review-agent)**. Should you require further assistance or have any inquiries, our support team is readily available to assist you.

Feel free to reach out to us via email at: **[support@bito.ai](mailto:support@bito.ai)**





<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[bito-shield]: https://img.shields.io/badge/Visit%20bito.ai-black.svg?style=for-the-badge&colorB=%232baaff
[bito-url]: https://bito.ai/

[contributors-shield]: https://img.shields.io/github/contributors/gitbito/CodeReviewAgent.svg?style=for-the-badge
[contributors-url]: https://github.com/gitbito/CodeReviewAgent/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/gitbito/CodeReviewAgent.svg?style=for-the-badge
[forks-url]: https://github.com/gitbito/CodeReviewAgent/network/members
[stars-shield]: https://img.shields.io/github/stars/gitbito/CodeReviewAgent.svg?style=for-the-badge
[stars-url]: https://github.com/gitbito/CodeReviewAgent/stargazers
[issues-shield]: https://img.shields.io/github/issues/gitbito/CodeReviewAgent.svg?style=for-the-badge
[issues-url]: https://github.com/gitbito/CodeReviewAgent/issues
[license-shield]: https://img.shields.io/github/license/gitbito/CodeReviewAgent.svg?style=for-the-badge
[license-url]: https://github.com/gitbito/CodeReviewAgent?tab=MIT-1-ov-file#readme
