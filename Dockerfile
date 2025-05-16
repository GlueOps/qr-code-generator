# Use an official Python runtime as a parent image
FROM python:3.12.10-alpine@sha256:9c51ecce261773a684c8345b2d4673700055c513b4d54bc0719337d3e4ee552e

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
