
# Create a new instance
resource "google_compute_instance" "vm_instance" {
   name = "jenkins-instance"
   machine_type = "n1-standard-1"
   zone = "us-central1-c"

   boot_disk {
      initialize_params {
      image = "centos-cloud/centos-7"
      }
   }

   network_interface {
      network = "default"
      access_config {}
   }

   metadata_startup_script = <<SCRIPT
   #Ansible
   sudo yum -y install epel-release
   sudo yum -y install ansible
   #Amazon Corretto
   sudo yum -y update
   sudo yum -y install wget
   sudo wget https://d2znqt9b1bc64u.cloudfront.net/java-1.8.0-amazon-corretto-devel-1.8.0_202.b08-2.x86_64.rpm
   sudo rpm -i java-1.8.0-amazon-corretto-devel-1.8.0_202.b08-2.x86_64.rpm
   #Jenkins
   curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
   sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
   sudo yum -y install fontconfig
   sudo yum -y upgrade && sudo yum -y install jenkins
   sudo systemctl start jenkins
   sudo systemctl enable jenkins
   sudo /sbin/chkconfig jenkins on
   #Maven
   sudo mkdir tmp
   sudo wget https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -P /tmp
   sudo mkdir opt
   sudo tar xf /tmp/apache-maven-3.6.0-bin.tar.gz -C /opt
   sudo ln -s /opt/apache-maven-3.6.0 /opt/maven
   sudo systemctl restart jenkins
   sudo touch /etc/environment
   sudo cat <<EOF | sudo tee -a /etc/environment
   PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/jvm/java-1.8.0-amazon-corretto/bin:/opt/apache-maven-3.6.0/bin"
   JAVA_HOME="/usr/lib/jvm/java-1.8.0-amazon-corretto"
   M2_HOME="/opt/apache-maven-3.6.0"
   EOF
   sudo update-alternatives --install "/usr/bin/mvn" "mvn" "/opt/apache-maven-3.6.0/bin/mvn" 0
   sudo update-alternatives --set mvn /opt/apache-maven-3.6.0/bin/mvn
   sudo wget https://raw.github.com/dimaj/maven-bash-completion/master/bash_completion.bash --output-document /etc/bash_completion.d/mvn
   SCRIPT

   service_account {
      scopes = ["userinfo-email", "compute-ro", "storage-ro"]
      }
}

