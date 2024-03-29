# Practica_11. Construcción de instancias de una arquitectura en 3 niveles.
### ¿Qué necesitamos?

Anteriormente hemos realizado la creación de instancias manualmente, ahora lo idoneo sería generar un script que nos permita crear instancias automaticamente,
pero claro, para ello primero tenemos que construir dicho script... Lo haremos con terraform, terraform nos ayuda a realizar instalaciones desatendidas en aws.

Las instrucciones usadas en terraform son: ``terraform init``,``terraform fmt``, ``terraform validate``, ``terraform plan`` y ``terraform apply``.

Los cuales cada uno realiza lo siguiente:

```
Terraform init --> Descargamos los plugins del proveedor, en este caso el de aws.

Terraform fmt --> Formatea el fichero de configuración para que sea mas legible, tareas que realiza: ajusta la indentación, ordena los argumentos de los bloques de configuración.

Terraform validate --> Validamos que la sintaxis del comando es correcta.

Terraform plan --> Mostramos los cambios que se van a aplicar.

Terraform apply --> Y aplicamos los cambios.
```

Debe realizarse según el orden que has ido leyéndolo, de arriba para abajo puedes saltarte el validate... no te lo recomiendo.

### Recomiendo instalar terraform desde snap.
Estableciendo lo siguiente:

```
sudo apt update && sudo apt install snapd
```

Y luego esta sentencia para terraform...

```
sudo snap terraform --classic
```

## Fichero main.tf

### En este apartado tenemos que crear al proveedor en este caso es aws, donde queremos crear las instancias...
```
# Configuramos el proveedor de AWS
provider "aws" {
  region     = "us-east-1"
  access_key = "clave_acceso" <--ESTO CAMBIA SIEMPRE TENLO EN CUENTA
  secret_key = "secret_token" <--ESTO CAMBIA SIEMPRE TENLO EN CUENTA
  token      = "clave_token_aws" <--ESTO CAMBIA SIEMPRE TENLO EN CUENTA
}
```
Es necesario poner la región, la clave de acceso, la clave secreta y un token de autenticación.

### Ahora vamos con los grupos de seguridad, es necesario uno para cada instancia.
```
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
```
Podemos ver que para asignar una regla de entrada y salida viene definido, dependiendo de si queremos conexiones entrantes o salientes, ingress, para entrantes, el cual se declara los puertos con ``from_port, to_port,protocol, cidr_blocks`` y egress para salientes.
```
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
```
Lo mismo para este, solo que tiene los mismos por ser el frontend al igual que el anterior...
```
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
```
Ya el servidor nfs requiere puertos distintos.. pero la sintaxis es la misma... Cabe destacar que la sintaxis correcta es:

``resource "aws_security_group" "nombre_grupo_seguridad" {name ="" description=""}``

Con seguir los ejemplos se entiende, es como si lo hicieramos desde el interfaz del navegador de aws, pero con sintaxis.

Estos son los grupos de seguridad para el balanceador, incluyendo el puerto 443 el cual muestra el contenido de los frontend de forma segura.
```
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
```

Lo mismo para el grupo de seguridad de backend... en este al final incluí que aceptase los ping (icmp).
```
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
```

## Creación de las instancias.
Aquí vamos a crear las instancias.

La estructura es muy simple, simplemente tenemos que elegir el ami de la instancia, los componentes hardware que va a tener (memoria ram, procesadores...), la clave que eso viene definido cuando creamos nuestra instancia, en mi caso es vockey, el grupo de seguridad, el cual se le debe de asignar a la instancia con la siguiente directiva: [security_groups = [aws_security_group.sg_frontend_terraform_1.name]] y finalmente la etiqueta tag, la cual da nombre a la instancia.

```
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
```
Con las demas son exactamente igual solo que con pequeñas variaciones, lo unico que se debe cambiar es la etiqueta y el nombre de la instancia.

```
resource "aws_instance" "frontend_2_terraform" {
  ami             = "ami-0c7217cdde317cfec"
  instance_type   = "t2.small"
  key_name        = "vockey"
  security_groups = [aws_security_group.sg_frontend_terraform_2.name]
  tags = {
    Name = "frontend_2_terraform"
  }
}
```

```
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
```

```
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
```

```
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
```

Con esto asignamos directamente el grupo a la instancia mientras se va creando, por eso tenemos que crear los grupos antes, ya que sin grupos, la instancia no se crea.

