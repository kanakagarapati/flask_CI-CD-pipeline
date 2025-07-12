#!/bin/bash

# Connect to EC2/VM and restart the Flask app
ssh -i ~/your-key.pem ubuntu@<STAGING_SERVER_IP> << EOF
cd ~/flask-ci-app
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart flaskapp
EOF
