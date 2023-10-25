# K8s Access

## Create Certificate for other users

### Create User on Control Plane Node (Optional)
```
useradd <username> && cd /home/<username>
```

### Install Certficate Library

```
sudo apt install openssl
```

### Create User Certificate
```
openssl genrsa -out <username>.key 2048

# Without Group
openssl req -new -key <username>.key \
  -out <username>.csr \
  -subj "/CN=<username>"
```

### Associate User Certificate with Certificate Authority
```
openssl x509 -req -in <username>.csr \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out <username>.crt -days 500

mkdir .certs && mv <username>.crt .certs/ && <username>.key .certs/

kubectl config set-credentials <username> \
  --client-certificate=/home/<username>/.certs/<username>.crt \
  --client-key=/home/<username>/.certs/<username>.key
```

The certificate will appear for the the user you are currently logged in as ~/.kube directory in the config file.

### Create Confg for Kubernetes Role for User Certificate

Create a file with the following content and kubectl apply -f <filename>

```
apiVersion: v1
clusters:
- cluster:
   certificate-authority-data: {Parse content here from certificate above for user}
   server: {Parse content here from certificate above for user}
  name: kubernetes
contexts:
- context:
   cluster: kubernetes
   user: <username>
  name: <username>-context
current-context: <username>-context
kind: Config
preferences: {}
users:
- name: <username>
  user:
   client-certificate: /home/jean/.certs/<username>.cert
   client-key: /home/jean/.certs/<username>.key
```

Create Roles for the user and kubectl apply -f <filename>

```
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: list-deployments
  namespace: my-project-dev
rules:
  - apiGroups: [ apps ]
    resources: [ deployments ]
    verbs: [ get, list ]
---------------------------------
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: list-deployments
rules:
  - apiGroups: [ apps ]
    resources: [ deployments ]
    verbs: [ get, list ]
```



### Bind Role to Cluster
Craete file and kubectl apply -f <filename>
- use ClusterRoleBinding without a metadata:namespace field.
- In order to update a Rolebinding; Delete the rolebinding First and then recreate.
- Cannot be updated via apply
```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: <username>
  namespace: my-project-dev
subjects:
- kind: User
  name: <username>
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: edit
  apiGroup: rbac.authorization.k8s.io
---------------------------------
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: <username>
  namespace: my-project-prod
subjects:
- kind: User
  name: <username>
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

### Test RoleBinding for User
```
# verb/resource element is one item within array of verbs for rule above.
kubectl auth can-i <verb> <resource> --as=<username> --namespace <namespace>
```
