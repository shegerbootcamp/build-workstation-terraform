### How to provision server

```
terrafom init
terrafom plan
terraform apply
```

### How to fetch private keys from ssm parameter store 

```
aws ssm get-parameter --name "/ec2/key-pair/jemal.master/private-rsa-key-pem" --output text --query Parameter.Value >> jemal.master.pem
```


### Nagios Notification Policy for EC2 Servers

#### Overview
This document outlines the current notification rules for EC2 servers monitored by Nagios. The configuration includes defined contacts, notification services, and conditions to trigger alerts based on specific thresholds. Additionally, Nagios will periodically dump program status every 10 seconds.

---

#### Contacts and Notification Rules

**Defined Contact:**

```cfg
define contact {
    contact_name                  ec2-admin
    use                           generic-contact
    alias                         EC2 Admin
    email                         ec2-admin@example.com
    service_notification_period   24x7
    host_notification_period      24x7
    service_notification_options  w,u,c,r,f
    host_notification_options     d,u,r,f
    service_notification_commands notify-service-by-email
    host_notification_commands    notify-host-by-email
}
```

- **contact_name**: Identifier for the contact.
- **use**: Inherits properties from the `generic-contact` template.
- **alias**: Descriptive name for the contact.
- **email**: Email address for notifications.
- **service_notification_period**: Times during which notifications can be sent for services (24x7).
- **host_notification_period**: Times during which notifications can be sent for hosts (24x7).
- **service_notification_options**: Conditions for service notifications: warning (w), unknown (u), critical (c), recovery (r), and flapping (f).
- **host_notification_options**: Conditions for host notifications: down (d), unreachable (u), recovery (r), and flapping (f).
- **service_notification_commands**: Command to use for service notifications.
- **host_notification_commands**: Command to use for host notifications.

---

#### Conditions and Thresholds for Triggering Alerts

- **Disk Usage:**
  - Warning threshold: 80%
  - Critical threshold: 90%
  - Command: `-w 80 -c 90`
  
- **Memory Usage:**
  - Warning threshold: 80%
  - Critical threshold: 90%
  - Command: `-w 80 -c 90`

- **CPU Load:**
  - Load thresholds: 60%, 80%, 80%
  - Command: `-l 60,80,80`

- **Linux Server Disk Checks:**
  - Local disk:
    - Warning threshold: 20%
    - Critical threshold: 10%
    - Command: `-w 20% -c 10%`
  - Commercial Cloud disk usage:
    - Warning threshold: 15%
    - Critical threshold: 10%
    - Specific directories: `/data` or `/log`
    - Command: `-w 15% -c 10%`

- **Certificate Expiration:**
  - Notification threshold: 30 days before expiration

- **Ping Check:**
  - Verifies that the host is reachable via ICMP (ping).

- **HTTP Service Alive Check:**
  - Verifies that an HTTP service is running on the specified port (default is 80).

---

#### Service Availability Monitoring

- **Triggering Condition:** 
  - An alert is triggered when a monitored service is down.
  - Service availability is checked periodically as defined in the Nagios configuration.

---

#### Example Configuration Snippets

**Host Check:**

```cfg
define host {
    use                     linux-server
    host_name               ec2-instance-1
    alias                   My EC2 Instance
    address                 <EC2-Instance-IP>
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
    contacts                ec2-admin
    contact_groups          ec2-admins
    check_command           check-host-alive
}
```

**Service Check for Disk Usage:**

```cfg
define service {
    use                     generic-service
    host_name               ec2-instance-1
    service_description     Disk Usage
    check_command           check_disk! -w 80 -c 90
    notifications_enabled   1
    contacts                ec2-admin
    contact_groups          ec2-admins
}
```

**Service Check for Memory Usage:**

```cfg
define service {
    use                     generic-service
    host_name               ec2-instance-1
    service_description     Memory Usage
    check_command           check_memory! -w 80 -c 90
    notifications_enabled   1
    contacts                ec2-admin
    contact_groups          ec2-admins
}
```

**Service Check for CPU Load:**

```cfg
define service {
    use                     generic-service
    host_name               ec2-instance-1
    service_description     CPU Load
    check_command           check_load! -l 60,80,80
    notifications_enabled   1
    contacts                ec2-admin
    contact_groups          ec2-admins
}
```

**Service Check for Certificate Expiration:**

```cfg
define service {
    use                     generic-service
    host_name               ec2-instance-1
    service_description     SSL Certificate Expiration
    check_command           check_ssl_cert! -w 30
    notifications_enabled   1
    contacts                ec2-admin
    contact_groups          ec2-admins
}
```

**Service Check for HTTP Service:**

```cfg
define service {
    use                     generic-service
    host_name               ec2-instance-1
    service_description     HTTP Service
    check_command           check_http
    notifications_enabled   1
    contacts                ec2-admin
    contact_groups          ec2-admins
}
```

**Ping Check:**

```cfg
define service {
    use                     generic-service
    host_name               ec2-instance-1
    service_description     PING
    check_command           check_ping!100.0,20%!500.0,60%
    notifications_enabled   1
    contacts                ec2-admin
    contact_groups          ec2-admins
}
```

---

#### Periodic Program Status Dump

To configure Nagios to periodically dump the program status every 10 seconds, modify the Nagios main configuration file (`/usr/local/nagios/etc/nagios.cfg`):

1. **Open the Nagios configuration file**:

    ```bash
    sudo nano /usr/local/nagios/etc/nagios.cfg
    ```

2. **Set the interval for status updates**:

    Add or modify the following lines to set the status update interval to 10 seconds:

    ```cfg
    status_update_interval=10
    ```

3. **Save and exit the configuration file**.

4. **Restart Nagios** to apply the changes:

    ```bash
    sudo systemctl restart nagios
    ```

---

#### Summary

This document provides the configuration and rules for monitoring EC2 servers with Nagios. It includes the setup for contacts, conditions, and thresholds for triggering alerts to ensure effective monitoring and timely notifications for administrators. Additionally, it configures Nagios to periodically dump the program status every 10 seconds.

---


define service {
    name                    generic-service      ; The name of this service template
    active_checks_enabled   1                    ; Enable active checks
    passive_checks_enabled  1                    ; Enable passive checks
    check_interval          5                    ; Time in minutes between regular checks
    retry_interval          1                    ; Time in minutes between retries
    max_check_attempts      3                    ; Number of times to retry a failed check before considering the service down
    notification_interval   30                   ; Time in minutes between notifications
    notification_period     24x7                 ; Period during which notifications can be sent
    register                0                    ; Do not register this definition - it's a template
}



define host {
    name                    linux-server         ; The name of this host template
    use                     generic-host         ; Inherit default values from the generic host template
    check_interval          5                    ; Time in minutes between regular checks
    retry_interval          1                    ; Time in minutes between retries
    max_check_attempts      5                    ; Number of times to retry a failed check before considering the host down
    notification_interval   30                   ; Time in minutes between notifications
    register                0                    ; Do not register this definition - it's a template
}
