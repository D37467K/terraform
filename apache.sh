      #!/bin/bash
        sudo yum update -y
        sudo yum install httpd -y
        sudo service httpd restart
        cd /var/www/html
        echo "Hi This is Terraform" > index.html
