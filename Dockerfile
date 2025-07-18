# Use an official Python runtime as a parent image
FROM python:3.11.13-alpine@sha256:9ce54d7ed458f71129c977478dd106cf6165a49b73fa38c217cc54de8f3e2bd0

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
