#! /bin/bash

MGMT=mgmt
CLUSTER1=cluster1
CLUSTER2=cluster2

# Installing GM
helm install vault hashicorp/vault -n vault \
  --kube-context ${MGMT} \
  --set "injector.enabled=false" \
  --set "server.dev.enabled=true" \
  --set "server.service.type=LoadBalancer" \
  --create-namespace

kubectl --context ${MGMT} apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

kubectl --context ${MGMT} exec -n vault vault-0 -- /bin/sh -c 'vault secrets enable pki'

kubectl --context ${MGMT} exec -n vault vault-0 -- /bin/sh -c 'vault write -format=json pki/root/generate/internal \
 common_name="Solo.io Root CA" organization="solo.io"  ttl=187600h'

kubectl --context ${MGMT} exec -n vault vault-0 -- /bin/sh -c 'vault secrets enable -path pki_relay pki'

kubectl --context ${MGMT} exec -n vault vault-0 -- /bin/sh -c 'vault write \
  -format=json pki_relay/intermediate/generate/internal \
  common_name="enterprise-networking-ca" organization="mesh.solo.io" ttl=43800h'

kubectl --context ${MGMT} exec -n vault vault-0 -- /bin/sh -c 'vault write -format=json pki/root/sign-intermediate \
  csr="-----BEGIN CERTIFICATE REQUEST-----
MIICtTCCAZ0CAQAwOjEVMBMGA1UEChMMbWVzaC5zb2xvLmlvMSEwHwYDVQQDExhl
bnRlcnByaXNlLW5ldHdvcmtpbmctY2EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
ggEKAoIBAQDFvAv2m+mJ+exwv6rpjUecWYcxkrRIBiuW2Xyxmm3w1Vpc5/wvZ1a5
AQVlC3g44CxnHebwLDFD+aLcI5RsVq95WCBKgi4TJGnugVVvNB3I8Y35SbX/7O5V
wWAk9h5bELApKnJyeKUNSMtImzO5Pcfl1stODkxeubWdub4L7F5MGx/en8j6nBjV
qLHFByKB8IzOjFajtCZVZPQfbAnfJl8nZYVkRfXLMMrAzc4zG5M/QM2mbGd+SYg5
wOoV52DCqtm6mWM5Do1DMM6Zi10+KXvpjAFQS4xEZwCrt9oRZJmJB4icfHxi8azV
zjPB9ARldcgohguvQvofnF8v2lkAxXRfAgMBAAGgNjA0BgkqhkiG9w0BCQ4xJzAl
MCMGA1UdEQQcMBqCGGVudGVycHJpc2UtbmV0d29ya2luZy1jYTANBgkqhkiG9w0B
AQsFAAOCAQEAscTBJXlZ8znveBO4DJIhTsySlB7m6ufzVznOSmbERnZx+JWJDVxm
I+J0DonpUX58HCsTKOHJJ8mV9R4A9/cz9wDaCXbPVnTcgtQA9eNLI62fwhKxbfNW
cxZ5QcDq1H0cCyp7jcjh3QjZyWjmEbf0Dt295mYrtVO0cxVQcxmjbxC1CnuYCxO0
UV4bAz4hi1iiOsbV4BbgZJ7YwSbQQ3xFCz5k+tGUBPVDn7zTxGmL4+Fv+g4LRHlT
g7FG7jU5MIuJIApYDZihvE76FthMvF8o2awlYu2q4cNQdQAX8f5+rZQYvDWOFgTq
bbF7o1KehuBiBAV+1Xk0YF8X5MFqo7n4AA==
-----END CERTIFICATE REQUEST-----" format=pem_bundle ttl=43800h'

