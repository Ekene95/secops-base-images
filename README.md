# 📁 SecOps Base Images: Wolfi-Java

![Security Status](https://img.shields.io/badge/Security-0--CVE-brightgreen)
![Build Status](https://img.shields.io/badge/Build-Verified-blue)
![Java Version](https://img.shields.io/badge/Java-24-orange)
![Provenance](https://img.shields.io/badge/Signed-Cosign-blueviolet)

This repository maintains the **Organization’s Gold Standard** for Java-based container environments. It utilizes the [Wolfi (Chainguard)](https://wolfi.dev/) ecosystem to provide a minimalist, high-performance, and cryptographically signed runtime.

---

## 🚀 Key Value Propositions

Unlike legacy images (e.g., `openjdk:alpine` or `debian-slim`), this image is engineered for the modern DevSecOps pipeline:

* **Zero Known Vulnerabilities (CVEs):** Maintained via daily rolling updates from Wolfi and verified with Trivy.
* **Non-Root by Default:** Runs as `appuser` (UID 1000) out of the box. No more `RUN adduser` in your app Dockerfiles.
* **Performance:** Built with `glibc` for superior mathematical and cryptographic execution speed compared to `musl`.
* **Ultra-Lean:** * **Content Size:** ~121MB (33% smaller than standard Corretto images).
    * **Idle Memory Usage:** **708 KiB** (Measured via Docker Stats).

---

## 🛠 Usage for Developers

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


## 🔐 Verification & Supply Chain Security

Every image in this repository is digitally signed via **Cosign** using GitHub Actions' OIDC identity. This ensures the image has not been tampered with and originated from our authorized CI/CD pipeline.

To verify the integrity of the image before deployment, run:

```bash
cosign verify [your-docker-hub-id]/mpnt-wolfi-java:latest \
  --certificate-identity-regexp "[https://github.com/](https://github.com/)[your-org]/[your-repo]/.github/workflows/.*" \
  --certificate-oidc-issuer "[https://token.actions.githubusercontent.com](https://token.actions.githubusercontent.com)"
