# 🚀 GitHub Pages Deployment Setup

This project is pre-configured to build and deploy to GitHub Pages automatically using GitHub Actions whenever changes
are pushed to the `main` branch.

### Prerequisites & Required Actions (MUST READ)

Because this is a Flutter web app deployed to GitHub Pages, you need to perform the following step-by-step setup before
your first deployment:

1. **Verify/Change the Base Href:**
    - Open `.github/workflows/deploy.yml`.
    - Locate the `flutter build web --release --base-href "/password_generator/"` line.
    - If your GitHub repository name is **not** `password_generator` (e.g. your repository is named
      `my-secure-generator`), change `"/password_generator/"` to `"/my-secure-generator/"`. The path **must** start and
      end with a forward slash `/`.
    - If you are deploying to a custom domain (e.g., `https://example.com`) or a user/organization page (e.g.,
      `https://username.github.io/` directly, not in a subfolder), change the base href to `"/"`.

2. **Initialize Git and Push to GitHub:**
   If you haven't initialized Git and pushed to GitHub yet, run the following commands in your local project root:
   ```bash
   git init
   git add .
   git commit -m "Initial commit and GitHub Pages setup"
   git branch -M main
   git remote add origin https://github.com/your-username/your-repo-name.git
   git push -u origin main
   ```

3. **Configure GitHub Repository Settings:**
   Once you push to GitHub:
    - Go to your repository on GitHub.
    - Navigate to **Settings** > **Actions** > **General**.
    - Scroll down to **Workflow permissions** and select **Read and write permissions**, then click **Save**. (This
      allows the deployment action to push the built files to the `gh-pages` branch).
    - Navigate to **Settings** > **Pages**.
    - Under **Branch**, select `gh-pages` and folder `/ (root)`, then click **Save**.

---