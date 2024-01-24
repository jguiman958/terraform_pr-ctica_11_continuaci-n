# Configuramos el proveedor de AWS
provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAWKPXDFVALDUEP5FJ"
  secret_key = "y6TOt3eYXNxB1RUkZ9VXutg12mZL54hM3yIJZPVg"
  token      = "FwoGZXIvYXdzEIv//////////wEaDE52sAQrEdlGOYNMxCLJAR9eCcLGM8N5QXCT/oaipAcMLq+ezyGbjQBver7fqdo2mDRHt/lYPGfWdjE3lpMYqwVg22Sof+Ae2eF7uQI+z32CumAirsRmi8oyKCFVHh9G+pwQxj1hzujFy2S/Cn1Zr2p1wcxIK+WLM1/JwOPG1S468g/GksuqYfZKBpsnJnCJp/gtID4yFO1qV0O7a2/YBEhtl/MdAt/LN62r9FlzL4qw+jkGGI1Za0FG3AR3WHbUJXNjT65u2RiD1v/hjtuRm+weUIDikOdsJyj1nLWtBjItPSV3UYYDaMnhObYhVzQa1kouHFPHTRpVv9/5GX2QgUM8L7oNrbBUfkFqa6xz"
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