# Creación de ips elásticas para las máquinas.

También, vamos a automatizar el proceso de automatización de ips elásticas, para que no lo tengamos que hacer a mano.

## Balanceador de carga.
```
resource "aws_eip" "load_balancer" {
  instance = aws_instance.load_balancer.id
}
```

En este caso, estamos asignando el id de la maquina a la ip elástica, con ese sencillo paso.

## Frontend 1 y 2

```
resource "aws_eip" "ip_elastica_frontend_1" {
  instance = aws_instance.frontend_1_terraform.id
}
```

```
resource "aws_eip" "ip_elastica_frontend_2" {
  instance = aws_instance.frontend_2_terraform.id
}
```

Hacemos exactamente lo mismo aquí con frontend 1 y 2 almacenando en ``instance`` el id de la instancia y otorgandole el recurso de ip flotante. 

## Backend

```
#resource "aws_eip" "ip_elastica_backend" {
#instance = aws_instance.backend.id
#}
```

Mas de lo mismo con el backend y la siguientes máquinas, esta comentado porque no puedo crear mas de 5 ips elásticas, y teniendo encuenta que trabajo con el nodo central, puedo crear el backend, sin embargo no puedo asignarle una ip flotante.

# NFS.

Como podemos comprobar cada uno tiene un nombre propio, para la variable del recurso.

```
resource "aws_eip" "ip_elastica_nfs" {
  instance = aws_instance.nfs_server.id
}
```

# Mostrar contenido ip elasticas 

Con esto podemos mostrar que ips flotantes se asignan a la instancia al final de la ejecución del fichero ``main.tf``

```
output "load_balancer" {
  value = aws_eip.load_balancer.public_ip
}

output "ip_elastica_frontend_1" {
  value = aws_eip.ip_elastica_frontend_1.public_ip
}

output "ip_elastica_frontend_2" {
  value = aws_eip.ip_elastica_frontend_2.public_ip
}

#output "ip_elastica_backend" {
#  value = aws_eip.ip_elastica_backend.public_ip
#}

output "ip_elastica_nfs" {
  value = aws_eip.ip_elastica_nfs.public_ip
}
```

Si queremos comprobar que funciona, solo tenemos que irnos al panel de las instancias creadas de aws y comprobar que se ha iniciado.

## Comprobaciones.
### Creación de los grupos de seguridad:
En la siguiente imagen se ven los grupos de seguridad creados.
![Captura1](https://github.com/jguiman958/terraform_pr-ctica_11_continuaci-n/assets/145347496/2e2a1b58-b8f6-427f-a795-87640125c784)
![Captura2](https://github.com/jguiman958/terraform_pr-ctica_11_continuaci-n/assets/145347496/4836e1a2-2019-45fa-906a-ec7d8f66bfac)
![Captura3](https://github.com/jguiman958/terraform_pr-ctica_11_continuaci-n/assets/145347496/0dc5fb67-2f2b-44ee-8fdf-9858dd85fcc8)
![Captura4](https://github.com/jguiman958/terraform_pr-ctica_11_continuaci-n/assets/145347496/61c8ed5a-73bb-4ae1-953e-47eb36123985)
![Captura5](https://github.com/jguiman958/terraform_pr-ctica_11_continuaci-n/assets/145347496/eb7b8195-f99f-43c0-869c-7b672b58c19c)
Si esto no se crea la instancia no se creará.

### Creación de las instancias:
En esta imagen vemos que me ha creado todas esas instancias a la vez, exluyendo la del nodo principal e instancia1 y instancia2.

![instancias_terraform](https://github.com/jguiman958/practica_11_terraform/assets/145347496/fe019bd3-81e2-4f2c-97c6-b9e049117385)

Y aquí lo tenemos, esto nos enseña a ver una forma cómoda de crear instancias, de forma muy sencilla.

### Creación de las ips elásticas.

![Captura6](https://github.com/jguiman958/terraform_pr-ctica_11_continuaci-n/assets/145347496/9f6bf242-6b74-4a57-bfda-bfdc6d8f8035)
Se han creado y asignado a la instancia, todas a la vez.

### Muestra de las instancias con ips flotantes asociadas.
![Captura7](https://github.com/jguiman958/terraform_pr-ctica_11_continuaci-n/assets/145347496/db601e7e-8b1e-4a90-b355-fd25a57ffcef)

No está la del backend ya que solo puedo asignar un máximo de 5 y la última está asociada por el nodo principal.
