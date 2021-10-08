## Steps

1. Create the root cert/key pair which will be used by each cert-manager instance
```
./gen-relay-root-ca.sh
```
2. Create the tokens necessary for relay communication and create the certificates for the mgmt server and each leaf cluster via cert-manager custom resources
```
./bootstrap-relay-secrets.sh
```
3. Install Gloo Mesh management plane on mgmt cluster and Gloo Mesh agents on leaf clusters. Set the correct values to use relay certs we've already created
```
./install-gloo-mesh.sh
```

