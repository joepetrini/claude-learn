# Production Deployment Guide

This guide walks you through deploying the Claude Learn application to production using GitHub Pages with Supabase as the backend.

## Prerequisites

Before deploying, ensure you have:

- GitHub account with repository access
- Supabase project set up
- Domain name (optional, for custom domain)
- Node.js 18+ installed locally

## 1. Supabase Production Setup

### Database Configuration

1. **Create Production Supabase Project**
   ```bash
   # Go to https://supabase.com/dashboard
   # Create a new project for production
   ```

2. **Set up Database Schema**
   ```sql
   -- Run the complete schema from docs/database-schema.sql
   -- This includes all tables, RLS policies, and constraints
   ```

3. **Configure Row Level Security**
   ```sql
   -- Ensure RLS is enabled on all tables
   ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
   ALTER TABLE module_progress ENABLE ROW LEVEL SECURITY;
   ALTER TABLE section_progress ENABLE ROW LEVEL SECURITY;
   ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
   ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
   ```

4. **Set up Storage (Optional - for avatars)**
   ```sql
   -- Create storage bucket for user avatars
   INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
   
   -- Set storage policies
   CREATE POLICY "Users can upload own avatar" ON storage.objects
     FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
   
   CREATE POLICY "Avatars are publicly accessible" ON storage.objects
     FOR SELECT USING (bucket_id = 'avatars');
   ```

### Google OAuth Setup

1. **Google Cloud Console Setup**
   ```
   1. Go to Google Cloud Console (console.cloud.google.com)
   2. Create new project or select existing
   3. Enable Google+ API
   4. Create OAuth 2.0 credentials
   5. Add authorized redirect URIs:
      - https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
      - https://YOUR_DOMAIN.com (for production domain)
   ```

2. **Supabase Auth Configuration**
   ```
   1. Go to Supabase Dashboard > Authentication > Providers
   2. Enable Google provider
   3. Add Client ID and Client Secret from Google Cloud
   4. Set redirect URL to your production domain
   ```

### Environment Variables

Set these in your Supabase project settings:

```env
# Required for production
SITE_URL=https://your-domain.com
ADDITIONAL_REDIRECT_URLS=https://your-domain.com,https://your-domain.com/**
```

## 2. Application Configuration

### Production Environment Setup

1. **Update Vite Configuration**
   ```javascript
   // vite.config.js
   export default defineConfig({
     plugins: [vue()],
     base: '/claude-learn/', // Set to your repository name
     build: {
       outDir: 'dist',
       assetsDir: 'assets',
       sourcemap: false, // Disable for production
     }
   })
   ```

2. **Environment Variables**
   Create `.env.production`:
   ```env
   VITE_SUPABASE_URL=https://your-project-id.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key
   VITE_APP_URL=https://your-domain.com
   ```

3. **Update Router Configuration**
   ```javascript
   // src/router/index.js
   const router = createRouter({
     history: createWebHashHistory('/claude-learn/'), // Match base path
     routes
   })
   ```

## 3. GitHub Pages Deployment

### Automated Deployment

1. **Create GitHub Actions Workflow**
   ```yaml
   # .github/workflows/deploy.yml
   name: Deploy to GitHub Pages
   
   on:
     push:
       branches: [ main ]
     workflow_dispatch:
   
   permissions:
     contents: read
     pages: write
     id-token: write
   
   concurrency:
     group: "pages"
     cancel-in-progress: false
   
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - name: Checkout
           uses: actions/checkout@v4
         
         - name: Setup Node
           uses: actions/setup-node@v4
           with:
             node-version: 18
             cache: 'npm'
         
         - name: Install dependencies
           run: npm ci
         
         - name: Build
           run: npm run build
           env:
             VITE_SUPABASE_URL: ${{ secrets.VITE_SUPABASE_URL }}
             VITE_SUPABASE_ANON_KEY: ${{ secrets.VITE_SUPABASE_ANON_KEY }}
             VITE_APP_URL: ${{ secrets.VITE_APP_URL }}
         
         - name: Setup Pages
           uses: actions/configure-pages@v4
         
         - name: Upload artifact
           uses: actions/upload-pages-artifact@v2
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
           uses: actions/deploy-pages@v3
   ```

2. **Configure GitHub Repository**
   ```bash
   # In your GitHub repository:
   # 1. Go to Settings > Pages
   # 2. Set Source to "GitHub Actions"
   # 3. Go to Settings > Secrets and Variables > Actions
   # 4. Add repository secrets:
   #    - VITE_SUPABASE_URL
   #    - VITE_SUPABASE_ANON_KEY
   #    - VITE_APP_URL
   ```

