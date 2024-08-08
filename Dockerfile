# Use an official Python runtime as a parent image
FROM python:3.12.5-alpine@sha256:c2f41e6a5a67bc39b95be3988dd19fbd05d1b82375c46d9826c592cca014d4de

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
