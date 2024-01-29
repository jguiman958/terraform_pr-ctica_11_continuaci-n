# Configuramos el proveedor de AWS
provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAWKPXDFVAGAGHXFVI"
  secret_key = "qmxDEn0QoEFRfIsREX2F5YOY79ut+Nd3u0S8czUh"
  token      = "FwoGZXIvYXdzEEYaDAiixBwBhsYaffu/NCLJAQlOoX4UU41yHCyaGKVeNke1kAzApAhZdFmEWub5vngrcxqKrEAg0tDuN74swiaEFbzLqQTx3oNfMKgKh6x+sh11YK6QcTNLLfpog0jIIu19k/bqgZZU6OFfqyGHAtevigxIogQxIkJe1b2bjqPwVlEj+vGdc7izB443Izdka+PJW+pjTLvreS6cLu8Agz/Zow0uDY8v9cy1HiXNMIC2aqFWwEzgvZE6Vyv5WNgdV2VqKfFfBy5fG4iSVtl9gextAsnwG6fmRDZGJSieuN6tBjIton1H5Lkz8OaHt4oRFAlwauoeHNTbWkrWWclTCxisQOP9ab/S3bAOQ1V3E7CK"
}

# CREACIÓN DE LOS GRUPOS DE SEGURIDAD.
# Creamos un grupo de seguridad para el frontend
resource "aws_security_group" "sg_frontend_terraform_1" {
  name        = "sg_frontend_terraform_1"
  description = "Grupo de seguridad para la instancia de frontend1"

  # Reglas de entrada para permitir el tráfico SSH, HTTP y HTTPS
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas de salida para permitir todas las conexiones salientes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_frontend_terraform_2" {
  name        = "sg_frontend_terraform_2"
  description = "Grupo de seguridad para la instancia de frontend2"

  # Reglas de entrada para permitir el tráfico SSH, HTTP y HTTPS
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas de salida para permitir todas las conexiones salientes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creamos un grupo de seguridad para el servidor nfs.
resource "aws_security_group" "sg_nfs_terraform" {
  name        = "sg_nfs"
  description = "Grupo de seguridad para la instancia de nfs_server"

  # Reglas de entrada para permitir el tráfico SSH, nfs.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas de salida para permitir todas las conexiones salientes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creamos un grupo de seguridad para el balanceador de carga.
resource "aws_security_group" "sg_load_balancer_terraform" {
  name        = "sg_load_balancer_terraform"
  description = "Grupo de seguridad para la instancia de load_balancer"

  # Reglas de entrada para permitir el tráfico SSH, HTTP y HTTPS
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas de salida para permitir todas las conexiones salientes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Grupo de seguridad para el backend
resource "aws_security_group" "sg_backend_terraform" {
  name        = "sg_backend_terraform"
  description = "Grupo de seguridad para la instancia de backend"

  # Reglas de entrada para permitir el tráfico SSH, 3306 e icmp.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Regla para ping--> ICMP.
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas de salida para permitir todas las conexiones salientes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# CREACION DE LAS INSTANCIAS.
# Creamos una instancia EC2 para el frontend 1 y frontend 2.
resource "aws_instance" "frontend_1_terraform" {
  ami             = "ami-0c7217cdde317cfec"
  instance_type   = "t2.small"
  key_name        = "vockey"
  security_groups = [aws_security_group.sg_frontend_terraform_1.name]
  tags = {
    Name = "frontend_1_terraform"
  }
}

resource "aws_instance" "frontend_2_terraform" {
  ami             = "ami-0c7217cdde317cfec"
  instance_type   = "t2.small"
  key_name        = "vockey"
  security_groups = [aws_security_group.sg_frontend_terraform_2.name]
  tags = {
    Name = "frontend_2_terraform"
  }
}

# Creamos una instancia EC2 para el servidor nfs.
resource "aws_instance" "nfs_server" {
  ami             = "ami-0c7217cdde317cfec"
  instance_type   = "t2.small"
  key_name        = "vockey"
  security_groups = [aws_security_group.sg_nfs_terraform.name]
  tags = {
    Name = "nfs_server"
  }
}

# Creamos una instancia EC2 para el balanceador de carga.
resource "aws_instance" "load_balancer" {
  ami             = "ami-0c7217cdde317cfec"
  instance_type   = "t2.small"
  key_name        = "vockey"
  security_groups = [aws_security_group.sg_load_balancer_terraform.name]
  tags = {
    Name = "load_balancer"
  }
}

# Creamos una instancia EC2 para el backend.
resource "aws_instance" "backend" {
  ami             = "ami-0c7217cdde317cfec"
  instance_type   = "t2.small"
  key_name        = "vockey"
  security_groups = [aws_security_group.sg_backend_terraform.name]
  tags = {
    Name = "backend"
  }
}

# Creación de ips flotantes
# Creamos una IP elástica y la asociamos a la instancia

# Balanceador de carga.
resource "aws_eip" "load_balancer" {
  instance = aws_instance.load_balancer.id
}

# Frontend 1 y 2
resource "aws_eip" "ip_elastica_frontend_1" {
  instance = aws_instance.frontend_1_terraform.id
}

resource "aws_eip" "ip_elastica_frontend_2" {
  instance = aws_instance.frontend_2_terraform.id
}

# Backend
#resource "aws_eip" "ip_elastica_backend" {
#  instance = aws_instance.backend.id
#}

# NFS
resource "aws_eip" "ip_elastica_nfs" {
  instance = aws_instance.nfs_server.id
}

# Mostrar contenido ip elasticas 
output "load_balancer" {
  value = aws_eip.load_balancer.public_ip
}

# Mostrar contenido ip elasticas 
output "ip_elastica_frontend_1" {
  value = aws_eip.ip_elastica_frontend_1.public_ip
}

# Mostrar contenido ip elasticas 
output "ip_elastica_frontend_2" {
  value = aws_eip.ip_elastica_frontend_2.public_ip
}

# Mostrar contenido ip elasticas 
#output "ip_elastica_backend" {
#  value = aws_eip.ip_elastica_backend.public_ip
#}

# Mostrar contenido ip elasticas 
output "ip_elastica_nfs" {
  value = aws_eip.ip_elastica_nfs.public_ip
}