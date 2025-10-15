wget -q "https://packages.microsoft.com/config/debian/$(lsb_release -rs)/packages-microsoft-prod.deb"
dpkg -i packages-microsoft-prod.deb

apt-get update && apt-get install -y powershell