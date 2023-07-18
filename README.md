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

- In your browser, navigate to ```https://127.0.0.1:8000.preview.app.github.dev/v1/qr?url=<your-url>``` - localhost, ```https://qr-code-generator.<development-captain-domain>/v1/qr?url=<your-url>``` - Kubernetes deployment

A QR code will be generated
<img width="931" alt="image" src="https://github.com/GlueOps/github-actions-build-push-containers/assets/49791498/d66f773c-e05c-43db-b978-0bebbb303bb2">

## Deploying on ArgoCD
- Reference [this](https://github.com/GlueOps/project-template-helm-chart-app) repo for parameters to include in your ArgoCD manifest.

- Video guide [1](https://drive.google.com/file/d/1gBThTF1ln-UTrxrMmle6K_0YEXunxBjz/view) & [2](https://drive.google.com/file/d/1gBThTF1ln-UTrxrMmle6K_0YEXunxBjz/view)