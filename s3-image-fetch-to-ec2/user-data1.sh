#!/bin/bash
apt update
apt install -y apache2

# Get the instance ID using the instance metadata ( this ip is fixed)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install the AWS CLI
apt install -y awscli

# Download the images from S3 bucket
#aws s3 cp s3://mybk-12121/project.webp /var/www/html/project.png --acl public-read

# Create a simple HTML file with the portfolio content and display the images
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My Portfolio</title>
</head>
<body>
  <h1>Terraform Project Server 1</h1>
  <h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>
  <br>
  <img src="project.png" alt="Girl in a jacket" width="500" height="600"> 
  <p>Welcome to Project 1</p>
  
</body>
</html>
EOF

# Start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2


# Examples of cat <<EOF syntax usage in Bash:
# 1. Assign multi-line string to a shell variable

# $ sql=$(cat <<EOF
# SELECT foo, bar FROM db
# WHERE foo='baz'
# EOF
# )

# The $sql variable now holds the new-line characters too. You can verify with echo -e "$sql".
# 2. Pass multi-line string to a file in Bash

# $ cat <<EOF > print.sh
# #!/bin/bash
# echo \$PWD
# echo $PWD
# EOF

# The print.sh file now contains:

# #!/bin/bash
# echo $PWD
# echo /home/user
