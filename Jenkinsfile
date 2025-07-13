pipeline {
    agent {
        label 'manoj_agent' // your custom build agent label
    }

    environment {
        EC2_IP = '35.160.245.31'
        PROJECT_DIR = '/home/ubuntu/flask_CI-CD-pipeline'
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
                sshagent(credentials: ['manojg']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@$EC2_IP << 'EOF'
                            echo "➡ Killing any running Flask apps (if any)..."
                            pkill -f "python app.py" || true

                            echo "➡ Cleaning previous deployment and cloning latest code..."
                            rm -rf $PROJECT_DIR
                            git clone https://github.com/kanakagarapati/flask_CI-CD-pipeline.git $PROJECT_DIR

                            echo "➡ Creating virtualenv and installing requirements..."
                            cd $PROJECT_DIR/Jenkins_Pipeline
                            python3 -m venv venv
                            ./venv/bin/pip install -r ../requirements.txt

                            echo "➡ Running pytest (if any tests exist)..."
                            ./venv/bin/python -m pytest tests/ || true

                            echo "➡ Starting Flask app in background..."
                            nohup ./venv/bin/python app.py > flask.log 2>&1 &
                        EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed at one or more stages.'
        }
    }
}