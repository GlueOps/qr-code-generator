# Use an official Python runtime as a parent image
FROM python:3.13.5-alpine@sha256:37b14db89f587f9eaa890e4a442a3fe55db452b69cca1403cc730bd0fbdc8aaf

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
