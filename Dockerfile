# Use an official Python runtime as a parent image
FROM python:3.12.7-alpine@sha256:e75de178bc15e72f3f16bf75a6b484e33d39a456f03fc771a2b3abb9146b75f8

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
