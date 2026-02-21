# SecOps Base Images

![Security Status](https://img.shields.io/badge/Security-0--CVE-brightgreen)
![Build Status](https://img.shields.io/badge/Build-Verified-blue)
![Java Version](https://img.shields.io/badge/Java-17_|_21_|_24_|_25-orange)
![Go Version](https://img.shields.io/badge/Go-1.24-00ADD8)
![Node Version](https://img.shields.io/badge/Node-20_|_22_|_24-339933)
![Python Version](https://img.shields.io/badge/Python-3.13-3776AB)
![Provenance](https://img.shields.io/badge/Signed-Cosign-blueviolet)
![SBOM](https://img.shields.io/badge/SBOM-SPDX-blue)

This repository maintains the **Organization’s Gold Standard** for container environments. It utilizes the [Wolfi (Chainguard)](https://wolfi.dev/) ecosystem to provide minimalist, high-performance, and cryptographically signed runtimes for Java, Node.js, Python, and Go.

---

## Security & Build Dashboard
| Base Image | Build Status | Security Scan | Registry |
| :--- | :--- | :--- | :--- |
| **Wolfi-Java** (17/21/24/25) | [![Java Status](https://github.com/Ekene95/secops-base-images/actions/workflows/java-ci.yaml/badge.svg)](https://github.com/Ekene95/secops-base-images/actions/workflows/java-ci.yaml) | ![Trivy](https://img.shields.io/badge/trivy-verified-brightgreen?logo=trivy) | [Docker Hub](https://hub.docker.com/r/kenzman/mpnt-wolfi-java) |
| **Wolfi-Node** (20/22/24) | [![Node Status](https://github.com/Ekene95/secops-base-images/actions/workflows/node-ci.yaml/badge.svg)](https://github.com/Ekene95/secops-base-images/actions/workflows/node-ci.yaml) | ![Trivy](https://img.shields.io/badge/trivy-verified-brightgreen?logo=trivy) | [Docker Hub](https://hub.docker.com/r/kenzman/ns-wolfi-node) |
| **Wolfi-Python** | [![Python Status](https://github.com/Ekene95/secops-base-images/actions/workflows/py-ci.yaml/badge.svg)](https://github.com/Ekene95/secops-base-images/actions/workflows/py-ci.yaml) | ![Trivy](https://img.shields.io/badge/trivy-verified-brightgreen?logo=trivy) | [Docker Hub](https://hub.docker.com/r/kenzman/ns-wolfi-python) |
| **Wolfi-Go** | [![Go Status](https://github.com/Ekene95/secops-base-images/actions/workflows/go-ci.yaml/badge.svg)](https://github.com/Ekene95/secops-base-images/actions/workflows/go-ci.yaml) | ![Trivy](https://img.shields.io/badge/trivy-verified-brightgreen?logo=trivy) | [Docker Hub](https://hub.docker.com/r/kenzman/ns-wolfi-go) |

> **Audit Note:** All images follow a strict **Shift-Left** pipeline: Local Build → Trivy Scan → Publish → Cosign Sign → **SBOM Generation**. A "Passing" build status is cryptographic proof of a clean security scan. SBOM artifacts (SPDX format) are attached to every build.

---

## Key Value Propositions

Unlike legacy images (e.g., `openjdk:alpine` or `debian-slim`), this image is engineered for the modern DevSecOps pipeline:

* **Zero Known Vulnerabilities (CVEs):** Maintained via daily rolling updates from Wolfi and verified with Trivy.
* **Non-Root by Default:** Runs as `appuser` (UID 1000) out of the box. No more `RUN adduser` in your app Dockerfiles.
* **Performance:** Built with `glibc` for superior mathematical and cryptographic execution speed compared to `musl`.
* **Ultra-Lean:** * **Content Size:** ~121MB (33% smaller than standard Corretto images).
* **Idle Memory Usage:** **708 KiB** (Measured via Docker Stats).

---

## Usage for Developers

To use this image in your application, update your `Dockerfile` as follows. This ensures you inherit the hardened security context and pre-configured environment variables (`JAVA_HOME`, `PATH`).

```dockerfile
# --- Stage 1: Build ---
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY . .
RUN mvn package -DskipTests

# --- Stage 2: Hardened Runtime ---
FROM [your-docker-id]/mpnt-wolfi-java:latest

# Use home directory of pre-configured 'appuser'
WORKDIR /home/appuser

# Copy the artifact from build stage
COPY --from=build /app/target/*.jar app.jar

# Application inherits the 0-CVE OS and non-root execution context
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

## Verification & Supply Chain Security

Every image in this repository is digitally signed via **Cosign** using GitHub Actions' OIDC identity. This ensures the image has not been tampered with and originated from our authorized CI/CD pipeline.

To verify the integrity of the image before deployment, run:

```bash
cosign verify [your-docker-hub-id]/mpnt-wolfi-java:latest \
  --certificate-identity-regexp "(https://github.com/)[your-org]/[your-repo]/.github/workflows/.*" \
  --certificate-oidc-issuer "(https://token.actions.githubusercontent.com)"
```

---

## Performance Benchmarks

Validated on internal lab hardware:

| Metric | Result | Note |
| :--- | :--- | :--- |
| **Idle Memory** | 708 KiB | Ultra-lean footprint; minimal OS overhead |
| **Startup (JIT Warmup)** | <100ms | Verified with 50M parallel math operations |
| **Disk Usage** | 450 MB | Total uncompressed size (including JDK) |
| **User Context** | Non-Root | Verified execution as `appuser` (UID 1000) |
