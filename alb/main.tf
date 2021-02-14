resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "${var.vpc_id}"
}

# resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment1" {
#   target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
#   target_id        = "${var.instance1_id}"
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment2" {
#   target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
#   target_id        = "${var.instance2_id}"
#   port             = 80
# }


resource "aws_lb" "my-aws-alb" {
  name     = "my-test-alb"
  internal = false

  security_groups = [
    "${aws_security_group.my-alb-sg.id}",
  ]

  subnets = [
    "${var.subnet1}",
    "${var.subnet2}",
  ]

  tags = {
    Name = "my-test-alb"
  }

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = "${aws_lb.my-aws-alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  }
}

resource "aws_security_group" "my-alb-sg" {
  name   = "my-alb-sg"
  vpc_id = "${var.vpc_id}"
}


resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_port" {
  from_port         = 3000
  protocol          = "tcp"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port           = 3000
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

##################  ASG

resource "aws_launch_configuration" "my-test-launch-config" {
  name_prefix   = "terraform-lc-example-"
  image_id      = "ami-0996d3051b72b5b2c"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.my-alb-sg.id}"]
  #user_data              = "${data.template_file.init.rendered}"
  key_name = "terrakey"
  user_data = <<-EOF
              #!/bin/bash
              echo "Healthy File" >> /home/ubuntu/ankit.txt
              chmod 777 /home/ubuntu/ankit.txt
              curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
              sudo apt-get install -y nodejs
              mkdir -p /home/ubuntu/nodeapp
              cd /home/ec2-user/nodeapp; git init; git remote add origin https://github.com/chapagain/nodejs-mysql-crud.git 
              git pull origin master
              EOF
  
  lifecycle {
    create_before_destroy = true
  }
}
# data "template_file" "init" {
#   template = "${file("${path.module}/userdata.tpl")}"
# }

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.my-test-launch-config.name}"
  #security_groups = "${aws_security_group.my-alb-sg.id}"
  vpc_zone_identifier  = [
    "${var.subnet1}",
    "${var.subnet2}",
  ]
  target_group_arns    = ["${aws_lb_target_group.my-target-group.arn}"]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 3

  tag {
    key                 = "Name"
    value               = "my-test-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "my-asg-sg" {
  name   = "my-asg-sg"
  vpc_id = "${var.vpc_id}"
}

# resource "aws_security_group_rule" "inbound_ssh" {
#   from_port         = 22
#   protocol          = "tcp"
#   security_group_id = "${aws_security_group.my-asg-sg.id}"
#   to_port           = 22
#   type              = "ingress"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "inbound_http" {
#   from_port         = 80
#   protocol          = "tcp"
#   security_group_id = "${aws_security_group.my-asg-sg.id}"
#   to_port           = 80
#   type              = "ingress"
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "outbound_all" {
#   from_port         = 0
#   protocol          = "-1"
#   security_group_id = "${aws_security_group.my-asg-sg.id}"
#   to_port           = 0
#   type              = "egress"
#   cidr_blocks       = ["0.0.0.0/0"]
# }


