## Environment Setup

Ubuntu 14.04 AMD64

### Install OpenLDAP

**Notice**: No need to run LDAP now, A standalone scheduler process is started now just for research.

```bash
sudo apt-get install slapd ldap-utils

# Set dc to 'dc=ms,dc=com'
sudo dpkg-reconfigure slapd
```

Or you could use ApacheDS, set LDAP server to allow ananymous user to add or modify entries.

### Environment Variables

```bash
source init.sh
```

### Code

Use the code in gaocegege/dev/SJTU branch
