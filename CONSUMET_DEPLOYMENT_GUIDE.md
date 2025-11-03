# Consumet API Deployment Guide

**Status:** Required for Phase 1 Migration
**Estimated Time:** 30-60 minutes

---

## Option 1: Railway.app (Recommended for Beginners) 🚀

Railway is the easiest way to deploy Consumet with a free tier.

### Step-by-Step Deployment

#### 1. Sign Up for Railway
1. Go to [railway.app](https://railway.app)
2. Click "Start a New Project" (sign up with GitHub)
3. Free tier includes:
   - $5 free credit per month
   - 512MB RAM
   - 1GB Disk
   - Sufficient for testing/personal use

#### 2. Deploy Consumet
```bash
# Option A: One-Click Deploy (Easiest)
1. Visit: https://railway.app/template/consumet
2. Click "Deploy Now"
3. Wait 2-3 minutes for deployment
4. Copy your deployment URL: https://your-app.up.railway.app

# Option B: From GitHub
1. Click "New Project" → "Deploy from GitHub repo"
2. Connect GitHub account
3. Search for "consumet/api.consumet.org"
4. Select repository and deploy
5. Railway will auto-detect and deploy
```

#### 3. Get Your API URL
After deployment:
1. Click on your deployed project
2. Go to "Settings" → "Domains"
3. You'll see: `https://your-app-name.up.railway.app`
4. **Save this URL** - you'll need it for the Flutter app

#### 4. Test Your Deployment
```bash
# Test search endpoint
curl https://your-app.up.railway.app/anime/gogoanime/naruto

# Expected response: JSON array with anime results
{
  "currentPage": 1,
  "hasNextPage": true,
  "results": [
    {
      "id": "naruto",
      "title": "Naruto",
      "url": "https://...",
      "image": "https://...",
      "releaseDate": "2002",
      "subOrDub": "sub"
    }
  ]
}
```

#### 5. Add to Flutter App
```dart
// lib/config/api_config.dart
class ApiConfig {
  // Replace with your Railway URL
  static const String consumetBaseUrl = 'https://your-app.up.railway.app';
}
```

---

## Option 2: Render.com (Free Tier Alternative)

Render offers a free tier with some limitations.

### Deployment Steps

1. **Sign Up**
   - Go to [render.com](https://render.com)
   - Sign up with GitHub

2. **Create New Web Service**
   ```
   - Click "New +" → "Web Service"
   - Connect GitHub: consumet/api.consumet.org
   - Name: consumet-api
   - Region: Choose closest to you
   - Branch: main
   - Build Command: npm install
   - Start Command: npm start
   - Plan: Free
   ```

3. **Wait for Deployment**
   - Takes 5-10 minutes
   - URL will be: `https://consumet-api.onrender.com`

4. **Test**
   ```bash
   curl https://your-app.onrender.com/anime/gogoanime/naruto
   ```

**Note:** Free tier has cold starts (may take 30s to wake up after inactivity).

---

## Option 3: Vercel (Serverless)

Good for low traffic, but has limitations.

### Deployment Steps

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Clone Consumet Repo**
   ```bash
   git clone https://github.com/consumet/api.consumet.org.git
   cd api.consumet.org
   ```

3. **Deploy**
   ```bash
   vercel deploy
   # Follow prompts
   # Login with GitHub
   # Confirm deployment
   ```

4. **Get URL**
   ```bash
   vercel --prod
   # Returns: https://your-app.vercel.app
   ```

**Limitations:**
- 10s execution timeout (may cause issues with video fetching)
- Better for metadata only

---

## Option 4: Docker on VPS (For Production)

If you have your own server or VPS (AWS, DigitalOcean, etc.).

### Prerequisites
- VPS with Docker installed
- SSH access
- Domain name (optional)

### Deployment Steps

#### 1. Install Docker
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
```

#### 2. Deploy Consumet
```bash
# Pull and run Consumet
sudo docker run -d \
  --name consumet \
  --restart unless-stopped \
  -p 3000:3000 \
  ghcr.io/consumet/api:latest

# Check logs
sudo docker logs consumet

# Test
curl http://localhost:3000/anime/gogoanime/naruto
```

#### 3. Setup Nginx Reverse Proxy (Optional)
```bash
# Install Nginx
sudo apt install nginx

# Create config
sudo nano /etc/nginx/sites-available/consumet

# Add:
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/consumet /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 4. Setup SSL with Let's Encrypt
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourdomain.com
```

---

## Cost Comparison

| Platform | Free Tier | Paid | Best For |
|----------|-----------|------|----------|
| **Railway** | $5 credit/month | $10+/month | Easiest setup |
| **Render** | 750 hours/month | $7+/month | Good balance |
| **Vercel** | Unlimited | $20/month | Serverless |
| **VPS (DigitalOcean)** | - | $6+/month | Full control |
| **AWS EC2** | 1 year free tier | $5+/month | Enterprise |

---

## Recommended: Railway for Phase 1

For this migration, I recommend **Railway.app** because:
- ✅ Easiest to deploy (5 minutes)
- ✅ Free $5 credit per month
- ✅ Auto-deploys updates
- ✅ Good for development and testing
- ✅ Can upgrade later if needed

### Quick Start with Railway

```bash
# 1. Visit Railway template
https://railway.app/template/consumet

# 2. Click "Deploy Now"

# 3. Wait 2-3 minutes

# 4. Get your URL from dashboard

# 5. Test it:
curl https://your-app.up.railway.app/anime/gogoanime/naruto

# 6. Add to Flutter app config
```

---

## Next Steps After Deployment

Once you have your Consumet URL:

1. **Create API Config**
   ```dart
   // lib/config/api_config.dart
   class ApiConfig {
     static const String consumetBaseUrl =
       'https://your-consumet-instance.com';

     static const String jikanBaseUrl =
       'https://api.jikan.moe/v4';
   }
   ```

2. **Create Consumet Repository**
   - See: `lib/data/repositories/consumet_repository.dart`
   - Will be created in Phase 2

3. **Test Endpoints**
   ```dart
   // Test in Flutter
   final dio = Dio();
   final response = await dio.get(
     '${ApiConfig.consumetBaseUrl}/anime/gogoanime/naruto'
   );
   print(response.data);
   ```

---

## Troubleshooting

### Issue: Deployment Failed
**Solution:** Check Railway logs in dashboard, ensure repository is public

### Issue: API Returns 404
**Solution:** Wait 5 minutes after deployment, Consumet is initializing

### Issue: Slow Response
**Solution:**
- Railway free tier may be slow
- Consider upgrading or using VPS
- Add caching in Flutter app

### Issue: Rate Limiting
**Solution:**
- Implement request caching
- Add debouncing for search
- Consider multiple provider fallbacks

---

## Security Considerations

1. **Environment Variables**
   - Store Consumet URL in environment variables
   - Don't hardcode in source code

2. **Rate Limiting**
   - Implement client-side rate limiting
   - Cache responses when possible

3. **Error Handling**
   - Always handle API failures gracefully
   - Provide fallback to alternative providers

4. **HTTPS Only**
   - All deployment options provide HTTPS
   - Never use HTTP in production

---

## Monitoring

### Railway Dashboard
- View logs in real-time
- Monitor usage and billing
- Set up alerts

### Health Check Endpoint
```bash
# Check if Consumet is running
curl https://your-app.up.railway.app/

# Expected: HTML page or JSON with API info
```

---

## Support

If you encounter issues:

1. **Consumet GitHub**: https://github.com/consumet/api.consumet.org/issues
2. **Railway Support**: https://railway.app/help
3. **Consumet Discord**: https://discord.gg/qTPfvMxzNH

---

**Ready?** Deploy Consumet now and return here with your API URL to continue Phase 1!
