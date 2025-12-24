New-Item -ItemType Directory -Force -Path "frontend\assets"
# Create a dummy poster.jpg to stop 404s (user can replace later)
Set-Content -Path "frontend\assets\poster.jpg" -Value "Dummy Image"
