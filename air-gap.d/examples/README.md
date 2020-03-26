# Example Files for Air-Gapped / Registry Mirror Setup 
>This directory (./air-gap.d/examples/) contains some example configuration files used for setting up vagrant-caasp
to use a registry mirror instead of the default _registry.suse.com_ to deploy SUSE CaaSP (or other containers for
demos, etc).

>There are a variety of "air-gap" designs that could be leveraged for a CaaSP deployment, with or without further
environment complexities (http proxy, etc).

>This method is reconfiguring cri-o's registry sources and specifying a registry and host that is to used as a 
redirect/mirror.  It allows for secure and insecure registry configurations and accounts for /etc/hosts manipulation
if needed.

**NOTE:**
The vagrant-caasp command-line option for air-gap/registry mirror setup : '-a' **REQUIRES** at least one configuration
file to be prepared for it to work! See below. 

# Files
* air-gapped-registries.conf (**required** for deploy_caasp.sh '-a' parameter to succeed.)
* registry-ca.crt (optional)
* add2hosts.in (optional)

# air-gapped-registries.conf
>This file is a replacement file for cri-o's /etc/containers/registries.conf. It should follow the configuration
guidelines in the cri-o documentation.  The example file can be modified to point to your registry mirror (change
entries for 'rmtreg151.susetest.com:5000').  Format is **TOML** (format 2).

References here:

[SUSE CaaSP Admin Guide](https://documentation.suse.com/suse-caasp/4.0/html/caasp-admin/_miscellaneous.html#_configuring_container_registries_for_cri_o)
 
[Github Reference Docs](https://raw.githubusercontent.com/containers/image/master/docs/containers-registries.conf.5.md "From GitHub")

>First line in the example _air-gapped-registries.conf_ file points to the registry as a target for "unqualified-search-
registries".  This is a catch-all for any request that can't be serviced by the defined [[registry]] entries that follow.
 
>Each [[registry]] in the example specifies a "mirror" location that will redirect any request that is made against the
listed "location" target.  For example, the first [[registry]] is a redirection for any image request located at
'registry.suse.com/caasp/v4'.  These requests will instead be directed to the rmtreg151.susetest.com host. Notice the
location includes the original directory appended to it here.  This will depend on how the caasp images were mirrored
and their hierarchy within the registry.  

>The example also has the 'insecure = true' setting for the 'location' - i.e. does it require authentication?  Note the
mirror location is also defined as 'insecure'.  If you have a secure registry, you can include the ca certificate that
was used to generate the certificate securing it, and the air-gap function will take care of it (see cert explanations below).

>The 'unqualified-search' indicates that this registry should not be referenced as a catch-all location for images that
can't be found in the list of defined registries.  The global target for 'unqualified-search-registries' is already set (above).

**Registry Example in air-gapped-registries.conf:**

    unqualified-search-registries = ["rmtreg151.susetest.com:5000"]

`[[registry]]                                                                                                          
blocked = false                                                                                                        
insecure = true                                                                                                        
location = "registry.suse.com/caasp/v4"                                                                                
mirror = [  {location = "rmtreg151.susetest.com:5000/registry.suse.com/caasp/v4", insecure = true}]                    
unqualified-search = false
`     

# registry-ca.crt
>This optional file is a copy of the CA certificate file that came from the CA that generated the server certificate
that is used for a secure registry.  By putting a copy of this file into the _/vagrant-caasp/air-gap.d/registry-ca.crt_, the air-gap option for deploy_caasp.sh will copy this into the CaaSP cluster nodes and update their ca certificate
trusts.  This will allow for secure communications during image retrievals.

**NOTE:**
The _registry-ca.crt_ **needs to be owned by root:root with 0640 POSIX rights,** the update-ca-certificates process requires this.

# add2hosts.in
>This optional file contains text entries that can be appended to the CaaSP nodes _/etc/hosts_ files.  This allows for
supplemental DNS resolution when adding registry mirrors or other infrastructure you need for your vagrant-caasp
deployments.
 
Recommend adding at least your custom registry mirror so it can be resolved by name.  Format must be compatible with /etc/hosts standard (IP Address       Hostname       Alias).

---

# Procedure
**(Required)**

```
Copy the ./air-gap.d/examples/air-gapped-registries.conf into the parent directory,
./air-gap.d/
```

>Modify the example to point to your private registry and namespaces (where the SUSE
CaaS Platform installation images are mirrored.  (hint: you can use 'skuba cluster
images' command to list the image and version tag for a particular CaaSP release.
e.g. skuba cluster images | awk '/1.16.2/ {print $2}' - make sure they are available
before you kick off a deployment)


**(Optional)**

```
Add a copy of your CA certificate file (into the ./air-gap.d/ directory)
and name it registry-ca.crt.  This is the public certificate of the CA that
signed the server certificate used to protect the private registry/mirror.
```

**Note:** This is the public certificate of the CA that signed the server certificate used to protect the private registry/mirror.


**(Optional)**

``` 
Add a file with hosts entries (for your registry or other hosts) to append
them to the SUSE CaaSP nodes.  You must name this file 'add2hosts.in'.
```

>This really helps ensure your master and worker nodes can find your host (by name),
which is important if you are using a cert with a DNS entry (or at least a subj alt name). 


---

Run your vagrant-caasp deployment as documented:


# Initial deployment


    cd vagrant-caasp

    ./deploy_caasp.sh -m <model> < --full > < -a >
    # -a will deploy air-gap/registry mirror settings prior to SUSE CaaSP cluster deployment
    # --full will attempt to bring the machines up and deploy the cluster.
    # Please adjust your memory settings in the config.yml for each machine type.
    # Do not run vagrant up, unless you know what you're doing and want the result

    Usage deploy_caasp.sh [options..]
    -m, --model <model>   Which config.yml model to use for vm sizing
                          Default: "minimal"
    -f, --full            attempt to bring the machines up and deploy the cluster
    -a, --air-gapped      Setup CaaSP nodes with substitute registries (for deployment and/or private image access)
    -i, --ignore-memory   Don't prompt when over allocating memory
    -t, --test            Do a dry run, don't actually deploy the vms
    -v, --verbose [uint8] Verbosity level to pass to skuba -v (default is 1)
    -h,-?, --help         Show help

Refer to vagrant-caasp GitHub repository for more information about the ./deploy_caasp.sh
script and options.


# NOTES


