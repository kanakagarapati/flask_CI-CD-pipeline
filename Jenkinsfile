pipeline {
    agent { label 'manoj_agent' }

    environment {
        EC2_HOST = '35.160.245.31'                             // Replace with your EC2 IP
        SSH_KEY_ID = 'ubuntu'                                  // Jenkins credential ID
        DEPLOY_DIR = '/home/ubuntu/flask_CI-CD-pipeline'      // EC2 deploy directory
        EC2_USERNAME = 'ubuntu'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/kanakagarapati/flask_CI-CD-pipeline.git', branch: 'main'
            }
        }

        stage('Install & Test Locally') {
            steps {
                sh 'python3 -m venv venv'
                sh './venv/bin/pip install -r requirements.txt'
                sh './venv/bin/python -m pytest Jenkins_Pipeline/tests/ || true'
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: [env.SSH_KEY_ID]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${EC2_USERNAME}@${EC2_HOST} << 'EOF'
                        echo "➡ Killing any running Flask apps..."
                        pkill -f "python app.py" || true

                        echo "➡ Cleaning old deployment and cloning new repo..."
                        rm -rf ${DEPLOY_DIR}
                        git clone https://github.com/kanakagarapati/flask_CI-CD-pipeline.git ${DEPLOY_DIR}

                        echo "➡ Installing dependencies..."
                        cd ${DEPLOY_DIR}
                        python3 -m venv venv
                        ./venv/bin/pip install -r requirements.txt

                        echo "➡ Running pytest on EC2..."
                        ./venv/bin/python -m pytest Jenkins_Pipeline/tests/ || true

                        echo "➡ Starting Flask app in background..."
                        cd Jenkins_Pipeline
                        nohup ../venv/bin/python app.py > ../flask.log 2>&1 &
                    EOF
                    """
                }
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed at one or more stages."
        }
        success {
            echo "✅ Deployment completed successfully."
        }
    }
}