kubectl --context ${MGMT} exec -n vault vault-0 -- /bin/sh -c 'vault write -format=json pki_relay/intermediate/set-signed certificate="-----BEGIN CERTIFICATE-----
MIIDZzCCAk+gAwIBAgIUdRc8V1Of/tQqztiD40pf63Ypic0wDQYJKoZIhvcNAQEL
BQAwLDEQMA4GA1UEChMHc29sby5pbzEYMBYGA1UEAxMPU29sby5pbyBSb290IENB
MB4XDTIxMTAxNDIwMzUzOVoXDTIxMTExNTIwMzYwOVowIzEhMB8GA1UEAxMYZW50
ZXJwcmlzZS1uZXR3b3JraW5nLWNhMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAuD4XnKj62nuUDFSgtXb7VVskCXKXPwQS57bchTLt6OHR5H4ai/wdVaZX
7dmz7tdjnLCStRUzhvaUaVJdZp9nrEdhHIzT816SI28wFQF1Z0DUC6T99aV9aSeY
jrAnI5rWNWCObxaEa1TxO7TnOE4c4LwXoNlFICGfp6j3eLqWAm9pY0pYQK6vQ9Ap
CBSAyzi0NWwDJSC22v5S33hU8Jq+0165mrA+jST3aB2+tB3uDEwQ67pSo80OBlMh
Cr8ujdrRhzh8/y7wRqF2ZNIfMzeV6HV0KayC4N7VrNwD4QCjJaXfvI5nrRTpNERz
cUYmcpiqTeFj/kGRC3CG11PiDnZjPwIDAQABo4GJMIGGMA4GA1UdDwEB/wQEAwIB
BjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBRJDxcPxUdIcmsJxALqhqU3xg5T
YDAfBgNVHSMEGDAWgBQczS2aEFyCMYhnj92LXu0Ww1dL4zAjBgNVHREEHDAaghhl
bnRlcnByaXNlLW5ldHdvcmtpbmctY2EwDQYJKoZIhvcNAQELBQADggEBAFFRb2fC
k/IGPjBUGz825KIZOUEuGmXAQXIqYGKL+IRGXZs5WxFnexQCk9FGrHe0u1wGIs0A
9KR8JPbagkbDLCzAPDlat7j05QZIpL3XpMsCj3VKMbPwh3uNK9EtXfMlyw69clJq
Ogrnta5gtgM7PEYWlV2AGde2grbUqVv0ab05j2pV4KVommQYB7vULZF9xvpDm8QH
9YWY/kvCrTtN0qDjtkKDkiZ5ropG+uMhmkzhpVlyNBYMBCqSxPruYsrOMScVFiXJ
NibatMUpTEhkTUVL9B8AUXiPveJEE933E7qmiiS9NUrfUUPf5Q/4ntygP9y/XkNT
dAbs4SqRc2DHa5A=
-----END CERTIFICATE-----"'

kubectl --context ${MGMT} exec -n vault vault-0 -- /bin/sh -c 'vault write pki_relay/roles/enterprise-networking-ca allow_any_name=true max_ttl="720h"'

kubectl --context ${MGMT} apply -f- <<EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: vault-issuer
  namespace: gloo-mesh
spec:
  vault:
    path: pki_relay/sign/enterprise-networking-ca
    server: http://35.245.37.143:8200
    auth:
      tokenSecretRef:
        name: vault-token
        key: token
EOF

kubectl --context ${MGMT} apply -f- <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: relay-server-tls
  namespace: gloo-mesh
spec:
  commonName: "enterprise-networking-ca"
  dnsNames:
    - "enterprise-networking-ca"
    - "enterprise-networking-ca.gloo-mesh"
    - "enterprise-networking-ca.gloo-mesh.svc"
    - "*.gloo-mesh"
  secretName: relay-server-tls-secret
  duration: 24h
  renewBefore: 30m
  privateKey:
    rotationPolicy: Always
    algorithm: RSA
    size: 2048
  usages:
    - digital signature
    - key encipherment
    - server auth
    - client auth
  issuerRef:
    name: vault-issuer
    kind: Issuer
    group: cert-manager.io
EOF

## Install on workload clusters
kubectl --context ${CLUSTER1} apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

kubectl --context ${CLUSTER1} create secret generic vault-token --from-literal=token=root -n gloo-mesh

kubectl --context ${CLUSTER1} apply -f- <<EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: vault-issuer
  namespace: gloo-mesh
spec:
  vault:
    path: pki_relay/sign/enterprise-networking-ca
    server: http://35.245.37.143:8200
    auth:
      tokenSecretRef:
        name: vault-token
        key: token
EOF

kubectl apply --context ${CLUSTER1} -f- <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: relay-client-tls
  namespace: gloo-mesh
spec:
  commonName: "enterprise-networking-ca"
  dnsNames:
    - "cluster1"
  secretName: relay-client-tls-secret
  duration: 24h
  renewBefore: 30m
  privateKey:
    rotationPolicy: Always
    algorithm: RSA
    size: 2048
  issuerRef:
    name: vault-issuer
    kind: Issuer
    group: cert-manager.io
EOF

## install on cluster2
kubectl --context ${CLUSTER2} apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

kubectl --context ${CLUSTER2} create secret generic vault-token --from-literal=token=root -n gloo-mesh

kubectl --context ${CLUSTER2} apply -f- <<EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: vault-issuer
  namespace: gloo-mesh
spec:
  vault:
    path: pki_relay/sign/enterprise-networking-ca
    server: http://35.245.37.143:8200
    auth:
      tokenSecretRef:
        name: vault-token
        key: token
EOF

kubectl apply --context ${CLUSTER2} -f- <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: relay-client-tls
  namespace: gloo-mesh
spec:
  commonName: "enterprise-networking-ca"
  dnsNames:
    - "cluster2"
  secretName: relay-client-tls-secret
  duration: 24h
  renewBefore: 30m
  privateKey:
    rotationPolicy: Always
    algorithm: RSA
    size: 2048
  issuerRef:
    name: vault-issuer
    kind: Issuer
    group: cert-manager.io
EOF