### Manual Deployment

If you prefer manual deployment:

```bash
# Build the application
npm run build

# Deploy to GitHub Pages (using gh-pages package)
npm install -g gh-pages
gh-pages -d dist
```

## 4. Custom Domain Setup (Optional)

### DNS Configuration

1. **Add CNAME Record**
   ```
   # In your DNS provider:
   # CNAME: your-domain.com -> your-username.github.io
   ```

2. **GitHub Pages Custom Domain**
   ```
   # In repository Settings > Pages:
   # 1. Set custom domain to your-domain.com
   # 2. Enable "Enforce HTTPS"
   ```

3. **Update Application URLs**
   ```env
   # Update environment variables
   VITE_APP_URL=https://your-domain.com
   
   # Update Supabase redirect URLs
   # Add your-domain.com to allowed origins
   ```

## 5. Performance Optimization

### Build Optimization

```javascript
// vite.config.js
export default defineConfig({
  plugins: [vue()],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['vue', 'vue-router'],
          supabase: ['@supabase/supabase-js']
        }
      }
    },
    chunkSizeWarningLimit: 1000
  }
})
```

### Content Delivery

1. **Enable GitHub Pages Caching**
   ```html
   <!-- Add to index.html -->
   <meta http-equiv="cache-control" content="public, max-age=31536000">
   ```

2. **Optimize Images**
   ```bash
   # Compress images in public/images/
   # Use WebP format when possible
   # Implement lazy loading for large images
   ```

## 6. Monitoring and Analytics

### Error Tracking

```javascript
// src/main.js
app.config.errorHandler = (error, instance, info) => {
  console.error('Global error:', error, info)
  // Send to your error tracking service
}
```

### Performance Monitoring

```javascript
// Add to src/main.js
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/claude-learn/sw.js')
}
```

## 7. Security Considerations

### Content Security Policy

```html
<!-- Add to index.html -->
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  connect-src 'self' https://*.supabase.co;
">
```

### Environment Security

1. **Secure Environment Variables**
   ```bash
   # Never commit .env files to repository
   # Use GitHub Secrets for sensitive data
   # Rotate Supabase keys regularly
   ```

2. **Database Security**
   ```sql
   -- Regularly audit RLS policies
   -- Monitor database access logs
   -- Keep Supabase project updated
   ```

## 8. Maintenance

### Regular Tasks

1. **Dependencies**
   ```bash
   # Monthly dependency updates
   npm audit
   npm update
   ```

2. **Database Maintenance**
   ```sql
   -- Monitor database size
   -- Clean up old quiz attempts if needed
   -- Backup important data
   ```

3. **Monitoring**
   ```bash
   # Check application logs
   # Monitor Supabase usage
   # Review user feedback
   ```

## 9. Troubleshooting

### Common Issues

1. **OAuth Redirect Issues**
   ```
   Problem: "Invalid redirect URL"
   Solution: Ensure all redirect URLs are configured in both Google Cloud and Supabase
   ```

2. **Build Failures**
   ```bash
   # Check environment variables
   # Verify Supabase connectivity
   # Review build logs in GitHub Actions
   ```

3. **Database Connection Issues**
   ```
   Problem: RLS policy errors
   Solution: Review and fix policies using docs/fix-rls-policies.sql
   ```

### Debug Mode

```javascript
// Add to src/main.js for debugging
if (import.meta.env.DEV) {
  window.supabase = supabase // Global access for debugging
}
```

## 10. Rollback Plan

### Emergency Rollback

```bash
# If deployment fails:
# 1. Revert to previous GitHub commit
git revert HEAD

# 2. Or deploy specific version
gh-pages -d dist -f
```

### Database Rollback

```sql
-- Keep database backups
-- Document schema changes
-- Test rollback procedures
```

---

## Quick Deployment Checklist

- [ ] Supabase project configured
- [ ] Google OAuth set up
- [ ] Environment variables added to GitHub Secrets
- [ ] GitHub Actions workflow created
- [ ] Database schema deployed
- [ ] RLS policies configured
- [ ] Storage bucket created (if using avatars)
- [ ] Custom domain configured (optional)
- [ ] SSL certificate enabled
- [ ] Error monitoring set up
- [ ] Performance monitoring configured

## Support

For deployment issues:
1. Check GitHub Actions logs
2. Review Supabase dashboard logs
3. Test locally with production environment variables
4. Consult the troubleshooting section above

---

**Note**: This deployment guide assumes familiarity with GitHub, Supabase, and basic DevOps concepts. For additional help, consult the official documentation for each service.