# QR-code-generator

A FastAPI endpoint that creates QR codes based off given URLs

## Setting up .env file

- Clone your specific cluster's [repo](https://github.com/development-captains/) into a codespace.

- Then run, in the root folder
```bash
$ source .env
```

- Clone the repository you want to work on and ```cd``` into that directory.
  
## Running the QR code generator

- Development environment

```python
uvicorn qr-generator:app --reload
```

- Ensure [public](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/restricting-the-visibility-of-forwarded-ports#overview) port forwarding in codespace.

## Running the Dockerfile

```bash
$ docker build -t qr-bot-generator .
$ docker run -p 8000:8000 qr-bot-generator
```

## Access the website

- In your browser, navigate to ```https://127.0.0.1:8000.preview.app.github.dev/v1/qr?url=<your-url>```

A QR code will be generated
<img width="931" alt="image" src="https://github.com/GlueOps/github-actions-build-push-containers/assets/49791498/d66f773c-e05c-43db-b978-0bebbb303bb2">

## Creating a Helm Chart
To create a Kubernetes deployment using Helm charts, run the following commands:
```bash
$ helm install qr-code-generator . --create-namespace -n glueops-core-qr-code-generator 
```

- Upgrade configurations
```bash
$ helm upgrade qr-code-generator . -n glueops-core-qr-code-generator
```

## Debugging

- To view all namespaces
```bash
$ helm list -A
```

- View manifests in specific namespace
```bash
$ kubectl get all -n <name-space>
```

- Fetch specific manifest in all namespaces
```bash
$ kubectl get ingress -A
```

- Get specific manifest (ingress) from specific namespace
```bash
$ kubectl get ingress/<name> -n <name-space>
```

- View changes in configuration
```bash
$ helm diff upgrade qr-code-generator . -n glueops-core-qr-code-generator
```

- Render a well formatted manifest
```bash
$ helm template qr-code-generator . -n glueops-core-qr-code-generator
```

- See if the newly setup cluster is available over the internet
```bash
$ dig +trace <value-of-host-in-ingress.yaml-file>
```
