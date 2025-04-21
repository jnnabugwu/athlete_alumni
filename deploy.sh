#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting deployment process for Athlete Alumni app..."

# Clean any previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build the web app in release mode
echo "🔨 Building web app in release mode..."
flutter build web --release

# Verify the build
if [ -d "build/web" ]; then
  echo "✅ Build completed successfully!"
else
  echo "❌ Build failed. Directory build/web not found."
  exit 1
fi

# Prompt for deployment
read -p "Do you want to deploy to Firebase now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "🔥 Deploying to Firebase..."
  firebase deploy --only hosting
  
  echo "🎉 Deployment complete! Your app should be available shortly."
  echo "Visit https://athlete-alumni.web.app to see your deployed app."
else
  echo "📋 Deployment skipped. You can manually deploy later with:"
  echo "firebase deploy --only hosting"
fi

echo "Done! 🏁" 