# GitHub Pages Deployment Guide

## Overview
This static site is perfectly suited for GitHub Pages hosting. It's free, fast, and automatically deploys when you push to your repository.

## Setup Steps

### 1. Repository Configuration
```bash
# Initialize git repository
git init
git add .
git commit -m "Initial commit"

# Create repository on GitHub (via CLI or web)
gh repo create claude-learn --public

# Push to GitHub
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/claude-learn.git
git push -u origin main
```

### 2. Vite Configuration for GitHub Pages
Create/update `vite.config.js`:
```javascript
import { defineConfig } from 'vite'

export default defineConfig({
  base: '/claude-learn/',  // Replace with your repo name
  build: {
    outDir: 'dist'
  }
})
```

### 3. GitHub Actions Workflow
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: ['main']
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: 'pages'
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build
        run: npm run build
        
      - name: Setup Pages
        uses: actions/configure-pages@v4
        
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: './dist'

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### 4. Package.json Scripts
Add deployment script to `package.json`:
```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "deploy": "npm run build && gh-pages -d dist"
  },
  "devDependencies": {
    "gh-pages": "^6.0.0"
  }
}
```

### 5. Enable GitHub Pages
1. Go to your repository settings
2. Navigate to "Pages" section
3. Under "Build and deployment", select "GitHub Actions"

## Alternative: Manual Deployment
If you prefer manual deployment:
```bash
npm install --save-dev gh-pages
npm run build
npx gh-pages -d dist
```

## Important Considerations

### Asset Paths
Ensure all asset paths work with the base URL:
```javascript
// In your JavaScript files
const baseUrl = import.meta.env.BASE_URL || '/';
const moduleData = await fetch(`${baseUrl}data/modules.json`);
```

### Custom Domain (Optional)
1. Add a `CNAME` file in your `public` directory with your domain
2. Configure DNS settings with your domain provider
3. Enable custom domain in GitHub Pages settings

## URL Structure
Your app will be available at:
- Default: `https://YOUR_USERNAME.github.io/claude-learn/`
- Custom domain: `https://your-domain.com/`

## Updating Content
Since content is in JSON files, updating is simple:
1. Edit JSON files in `data/` directory
2. Commit and push to main branch
3. GitHub Actions will automatically rebuild and deploy

## Benefits
- ✅ Free hosting
- ✅ Automatic HTTPS
- ✅ CDN distribution
- ✅ Automatic deployments
- ✅ Version control for content
- ✅ Easy rollbacks

## Troubleshooting

### 404 Errors
If you get 404 errors for assets:
- Check the `base` setting in `vite.config.js`
- Ensure all paths are relative
- Clear browser cache

### Build Failures
- Check GitHub Actions logs
- Ensure all dependencies are in `package.json`
- Test build locally with `npm run build`

### Content Updates Not Showing
- GitHub Pages has caching
- Wait a few minutes
- Try hard refresh (Ctrl+Shift+R)
- Check deployment status in Actions tab