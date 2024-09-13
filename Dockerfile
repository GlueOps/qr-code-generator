# Use an official Python runtime as a parent image
FROM python:3.11.10-alpine@sha256:004b4029670f2964bb102d076571c9d750c2a43b51c13c768e443c95a71aa9f3

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
